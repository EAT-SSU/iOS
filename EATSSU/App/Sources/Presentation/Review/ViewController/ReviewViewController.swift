//
//  ReviewViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/04/07.
//

import UIKit

import FirebaseAnalytics
import Moya

final class ReviewViewController: BaseViewController {
    // MARK: - Properties

    let reviewProvider = MoyaProvider<ReviewRouter>(plugins: [ESMoyaLoggingPlugin()])
    var menuID: Int = .init()
    var type = "VARIABLE"
    private var menuNameList: [String] = []
    private var menuIDList: [Int]? = [Int]()
    private var menuDictionary: [String: Int] = [:]
    private var reviewList = [MenuDataList]()
    
    // ✨ V2 API 응답 데이터
    private var mealStatistics: ReviewMealStatisticsResponse?
    private var menuStatistics: ReviewMeuStatisticsResponse?
    private var totalReviewCount: Int = 0

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
        // ✨ V2 API 호출로 변경
        getStatistics()
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
        
        reviewTabBarView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
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
        if type == "VARIABLE" {
            let reviewVC = SetRateViewController(mealId: menuID)
            navigationController?.pushViewController(reviewVC, animated: true)
        } else {
            let reviewVC = SetRateViewController()
            reviewVC.dataBind(list: menuNameList,
                               idList: menuIDList ?? [],
                               reviewList: nil,
                               currentPage: 0)
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
            self.getReviewList(type: self.type, menuId: self.menuID)
            refresh.endRefreshing()
        }
    }

    func bindMenuID(id: Int) {
        menuID = id
    }

    private func showFixOrDeleteAlert(data: MenuDataList) {
        let alert = UIAlertController(title: "리뷰 수정 혹은 삭제",
                                      message: "작성하신 리뷰를 수정 또는 삭제하시겠습니까?",
                                      preferredStyle: UIAlertController.Style.actionSheet)
        
        let fixAction = UIAlertAction(title: "수정하기",
                                      style: .default,
                                      handler: { _ in
            let setRateViewController = SetRateViewController()
            setRateViewController.dataBindForFix(list: [data.menu], reivewId: data.reviewID)
            setRateViewController.settingForReviewFix(data: data)
            self.navigationController?.pushViewController(setRateViewController, animated: true)
        })
        
        let deleteAction = UIAlertAction(title: "삭제하기",
                                         style: .default,
                                         handler: { _ in
            self.showCustomDialog(
                title: "리뷰 삭제하기",
                message: "해당 리뷰를 삭제할까요?",
                cancelButtonTitle: "취소하기",
                confirmButtonTitle: "삭제하기"
            ) { [weak self] in
                self?.deleteReview(reviewID: data.reviewID)
            }
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

    
    // MARK: - Action Method

    func userTapReviewButton() {
        if RealmService.shared.isAccessTokenPresent() {
            activityIndicatorView.isHidden = false
            DispatchQueue.global().async {
                DispatchQueue.main.async { [self] in
                    if menuIDList == nil {
                        // FIXED
                        let setRateViewController = SetRateViewController()
                        menuIDList = [menuID]
                        setRateViewController.dataBind(list: menuNameList,
                                                       idList: menuIDList ?? [],
                                                       reviewList: nil,
                                                       currentPage: 0)
                        activityIndicatorView.stopAnimating()
                        navigationController?.pushViewController(setRateViewController, animated: true)
                    } else {
                        // VARIABLE
                        if menuIDList?.count == 1 {
                            let setRateViewController = SetRateViewController(mealId: menuID)
                            setRateViewController.dataBind(list: menuNameList,
                                                           idList: menuIDList ?? [],
                                                           reviewList: nil,
                                                           currentPage: 0)
                            activityIndicatorView.stopAnimating()
                            navigationController?.pushViewController(setRateViewController, animated: true)
                        } else {
                            let setRateViewController = SetRateViewController(mealId: menuID)
                            setRateViewController.dataBind(list: menuNameList,
                                                           idList: menuIDList ?? [],
                                                           reviewList: nil,
                                                           currentPage: 0)
                            activityIndicatorView.stopAnimating()
                            navigationController?.pushViewController(setRateViewController, animated: true)
                        }
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
                userTapReviewButton()
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

                cell.dataBind(response: reviewList[indexPath.row])
                cell.handler = { [weak self] in
                    guard let self else { return }

                    reviewList[indexPath.row].isWriter ? showFixOrDeleteAlert(data: reviewList[indexPath.row])
                        : showReportAlert(reviewID: cell.reviewId)
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

// MARK: - Server Setting

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
            responseType: ReviewMeuStatisticsResponse.self,
            useAuth: false
        ) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                self.menuStatistics = data
                self.totalReviewCount = data.totalReviewCount
                self.menuNameList = [data.menuName]
                self.makeDictionary()
                self.reviewTableView.reloadData()
            case .failure(let error):
                print("Fixed Menu Statistics Error: \(error.localizedDescription)")
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
                print("Meal Statistics Error: \(error.localizedDescription)")
            }
        }
    }

    // 하단 리뷰 리스트 불러오는 API
    func getReviewList(type: String, menuId _: Int) {
        reviewProvider.request(.reviewList(type, menuID)) { response in
            switch response {
            case let .success(moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<ReviewListResponse>.self)
                    guard let data = responseData.result else { return }
                    self.reviewList = data.dataList
                    self.reviewTableView.reloadData()
                    
                } catch let err {
                    print(err.localizedDescription)
                }
            case let .failure(err):
                print(err.localizedDescription)
            }
        }
    }

    func deleteReview(reviewID: Int) {
        reviewProvider.request(.deleteReview(reviewID)) { response in
            switch response {
            case .success:
                self.getStatistics()
                self.updateViewConstraints()
                self.getReviewList(type: self.type, menuId: self.menuID)
            case let .failure(err):
                print(err.localizedDescription)
            }
        }
    }
}

extension ReviewViewController: ReviewMenuTypeInfoDelegate {
    func didDelegateReviewMenuTypeInfo(for menuTypeData: ReviewMenuTypeInfo) {
        let reviewMenuTypeInfo = ReviewMenuTypeInfo(menuType: menuTypeData.menuType,
                                                    menuID: menuTypeData.menuID,
                                                    changeMenuIDList: menuTypeData.changeMenuIDList)
        type = reviewMenuTypeInfo.menuType
        menuID = reviewMenuTypeInfo.menuID
        menuIDList = reviewMenuTypeInfo.changeMenuIDList
    }
}

// MARK: - ReviewRateViewCell Extension for V2 API

extension ReviewRateViewCell {
    // ✨ Meal 통계 데이터 바인딩
    func configureWithMealStatistics(_ data: ReviewMealStatisticsResponse) {
        // 메뉴명 설정
        let menuNames = data.menuList.map { $0.name }
        menuLabel.text = menuNames.joined(separator: " + ")
        
        // 평균 별점 설정
        let ratingValue = data.rating
        if ratingValue == 0.0 {
            rateNumLabel.text = "-"
        } else {
            let total = String(format: "%.1f", ratingValue)
            rateNumLabel.text = "\(total)"
        }
        totalRate = ratingValue
        
        // 별점 차트 업데이트
        let totalCount = max(data.totalReviewCount, 1)
        fiveForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.fiveStarCount / totalCount)
        }
        fourForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.fourStarCount / totalCount)
        }
        threeForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.threeStarCount / totalCount)
        }
        twoForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.twoStarCount / totalCount)
        }
        oneForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.oneStarCount / totalCount)
        }
    }
    
    // ✨ Menu 통계 데이터 바인딩
    func configureWithMenuStatistics(_ data: ReviewMeuStatisticsResponse) {
        // 메뉴명 설정
        menuLabel.text = data.menuName
        
        // 평균 별점 설정
        let ratingValue = data.rating
        if ratingValue == 0.0 {
            rateNumLabel.text = "-"
        } else {
            let total = String(format: "%.1f", ratingValue)
            rateNumLabel.text = "\(total)"
        }
        totalRate = ratingValue
        
        // 별점 차트 업데이트
        let totalCount = max(data.totalReviewCount, 1)
        fiveForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.fiveStarCount / totalCount)
        }
        fourForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.fourStarCount / totalCount)
        }
        threeForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.threeStarCount / totalCount)
        }
        twoForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.twoStarCount / totalCount)
        }
        oneForeground.snp.updateConstraints {
            $0.width.equalTo(126 * data.reviewRatingCount.oneStarCount / totalCount)
        }
    }
}
