//
//  ReviewViewController.swift
//  EatSSU-iOS
//
//  Created by 한금준 on 20/11/25.
//

import UIKit
import SnapKit

import Moya

import EATSSUDesign

final class ReviewViewController: BaseViewController {
    
    // MARK: - Properties
    override var shouldHideTabBar: Bool { true }
    
    private var shouldShowSuccessToast: Bool = false
    
    // MARK: - Network
    
    /// 리뷰 API 프로바이더
    let reviewProvider = MoyaProvider<ReviewRouter>(plugins: [ESMoyaLoggingPlugin()])
    
    // MARK: - Data Properties
    
    /// 메뉴 ID (FIXED 타입) 또는 식사 ID (VARIABLE 타입)
    var menuID: Int = 0

    /// 메뉴 타입 ("FIXED" 또는 "VARIABLE")
    var type = "VARIABLE"

    /// 리뷰 작성 대상 메뉴가 속한 식당 이름 (예: "학생 식당")
    private var restaurantName: String?
    
    /// 메뉴 이름 리스트
    private var menuNameList: [String] = []
    
    /// 메뉴 ID 리스트
    private var menuIDList: [Int]? = []
    
    /// 메뉴 이름-ID 매핑 딕셔너리
    private var menuDictionary: [String: Int] = [:]
    
    /// 리뷰 목록 데이터
    private var reviewList = [ReviewListItem]()
    
    /// 식사(Meal) 통계 데이터
    private var mealStatistics: ReviewMealStatisticsResponse?
    
    /// 메뉴(Menu) 통계 데이터
    private var menuStatistics: ReviewMenuStatisticsResponse?
    
    /// 전체 리뷰 개수
    private var totalReviewCount: Int = 0
    
    /// 리뷰 작성 가능한 메뉴 목록 (VARIABLE 타입)
    private var validMenusForReview: [ReviewValidMenu] = []

    /// 리뷰별 번역 상태 (셀 재사용에 대비해 reviewId 기준으로 보관)
    private var translationStates: [Int: ReviewTranslationState] = [:]

    /// 번역 기능 노출 여부 (현재 서버가 EN 번역만 지원 + 번역 API는 인증 필수)
    private var isTranslationAvailable: Bool {
        AppLanguageManager.shared.currentLanguage == .english
            && RealmService.shared.getToken() != ""
    }
    
    // MARK: - UI Components
    
    /// 리뷰 목록 테이블뷰
    let reviewTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    /// 빈 상태 이미지뷰
    private lazy var noReviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.noReview.image
        imageView.isHidden = true
        return imageView
    }()
    
    /// 리뷰 작성 버튼 컨테이너
    private let reviewTabBarContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 0
        view.clipsToBounds = true
        return view
    }()
    
    /// 리뷰 작성 버튼
    private let reviewTabBarView: MainButton = {
        let button = MainButton()
        button.title = TextLiteral.Review.writeReview
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        logScreenView(screenID: FirebaseScreenID.Review.V1.review_v1_1)
        setTableView()
        setFirebaseTask()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getStatistics()
        if type == "VARIABLE" {
            getValidMenusForReview()
        }
        getReviewList(type: type, menuId: menuID)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if shouldShowSuccessToast {
            showToast(message: TextLiteral.Review.registerReviewSuccess)
            shouldShowSuccessToast = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    // MARK: - UI Configuration
    
    override func configureUI() {
        reviewTableView.backgroundColor = .white
        
        view.addSubviews(
            reviewTableView,
            noReviewImageView,
            reviewTabBarContainer
        )
        reviewTabBarContainer.addSubview(reviewTabBarView)
    }
    
    override func setLayout() {
        reviewTableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(reviewTabBarContainer.snp.top)
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
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.top.equalToSuperview().offset(12)
        }
    }
    
    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = TextLiteral.Review.review
    }
    
    override func setButtonEvent() {
        reviewTabBarView.addTarget(
            self,
            action: #selector(handleAddReviewButtonTap),
            for: .touchUpInside
        )
    }
    
    // MARK: - TableView Setup
    
    private func setTableView() {
        reviewTableView.register(
            ReviewTableCell.self,
            forCellReuseIdentifier: ReviewTableCell.identifier
        )
        reviewTableView.register(
            ReviewRateViewCell.self,
            forCellReuseIdentifier: ReviewRateViewCell.identifier
        )
        reviewTableView.register(
            ReviewEmptyViewCell.self,
            forCellReuseIdentifier: ReviewEmptyViewCell.identifier
        )
        reviewTableView.register(
            ReviewDividerCell.self,
            forCellReuseIdentifier: ReviewDividerCell.identifier
        )
        
        reviewTableView.delegate = self
        reviewTableView.dataSource = self
    }
    
    // MARK: - Actions
    
    /// 리뷰 작성 버튼 탭 처리
    @objc private func handleAddReviewButtonTap() {
        ReviewAnalyticsManager.shared.logWriteReviewV2(restaurantName: restaurantName)

        if type == "VARIABLE" {
            let reviewVC = SetRateViewController(mealId: menuID)
            reviewVC.restaurantName = restaurantName
            reviewVC.dataBind(
                list: validMenusForReview.map { $0.name },
                idList: validMenusForReview.map { $0.menuId }
            )
            navigationController?.pushViewController(reviewVC, animated: true)

        } else {
            let reviewVC = SetRateViewController(menuId: menuID)
            reviewVC.restaurantName = restaurantName
            reviewVC.dataBind(
                list: menuNameList,
                idList: menuIDList ?? []
            )
            navigationController?.pushViewController(reviewVC, animated: true)
        }
    }
    
    /// 테이블 새로고침
    @objc private func refreshTable(refresh: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.getStatistics()
            if self.type == "VARIABLE" {
                self.getValidMenusForReview()
            }
            self.getReviewList(type: self.type, menuId: self.menuID)
            refresh.endRefreshing()
        }
    }
    
    // MARK: - Alert Methods
    
    /// 리뷰 삭제 확인 알림 표시
    /// - Parameter data: 리뷰 데이터
    private func showDeleteAlert(data: ReviewListItem) {
        if !data.isWriter {
            self.showReportAlert(reviewID: data.reviewId)
            return
        }
        
        let title = TextLiteral.Review.deleteReview
        let message = TextLiteral.Review.askDeleteReview
        let confirmButtonTitle = TextLiteral.Common.delete
        let cancelButtonTitle = TextLiteral.Common.cancelDark
        
        self.showCustomDialog(
            title: title,
            message: message,
            cancelButtonTitle: cancelButtonTitle,
            confirmButtonTitle: confirmButtonTitle
        ) { [weak self] in
            guard let self = self else { return }
            self.deleteReview(reviewID: data.reviewId)
        }
    }
    
    /// 리뷰 신고 알림 표시
    /// - Parameter reviewID: 신고할 리뷰 ID
    private func showReportAlert(reviewID: Int) {
        showCustomDialog(
            title: TextLiteral.Review.reportReview,
            message: TextLiteral.Review.askReportReview,
            cancelButtonTitle: TextLiteral.Common.cancelDark,
            confirmButtonTitle: TextLiteral.Review.report
        ) { [weak self] in
            let reportViewController = ReportViewController()
            reportViewController.bindData(reviewID: reviewID)
            self?.navigationController?.pushViewController(reportViewController, animated: true)
        }
    }
    
    /// 로그인으로 이동
    private func pushToLoginVC() {
        let loginVC = LoginViewController()
        navigationController?.pushViewController(loginVC, animated: true)
    }
    
    // MARK: - Public Methods
    func setReviewSubmittedSuccessfully() {
        shouldShowSuccessToast = true
    }
    
    /// 메뉴 ID 바인딩
    /// - Parameter id: 메뉴 ID
    func bindMenuID(id: Int) {
        menuID = id
    }
    
    /// 리뷰 작성 버튼 탭 처리 (로그인 체크 포함)
    func userTapReviewButton() {
        if RealmService.shared.isAccessTokenPresent() {
            ReviewAnalyticsManager.shared.logWriteReviewV2(restaurantName: restaurantName)
            DispatchQueue.global().async {
                DispatchQueue.main.async { [self] in
                    if type == "FIXED" {
                        let setRateViewController = SetRateViewController(menuId: menuID)
                        setRateViewController.restaurantName = restaurantName
                        setRateViewController.dataBind(
                            list: menuNameList,
                            idList: menuIDList ?? []
                        )
                        navigationController?.pushViewController(
                            setRateViewController,
                            animated: true
                        )
                    } else {
                        let setRateViewController = SetRateViewController(mealId: menuID)
                        setRateViewController.restaurantName = restaurantName
                        setRateViewController.dataBind(
                            list: validMenusForReview.map { $0.name },
                            idList: validMenusForReview.map { $0.menuId }
                        )
                        navigationController?.pushViewController(
                            setRateViewController,
                            animated: true
                        )
                    }
                }
            }
        } else {
            showAlertControllerWithCancel(
                title: TextLiteral.Common.needLogin,
                message: TextLiteral.Common.askLogin,
                confirmStyle: .default
            ) {
                self.pushToLoginVC()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    /// 메뉴 이름-ID 딕셔너리 생성
    private func makeDictionary() {
        if menuIDList != [] {
            for (index, string) in menuNameList.enumerated() {
                let idValue = menuIDList?[index]
                menuDictionary[string] = idValue
            }
        }
    }
    
    /// Firebase 작업 설정
    private func setFirebaseTask() {
        FirebaseRemoteConfig.shared.fetchRestaurantInfo()
    }
    
    /// 작성 후의 새로고침 함수
    func refreshAllData() {
        getStatistics()
        if type == "VARIABLE" {
            getValidMenusForReview()
        }
        getReviewList(type: type, menuId: menuID)
    }
}

// MARK: - UITableViewDelegate

extension ReviewViewController: UITableViewDelegate {
    
    /// 셀 선택 처리
    func tableView(_: UITableView, didSelectRowAt _: IndexPath) {
        print("cell did touched")
    }
    
    /// 섹션 헤더 높이
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0
        case 1:
            return 6
        case 2:
            return 0
        default:
            return 0
        }
    }
    
    /// 섹션 헤더 뷰
    func tableView(
        _ tableView: UITableView,
        viewForHeaderInSection section: Int
    ) -> UIView? {
        let spacerView = UIView()
        spacerView.backgroundColor = .clear
        return spacerView
    }
    
    /// 셀 높이
    func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 251.adjusted
        case 1:
            return UITableView.automaticDimension
        case 2:
            if reviewList.count == 0 {
                return 300.adjusted
            } else {
                return UITableView.automaticDimension
            }
        default:
            return UITableView.automaticDimension
        }
    }
}

// MARK: - UITableViewDataSource

extension ReviewViewController: UITableViewDataSource {
    
    /// 섹션 개수
    func numberOfSections(in _: UITableView) -> Int {
        return 3
    }
    
    /// 섹션별 행 개수
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return reviewList.count == 0 ? 1 : reviewList.count  // 리뷰 목록 또는 빈 상태
        default:
            return 0
        }
    }
    
    /// 셀 구성
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return configureStatisticsCell(tableView, indexPath: indexPath)
            
        case 1:
            return configureDividerCell(tableView, indexPath: indexPath)
            
        case 2:
            return configureReviewCell(tableView, indexPath: indexPath)
            
        default:
            return UITableViewCell()
        }
    }
    
    // MARK: - Cell Configuration Helpers
    
    /// 통계 셀 구성
    private func configureStatisticsCell(
        _ tableView: UITableView,
        indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ReviewRateViewCell.identifier,
            for: indexPath
        ) as? ReviewRateViewCell ?? ReviewRateViewCell()
        
        cell.selectionStyle = .none
        
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
    }
    
    /// 구분선 셀 구성
    private func configureDividerCell(
        _ tableView: UITableView,
        indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ReviewDividerCell.identifier,
            for: indexPath
        ) as? ReviewDividerCell ?? ReviewDividerCell()
        
        cell.configure(reviewCount: totalReviewCount)
        cell.selectionStyle = .none
        return cell
    }
    
    /// 리뷰 셀 또는 빈 상태 셀 구성
    private func configureReviewCell(
        _ tableView: UITableView,
        indexPath: IndexPath
    ) -> UITableViewCell {
        if reviewList.count == 0 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ReviewEmptyViewCell.identifier,
                for: indexPath
            ) as? ReviewEmptyViewCell ?? ReviewEmptyViewCell()
            
            if RealmService.shared.getToken() == "" {
                cell.configure(isTokenExist: false)
            } else {
                cell.configure(isTokenExist: true)
            }
            cell.selectionStyle = .none
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ReviewTableCell.identifier,
                for: indexPath
            ) as? ReviewTableCell ?? ReviewTableCell()
            
            let reviewItem = reviewList[indexPath.row]
            cell.dataBind(response: reviewItem)

            cell.handler = { [weak self] in
                guard let self else { return }

                reviewList[indexPath.row].isWriter
                ? self.showDeleteAlert(data: reviewList[indexPath.row])
                : self.showReportAlert(reviewID: reviewList[indexPath.row].reviewId)
            }

            cell.configureTranslation(
                state: translationStates[reviewItem.reviewId] ?? .idle,
                isAvailable: isTranslationAvailable
            )

            cell.translationActionHandler = { [weak self] in
                self?.handleTranslationAction(reviewId: reviewItem.reviewId)
            }

            cell.translationInfoHandler = { [weak self] anchorView in
                guard let self else { return }
                TranslationTooltipView.show(in: self.view, from: anchorView)
            }
            
            cell.selectionStyle = .none
            cell.reloadInputViews()
            return cell
        }
    }
}

// MARK: - Network Methods

extension ReviewViewController {
    
    /// 통계 데이터 조회
    func getStatistics() {
        if type == "FIXED" {
            getFixedMenuStatistics()
        } else {
            getMealStatistics()
        }
    }
    
    /// 고정 메뉴 통계 조회
    private func getFixedMenuStatistics() {
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
                self.menuIDList = [self.menuID]
                self.makeDictionary()
                self.reviewTableView.reloadData()
                
            case .failure(let error):
                print("❌ Fixed Menu Statistics Error: \(error.localizedDescription)")
            }
        }
    }
    
    /// 식사 통계 조회
    private func getMealStatistics() {
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
                print("❌ Meal Statistics Error: \(error.localizedDescription)")
                self.reviewTableView.reloadData()
            }
        }
    }
    
    /// 리뷰 작성 가능한 메뉴 목록 조회 (VARIABLE 타입)
    func getValidMenusForReview() {
        NetworkService.shared.request(
            ReviewRouter.getValidMenusForReview(menuID),
            responseType: ReviewValidMenusResponse.self,
            useAuth: true
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.validMenusForReview = data.menuList
                print("✅ Valid Menus for Review: \(data.menuList.map { $0.name })")
                
            case .failure(let error):
                print("❌ Valid Menus Error: \(error.localizedDescription)")
            }
        }
    }
    
    /// 리뷰 목록 조회
    /// - Parameters:
    ///   - type: 메뉴 타입 ("FIXED" 또는 "VARIABLE")
    ///   - menuId: 메뉴/식사 ID
    func getReviewList(type: String, menuId _: Int) {
        if type == "FIXED" {
            getFixedMenuReviewList()
        } else {
            getMealReviewList()
        }
    }
    
    /// 고정 메뉴 리뷰 목록 조회
    private func getFixedMenuReviewList() {
        NetworkService.shared.request(
            ReviewRouter.newReviewList(type, menuID, lastReviewId: nil, page: 0, size: 20),
            responseType: NewReviewListResponse.self,
            useAuth: true
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.reviewList = data.dataList
                self.reviewTableView.reloadData()
                print("✅ Fixed Menu Reviews loaded: \(self.reviewList.count) items")
                
            case .failure(let error):
                print("❌ Fixed Menu Review List Error: \(error.localizedDescription)")
            }
        }
    }
    
    /// 식사 리뷰 목록 조회
    private func getMealReviewList() {
        NetworkService.shared.request(
            ReviewRouter.newReviewList(type, menuID, lastReviewId: nil, page: nil, size: 20),
            responseType: NewReviewListResponse.self,
            useAuth: true
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.reviewList = data.dataList
                self.reviewTableView.reloadData()
                print("✅ Meal Reviews loaded: \(self.reviewList.count) items")
                
            case .failure(let error):
                print("❌ Meal Review List Error: \(error.localizedDescription)")
            }
        }
    }
    
    
    /// 번역하기 / 원문 보기 / 번역 보기 탭 처리
    private func handleTranslationAction(reviewId: Int) {
        switch translationStates[reviewId] ?? .idle {
        case .idle, .failed:
            requestTranslation(reviewId: reviewId)

        case .loading:
            break

        case let .translated(text, showingOriginal):
            // 이미 번역문을 갖고 있으므로 API 재호출 없이 토글만 수행
            translationStates[reviewId] = .translated(text: text, showingOriginal: !showingOriginal)
            reloadReviewRow(reviewId: reviewId)
        }
    }

    /// 리뷰 번역 요청
    private func requestTranslation(reviewId: Int) {
        translationStates[reviewId] = .loading
        reloadReviewRow(reviewId: reviewId)

        let language = AppLanguageManager.shared.currentLanguage.rawValue.uppercased()

        NetworkService.shared.request(
            ReviewRouter.translateReview(reviewId, language: language),
            responseType: ReviewTranslationResponse.self,
            useAuth: true
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                self.translationStates[reviewId] = .translated(text: data.translatedContent, showingOriginal: false)

            case .failure(let error):
                print("❌ Review Translation Error: \(error.localizedDescription)")
                self.translationStates[reviewId] = .failed
            }
            self.reloadReviewRow(reviewId: reviewId)
        }
    }

    /// reviewId에 해당하는 리뷰 셀만 갱신
    private func reloadReviewRow(reviewId: Int) {
        guard let row = reviewList.firstIndex(where: { $0.reviewId == reviewId }) else { return }
        reviewTableView.reloadRows(at: [IndexPath(row: row, section: 2)], with: .none)
    }

    /// 리뷰 삭제
    /// - Parameter reviewID: 삭제할 리뷰 ID
    func deleteReview(reviewID: Int) {
        NetworkService.shared.request(
            ReviewRouter.deleteReview(reviewID),
            responseType: Bool.self,
            useAuth: true
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                print("✅ Review 삭제 성공")
                
                self.getStatistics()
                if self.type == "VARIABLE" {
                    self.getValidMenusForReview()
                }
                self.getReviewList(type: self.type, menuId: self.menuID)
                self.showToast(message: TextLiteral.Review.deleteReviewSuccess)
                
            case let .failure(error):
                print("❌ Delete Review Error: \(error.localizedDescription)")
                self.showToast(message: TextLiteral.Review.deleteReviewFail)
            }
        }
    }
}

// MARK: - ReviewMenuTypeInfoDelegate

extension ReviewViewController: ReviewMenuTypeInfoDelegate {
    
    /// 메뉴 타입 정보 델리게이트
    func didDelegateReviewMenuTypeInfo(for menuTypeData: ReviewMenuTypeInfo) {
        type = menuTypeData.menuType
        menuID = menuTypeData.menuID
        menuIDList = menuTypeData.changeMenuIDList
        restaurantName = menuTypeData.restaurantName
    }
}
