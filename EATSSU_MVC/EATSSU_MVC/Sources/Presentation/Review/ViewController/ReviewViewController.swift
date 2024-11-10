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
    
    let reviewProvider = MoyaProvider<ReviewRouter>(plugins: [MoyaLoggingPlugin()])
    var menuID: Int = Int()
    var type = "VARIABLE"
    private var menuNameList: [String] = []
    private var menuIDList: [Int]? = [Int]()
    private var menuDictionary: [String: Int] = [:]
    private var reviewList = [MenuDataList]()
    private var responseData: ReviewRateResponse?
    private var fixedResponseData: FixedReviewRateResponse?
    
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
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableView()
        initRefresh()
        setFirebaseTask()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getReviewRate()
        getReviewList(type: type, menuId: menuID)
    }
    
    // MARK: - Functions
    
    override func configureUI() {
        reviewTableView.backgroundColor = .white
        view.addSubviews(reviewTableView,
                         activityIndicatorView,
                         noReviewImageView)
    }
    
    override func setLayout() {
        reviewTableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        activityIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        noReviewImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = "리뷰"
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
            self.getReviewRate()
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
                                      preferredStyle: UIAlertController.Style.actionSheet
        )
        
        let fixAction = UIAlertAction(title: "수정하기",
                                      style: .default,
                                      handler: { okAction in
            let setRateViewController = SetRateViewController()
            setRateViewController.dataBindForFix(list: [data.menu], reviewId: data.reviewID)
            setRateViewController.settingForReviewFix(data: data)
            self.navigationController?.pushViewController(setRateViewController, animated: true)
        })
        
        let deleteAction = UIAlertAction(title: "삭제하기",
                                         style: .default,
                                         handler: { okAction in
            self.deleteReview(reviewID: data.reviewID)
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
        let alert = UIAlertController(title: "리뷰 신고하기",
                                      message: "해당 리뷰를 신고하시겠습니까?",
                                      preferredStyle: UIAlertController.Style.alert
        )
        
        let cancelAction = UIAlertAction(title: "취소",
                                         style: .cancel,
                                         handler: nil)
        
        let deleteAction = UIAlertAction(title: "신고",
                                         style: .default,
                                         handler: { okAction in
            let reportViewController = ReportViewController()
            reportViewController.bindData(reviewID: reviewID)
            self.navigationController?.pushViewController(reportViewController, animated: true)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Action Method
    
    //    @objc
    func userTapReviewButton() {
        if RealmService.shared.isAccessTokenPresent() {
            activityIndicatorView.isHidden = false
            DispatchQueue.global().async { // 백그라운드 스레드에서 작업을 수행
                // 작업 완료 후 UI 업데이트를 메인 스레드에서 수행
                DispatchQueue.main.async { [self] in
                    // 고정메뉴인지 판별(메뉴 ID List에 nil값 들어옴)
                    if menuIDList == nil {
                        let setRateViewController = SetRateViewController()
                        menuIDList = [menuID]
                        setRateViewController.dataBind(list: menuNameList,
                                                       idList: menuIDList ?? [],
                                                       reviewList: nil,
                                                       currentPage: 0)
                        self.activityIndicatorView.stopAnimating()
                        self.navigationController?.pushViewController(setRateViewController, animated: true)
                    } else {
                        // 고정메뉴이고, 메뉴가 1개일때 선택창으로 안가고 바로 작성창으로 가도록
                        if menuIDList?.count == 1 {
                            let setRateViewController = SetRateViewController()
                            setRateViewController.dataBind(list: menuNameList,
                                                           idList: menuIDList ?? [],
                                                           reviewList: nil,
                                                           currentPage: 0)
                            self.activityIndicatorView.stopAnimating()
                            self.navigationController?.pushViewController(setRateViewController, animated: true)
                        } else {
                            let choiceMenuViewController = ChoiceMenuViewController()
                            choiceMenuViewController.menuDataBind(menuList: menuNameList, idList: menuIDList ?? [])
                            self.activityIndicatorView.stopAnimating()
                            self.navigationController?.pushViewController(choiceMenuViewController, animated: true)
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("cell did touched")
    }
}

extension ReviewViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            // 두 번째 섹션에서 리뷰 개수가 하나도 없을 때 셀 변경
            if reviewList.count == 0 {
                return 1
            } else {
                return reviewList.count
            }
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: ReviewRateViewCell.identifier, for: indexPath) as? ReviewRateViewCell ?? ReviewRateViewCell()
            cell.selectionStyle = .none
            if self.type == "FIXED" {
                cell.fixMenuDataBind(data: self.fixedResponseData ?? FixedReviewRateResponse(menuName: "",
                                                                                             totalReviewCount: 0,
                                                                                             mainRating: 0,
                                                                                             amountRating: 0,
                                                                                             tasteRating: 0,
                                                                                             reviewRatingCount: StarCount(fiveStarCount: 0,
                                                                                                                          fourStarCount: 0,
                                                                                                                          threeStarCount: 0,
                                                                                                                          twoStarCount: 0,
                                                                                                                          oneStarCount: 0)))
            } else {
                cell.dataBind(data: self.responseData ?? ReviewRateResponse(menuNames: [""],
                                                                            totalReviewCount: 0,
                                                                            mainRating: 0,
                                                                            amountRating: 0,
                                                                            tasteRating: 0,
                                                                            reviewRatingCount: StarCount(fiveStarCount: 0,
                                                                                                         fourStarCount: 0,
                                                                                                         threeStarCount: 0,
                                                                                                         twoStarCount: 0,
                                                                                                         oneStarCount: 0)))
            }
            cell.handler = { [weak self] in
                guard let self else { return }
                userTapReviewButton()
            }
            cell.reloadInputViews()
            return cell
            
        case 1:
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 251.adjusted
        case 1:
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

// MARK: - Server Setting

extension ReviewViewController {
    
    // 상단 메뉴 별점 불러오는 API
    func getReviewRate() {
        self.reviewProvider.request(.reviewRate(type, menuID)) { response in
            switch response {
            case .success(let moyaResponse):
                do {
                    if self.type == "FIXED" {
                        let responseData = try moyaResponse.map(BaseResponse<FixedReviewRateResponse>.self)
                        self.fixedResponseData = responseData.result
                        self.reviewTableView.reloadData()
                        self.menuNameList = [responseData.result.menuName]
                    } else {
                        let responseData = try moyaResponse.map(BaseResponse<ReviewRateResponse>.self)
                        self.responseData = responseData.result
                        self.reviewTableView.reloadData()
                        self.menuNameList = responseData.result.menuNames
                    }
                    self.makeDictionary()
                } catch(let err) {
                    print(err.localizedDescription)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    // 하단 리뷰 리스트 불러오는 API
    func getReviewList(type: String, menuId: Int) {
        self.reviewProvider.request(.reviewList(type, menuID)) { response in
            switch response {
            case .success(let moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<ReviewListResponse>.self)
                    self.reviewList = responseData.result.dataList
                    self.reviewTableView.reloadData()
                } catch(let err) {
                    print(err.localizedDescription)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    func deleteReview(reviewID: Int) {
        self.reviewProvider.request(.deleteReview(reviewID)) { response in
            switch response {
            case .success(_):
                self.getReviewRate()
                self.updateViewConstraints()
                self.getReviewList(type: self.type, menuId: self.menuID)
                self.reviewTableView.showToast(message: "삭제되었어요 !")
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}

extension ReviewViewController: ReviewMenuTypeInfoDelegate {
    func didDelegateReviewMenuTypeInfo(for menuTypeData: ReviewMenuTypeInfo) {
        var reviewMenuTypeInfo = ReviewMenuTypeInfo(menuType: menuTypeData.menuType,
                                                    menuID: menuTypeData.menuID,
                                                    changeMenuIDList: menuTypeData.changeMenuIDList)
        type = reviewMenuTypeInfo.menuType
        menuID = reviewMenuTypeInfo.menuID
        menuIDList = reviewMenuTypeInfo.changeMenuIDList
    }
}
