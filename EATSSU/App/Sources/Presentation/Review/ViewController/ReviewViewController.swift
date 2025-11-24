//
//  ReviewViewController.swift
//  EatSSU-iOS
//
//  Updated with full V2 API integration
//

import UIKit
import FirebaseAnalytics
import Moya
import SnapKit

// MARK: - Properties (모델 변경 반영)

// MenuInfo는 삭제하고 ReviewValidMenu로 통일

final class ReviewViewController: BaseViewController {
    // MARK: - Properties
    override var shouldHideTabBar: Bool {
            return true
        }
    let reviewProvider = MoyaProvider<ReviewRouter>(plugins: [ESMoyaLoggingPlugin()])
    var menuID: Int = .init()
    var type = "VARIABLE"
    private var menuNameList: [String] = []
    private var menuIDList: [Int]? = [Int]()
    private var menuDictionary: [String: Int] = [:]
    
    // ✨ V2 API로 변경: MenuDataList → ReviewListItem
    private var reviewList = [ReviewListItem]()
    
    // ✨ V2 API 응답 데이터
    private var mealStatistics: ReviewMealStatisticsResponse?
    private var menuStatistics: ReviewMenuStatisticsResponse?
    private var totalReviewCount: Int = 0
    
    // ✨ 리뷰 작성 가능한 메뉴 목록 (getValidMenusForReview)
    // 이 프로퍼티는 이제 typealias 덕분에 [ReviewValidMenu]와 동일합니다.
    private var validMenusForReview: [ReviewValidMenu] = []

    // MARK: - UI Component

    let refreshControl = UIRefreshControl()

    let reviewTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()

    private var activityIndicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.startAnimating()
        indicator.isHidden = true
        return indicator
    }()

    private lazy var noReviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiteral.noReview
        imageView.isHidden = true
        return imageView
    }()
    
    private let reviewTabBarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 0
        view.clipsToBounds = true
        return view
    }()
    
    private let reviewTabBarView: MainButton = {
        let button = MainButton()
        button.title = "리뷰 작성하기"
        return button
    }()

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setTableView()
        initRefresh()
        setFirebaseTask()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // ✨ V2 API 호출 순서: 통계 → 유효 메뉴 → 리뷰 리스트
        getStatistics()
        if type == "VARIABLE" {
            getValidMenusForReview() // VARIABLE 타입일 때만 호출
        }
        getReviewList(type: type, menuId: menuID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            var parentVC = self.parent
            while parentVC != nil {
                if let customTabBar = parentVC as? CustomTabBarContainerController {
                    customTabBar.setTabBarHidden(false, animated: false)
                    break
                }
                parentVC = parentVC?.parent
            }
        }
    }

    // MARK: - Functions

    override func configureUI() {
        reviewTableView.backgroundColor = .white
        view.addSubviews(reviewTableView,
                         activityIndicatorView,
                         noReviewImageView,
                         reviewTabBarContainer)
        reviewTabBarContainer.addSubview(reviewTabBarView)
    }

    override func setLayout() {
        reviewTableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(reviewTabBarContainer.snp.top)
        }
        
        activityIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        noReviewImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        reviewTabBarContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(80)
        }
        
        // 🛠️ Auto Layout 충돌 수정: .bottom 제약을 제거하여 MainButton 내부 높이 제약이 우선되도록 함
        reviewTabBarView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.top.equalToSuperview().offset(12)
            // $0.bottom.equalToSuperview().offset(-12) // 제거
        }
    }

    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = "리뷰"
    }
    
    override func setButtonEvent() {
        reviewTabBarView.addTarget(self, action: #selector(handleAddReviewButtonTap), for: .touchUpInside)
    }
    
    @objc private func handleAddReviewButtonTap() {
        // MARK: - 로직 수정
        
        if type == "VARIABLE" {
            let reviewVC = SetRateViewController(mealId: menuID)
            
            // 🛠️ 수정: .menuId 속성 사용
            reviewVC.dataBind(
                list: validMenusForReview.map { $0.name },
                idList: validMenusForReview.map { $0.menuId }
            )
            navigationController?.pushViewController(reviewVC, animated: true)
            
        } else { // FIXED
            let reviewVC = SetRateViewController(menuId: menuID)
            
            reviewVC.dataBind(
                list: menuNameList,
                idList: menuIDList ?? []
            )
            navigationController?.pushViewController(reviewVC, animated: true)
        }
    }

    private func setFirebaseTask() {
        FirebaseRemoteConfig.shared.fetchRestaurantInfo()

        #if DEBUG
        #else
            Analytics.logEvent("ReviewViewControllerLoad", parameters: nil)
        #endif
    }

    func setTableView() {
        reviewTableView.register(ReviewTableCell.self, forCellReuseIdentifier: ReviewTableCell.identifier)
        reviewTableView.register(ReviewRateViewCell.self, forCellReuseIdentifier: ReviewRateViewCell.identifier)
        reviewTableView.register(ReviewEmptyViewCell.self, forCellReuseIdentifier: ReviewEmptyViewCell.identifier)
        reviewTableView.register(ReviewDividerCell.self, forCellReuseIdentifier: ReviewDividerCell.identifier)

        reviewTableView.delegate = self
        reviewTableView.dataSource = self
    }

    func initRefresh() {
        refreshControl.addTarget(self,
                                 action: #selector(refreshTable(refresh:)),
                                 for: .valueChanged)

        reviewTableView.refreshControl = refreshControl
    }

    @objc
    func refreshTable(refresh: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.getStatistics()
            if self.type == "VARIABLE" {
                self.getValidMenusForReview()
            }
            self.getReviewList(type: self.type, menuId: self.menuID)
            refresh.endRefreshing()
        }
    }

    func bindMenuID(id: Int) {
        menuID = id
    }

    private func showDeleteAlert(data: ReviewListItem) {
            
            // ✨ 리뷰 작성자가 아니면 바로 신고 다이얼로그를 띄웁니다.
            if !data.isWriter {
                self.showReportAlert(reviewID: data.reviewId)
                return
            }
            
            // ✨ 리뷰 작성자인 경우: 삭제 시 Custom Dialog를 사용합니다.
            
            // Custom Dialog를 위한 데이터
            let title = "리뷰 삭제"
            let message = "해당 리뷰를 삭제할까요?"
            let confirmButtonTitle = "삭제하기"
            let cancelButtonTitle = "취소하기"
            
            self.showCustomDialog(
                title: title,
                message: message,
                cancelButtonTitle: cancelButtonTitle,
                confirmButtonTitle: confirmButtonTitle
            ) { [weak self] in
                guard let self = self else { return }
                
                // 삭제 확인 시, deleteReview 함수 호출
                self.deleteReview(reviewID: data.reviewId)
            }
        }
        
        private func showFixOrDeleteAlert_OLD(data: ReviewListItem) {
            let alert = UIAlertController(title: "리뷰 수정 혹은 삭제",
                                              message: "작성하신 리뷰를 수정 또는 삭제하시겠습니까?",
                                              preferredStyle: UIAlertController.Style.actionSheet)
                
                let fixAction = UIAlertAction(title: "수정하기",
                                              style: .default,
                                              handler: { _ in
                    
                    let menuNames = data.menu?.map { $0.name } ?? []
                    // ✨ MenuLike 배열에서 menuId만 추출 (수정 요청 DTO의 menuLikes를 구성하기 위함)
                    let menuIds = data.menu?.map { $0.menuId } ?? []
                    
                    // 🛠️ 수정: data.type에 따라 SetRateViewController 생성자 변경 필요
                    // ReviewViewController는 dataBindForFix를 사용할 것이므로 menuId 생성자를 사용하는 것이 적절
                    let setRateViewController = SetRateViewController(menuId: self.menuID)
                    
                    // 1. 리뷰 ID와 메뉴 이름을 바인딩 (UI 설정 및 reviewId 저장)
                    setRateViewController.dataBindForFix(list: menuNames, reviewId: data.reviewId)
                    
                    // 2. 리뷰 상세 정보 (별점, 내용, 이미지) 바인딩
                    setRateViewController.settingForReviewFix(data: data)
                    
                    // 3. 리뷰 수정 API 호출을 위한 추가 정보 바인딩 (menuId, isLike)
                    // SetRateViewController의 validMenuIDList와 likedStates에 원본 정보를 설정
                    let likedStates = data.menu?.map { $0.isLike } ?? []
                    setRateViewController.dataBindForFix(
                        menuNames: menuNames,
                        menuIds: menuIds,
                        likedStates: likedStates
                    )

                    self.navigationController?.pushViewController(setRateViewController, animated: true)
                })
            
            let deleteAction = UIAlertAction(title: "삭제하기",
                                                 style: .destructive,
                                                 handler: { [weak self] _ in
                    guard let self = self else { return }
                    
                    // ✨ V2 API를 사용하는 deleteReview 함수 호출 (reviewId 전달)
                    // ReviewRouter.deleteReview에 V2 Path와 Method가 적용되었으므로
                    // 이 함수 내부의 호출 로직은 변경 없이 V2 API를 사용하게 됩니다.
                    self.deleteReview(reviewID: data.reviewId)
                })
            
            let cancelAction = UIAlertAction(title: "취소하기",
                                             style: .cancel,
                                             handler: nil)
            
            alert.addAction(fixAction)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            present(alert, animated: true, completion: nil)
        }
    
    private func showReportAlert(reviewID: Int) {
        showCustomDialog(
            title: "리뷰 신고하기",
            message: "해당 리뷰를 신고하시겠습니까?",
            cancelButtonTitle: "취소하기",
            confirmButtonTitle: "신고하기"
        ) { [weak self] in
            let reportViewController = ReportViewController()
            reportViewController.bindData(reviewID: reviewID)
            self?.navigationController?.pushViewController(reportViewController, animated: true)
        }
    }

    func userTapReviewButton() {
        if RealmService.shared.isAccessTokenPresent() {
            activityIndicatorView.isHidden = false
            DispatchQueue.global().async {
                DispatchQueue.main.async { [self] in
                    
                    if type == "FIXED" {
                        let setRateViewController = SetRateViewController(menuId: menuID)
                        
                        setRateViewController.dataBind(
                            list: menuNameList,
                            idList: menuIDList ?? []
                        )
                        activityIndicatorView.stopAnimating()
                        navigationController?.pushViewController(setRateViewController, animated: true)
                    } else { // VARIABLE
                        let setRateViewController = SetRateViewController(mealId: menuID)
                        
                        // 🛠️ 수정: .menuId 속성 사용
                        setRateViewController.dataBind(
                            list: validMenusForReview.map { $0.name },
                            idList: validMenusForReview.map { $0.menuId }
                        )
                        activityIndicatorView.stopAnimating()
                        navigationController?.pushViewController(setRateViewController, animated: true)
                    }
                }
            }
        } else {
            showAlertControllerWithCancel(title: "로그인이 필요한 서비스입니다", message: "로그인 하시겠습니까?", confirmStyle: .default) {
                self.pushToLoginVC()
            }
        }
    }

    private func pushToLoginVC() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }

    func makeDictionary() {
        if menuIDList != [] {
            for (index, string) in menuNameList.enumerated() {
                let idValue = menuIDList?[index]
                menuDictionary[string] = idValue
            }
        }
    }
}

// MARK: - UITableView Delegate, DataSource

extension ReviewViewController: UITableViewDelegate {
    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
        print("cell did touched")
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            return 6
        case 2:
            return 8
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let spacerView = UIView()
        spacerView.backgroundColor = .clear
        return spacerView
    }
}

extension ReviewViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        3
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            1
        case 1:
            1
        case 2:
            if reviewList.count == 0 {
                1
            } else {
                reviewList.count
            }
        default:
            0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReviewRateViewCell.identifier, for: indexPath) as? ReviewRateViewCell ?? ReviewRateViewCell()
            cell.selectionStyle = .none
            
            // ✨ V2 API 데이터로 바인딩
            if type == "FIXED" {
                if let statistics = menuStatistics {
                    cell.configureWithMenuStatistics(statistics)
                }
            } else {
                if let statistics = mealStatistics {
                    cell.configureWithMealStatistics(statistics)
                }
            }
            
            cell.handler = { [weak self] in
                guard let self else { return }
                self.userTapReviewButton()
            }
            cell.reloadInputViews()
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReviewDividerCell.identifier, for: indexPath) as? ReviewDividerCell ?? ReviewDividerCell()
            cell.configure(reviewCount: totalReviewCount)
            cell.selectionStyle = .none
            return cell
            
        case 2:
            if reviewList.count == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: ReviewEmptyViewCell.identifier, for: indexPath) as? ReviewEmptyViewCell ?? ReviewEmptyViewCell()
                if RealmService.shared.getToken() == "" {
                    cell.configure(isTokenExist: false)
                } else {
                    cell.configure(isTokenExist: true)
                }
                cell.selectionStyle = .none
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: ReviewTableCell.identifier, for: indexPath) as? ReviewTableCell ?? ReviewTableCell()

                // ✨ ReviewListItem 직접 바인딩
                // 🛠️ 요청사항 반영: isLike가 true인 메뉴만 필터링하여 바인딩
                var filteredReviewItem = reviewList[indexPath.row]
                let likedMenus = filteredReviewItem.menu?.filter { $0.isLike }
                filteredReviewItem.menu = likedMenus
                
                cell.dataBind(response: filteredReviewItem)
                
                cell.handler = { [weak self] in
                    guard let self else { return }

                    reviewList[indexPath.row].isWriter ? self.showDeleteAlert(data: reviewList[indexPath.row])
                        : self.showReportAlert(reviewID: reviewList[indexPath.row].reviewId)
                }
                cell.selectionStyle = .none
                cell.reloadInputViews()
                return cell
            }

        default:
            return UITableViewCell()
        }
    }

    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            251.adjusted
        case 1:
            UITableView.automaticDimension
        case 2:
            if reviewList.count == 0 {
                300.adjusted
            } else {
                UITableView.automaticDimension
            }
        default:
            UITableView.automaticDimension
        }
    }
}

// MARK: - V2 API Network Calls

extension ReviewViewController {
    // ✨ V2 API: 통계 데이터 가져오기
    func getStatistics() {
        if type == "FIXED" {
            getFixedMenuStatistics()
        } else {
            getMealStatistics()
        }
    }
    
    // ✨ V2 API: 고정 메뉴 통계
    func getFixedMenuStatistics() {
        NetworkService.shared.request(
            ReviewRouter.getFixedMenuStatistics(menuID),
            responseType: ReviewMenuStatisticsResponse.self,
            useAuth: false
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.menuStatistics = data
                self.totalReviewCount = data.totalReviewCount
                self.menuNameList = [data.menuName]
                self.menuIDList = [self.menuID] // FIXED 메뉴는 menuIDList도 menuID로 설정
                self.makeDictionary()
                self.reviewTableView.reloadData()
            case .failure(let error):
                print("❌ Fixed Menu Statistics Error: \(error.localizedDescription)")
            }
        }
    }
    
    // ✨ V2 API: 식단 통계
    func getMealStatistics() {
        NetworkService.shared.request(
            ReviewRouter.getMealStatistics(menuID),
            responseType: ReviewMealStatisticsResponse.self,
            useAuth: false
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.mealStatistics = data
                self.totalReviewCount = data.totalReviewCount
                self.menuNameList = data.menuList.map { $0.name }
                self.menuIDList = data.menuList.map { $0.id }
                self.makeDictionary()
                self.reviewTableView.reloadData()
            case .failure(let error):
                // 🛠️ Meal Statistics Error 처리 개선 (rating: null 디코딩 오류 가정)
                print("❌ Meal Statistics Error: \(error.localizedDescription)")
                // 디코딩 실패해도 UI 갱신을 위해 reloadData 호출
                self.reviewTableView.reloadData()
            }
        }
    }
    
    // MARK: 🛠️ JSON Decoding 수정: responseType을 ReviewValidMenusResponse.self로 변경
    // ✨ V2 API: 리뷰 작성 가능한 메뉴 목록 조회 (VARIABLE 타입 전용)
    func getValidMenusForReview() {
        NetworkService.shared.request(
            ReviewRouter.getValidMenusForReview(menuID),
            responseType: ReviewValidMenusResponse.self, // 🛠️ Wrapper DTO 타입 사용
            useAuth: true
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                // 🛠️ 수정: result 내부의 menuList 배열을 사용 (타입이 [MenuInfo]로 일치)
                self.validMenusForReview = data.menuList
                print("✅ Valid Menus for Review: \(data.menuList.map { $0.name })")
            case .failure(let error):
                print("❌ Valid Menus Error: \(error.localizedDescription)")
                // 에러 발생 시 처리 (Meal Statistics에서 가져온 데이터가 타입이 다를 수 있으므로 임시 주석)
                // self.validMenusForReview = (self.mealStatistics?.menuList ?? [])
                break
            }
        }
    }

    // ✨ V2 API: 리뷰 리스트 불러오기
    func getReviewList(type: String, menuId _: Int) {
        if type == "FIXED" {
            getFixedMenuReviewList()
        } else {
            getMealReviewList()
        }
    }
    
    // ✨ V2 API: 고정 메뉴 리뷰 리스트
    func getFixedMenuReviewList() {
        NetworkService.shared.request(
            ReviewRouter.newReviewList(type, menuID, lastReviewId: nil, page: 0, size: 20),
            responseType: NewReviewListResponse.self,
            useAuth: true
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                // ✨ ReviewListItem을 그대로 사용
                self.reviewList = data.dataList
                self.reviewTableView.reloadData()
                print("✅ Fixed Menu Reviews loaded: \(self.reviewList.count) items")
            case .failure(let error):
                print("❌ Fixed Menu Review List Error: \(error.localizedDescription)")
            }
        }
    }
    
    // ✨ V2 API: 식단 리뷰 리스트
    func getMealReviewList() {
        NetworkService.shared.request(
            ReviewRouter.newReviewList(type, menuID, lastReviewId: nil, page: nil, size: 20),
            responseType: NewReviewListResponse.self,
            useAuth: true
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                // ✨ ReviewListItem을 그대로 사용
                self.reviewList = data.dataList
                self.reviewTableView.reloadData()
                print("✅ Meal Reviews loaded: \(self.reviewList.count) items")
            case .failure(let error):
                print("❌ Meal Review List Error: \(error.localizedDescription)")
            }
        }
    }

    func deleteReview(reviewID: Int) {
        NetworkService.shared.request(
            ReviewRouter.deleteReview(reviewID), // 1. ReviewRouter를 타겟으로 지정
            responseType: Bool.self,             // 2. 응답 타입은 Bool로 가정
            useAuth: true                        // 3. ✨ 인증 필요!
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                print("✅ Review 삭제 성공")
                // 삭제 성공 시, 통계 및 리뷰 목록을 새로고침
                self.getStatistics()
                if self.type == "VARIABLE" {
                    self.getValidMenusForReview()
                }
                self.getReviewList(type: self.type, menuId: self.menuID)
                self.showToast(message: "리뷰가 성공적으로 삭제되었습니다.") // 사용자에게 피드백 제공
                
            case let .failure(error):
                print("❌ Delete Review Error: \(error.localizedDescription)")
                self.showToast(message: "리뷰 삭제에 실패했습니다.")
            }
        }
    }
}

extension ReviewViewController: ReviewMenuTypeInfoDelegate {
    func didDelegateReviewMenuTypeInfo(for menuTypeData: ReviewMenuTypeInfo) {
        let reviewMenuTypeInfo = ReviewMenuTypeInfo(
            menuType: menuTypeData.menuType,
            menuID: menuTypeData.menuID,
            changeMenuIDList: menuTypeData.changeMenuIDList
        )
        type = reviewMenuTypeInfo.menuType
        menuID = reviewMenuTypeInfo.menuID
        menuIDList = reviewMenuTypeInfo.changeMenuIDList
    }
}
