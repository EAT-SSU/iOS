//
//  MyReviewViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/27.
//

import UIKit

import Moya
import SnapKit
import FirebaseAnalytics

final class MyReviewViewController: BaseViewController {
    // MARK: - Properties

    private let myProvider = MoyaProvider<MyRouter>(session: Session(interceptor: AuthInterceptor.shared))
    private let reviewProvider = MoyaProvider<ReviewRouter>(session: Session(interceptor: AuthInterceptor.shared))

    private var reviewList = [MyDataList]()
    var nickname: String = .init()
    private var menuName: String = .init()

    // MARK: - UI Components

    let myReviewView = MyReviewView()
    
    init(nickname: String) {
        self.nickname = nickname
        super.init(nibName: nil, bundle: nil)
    }

    private lazy var noMyReviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImageLiteral.noMyReview
        imageView.isHidden = true
        return imageView
    }()

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setDelegate()
        checkReviewCount()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        logScreenView(screenID: FirebaseScreenID.MyPage.mypage3)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        getMyReview()
    }

    // MARK: - Functions

    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = TextLiteral.MyPage.myReview
    }

    override func configureUI() {
        view.addSubviews(myReviewView, noMyReviewImageView)
    }

    override func setLayout() {
        myReviewView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        noMyReviewImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func setDelegate() {
        myReviewView.myReviewTableView.register(ReviewTableCell.self, forCellReuseIdentifier: ReviewTableCell.identifier)
        myReviewView.myReviewTableView.delegate = self
        myReviewView.myReviewTableView.dataSource = self
    }

    func dataBind(nickname: String) {
        self.nickname = nickname
    }

    private func showFixOrDeleteAlert(reviewID: Int, menuName: String) {
        let alert = UIAlertController(title: "리뷰 수정 혹은 삭제",
                                      message: "작성하신 리뷰를 수정 또는 삭제하시겠습니까?",
                                      preferredStyle: UIAlertController.Style.actionSheet)

        let fixAction = UIAlertAction(title: "수정하기",
                                      style: .default,
                                      handler: { _ in
                                          let setRateViewController = SetRateViewController()
                                          setRateViewController.dataBindForFix(list: [menuName], reivewId: reviewID)
                                          self.navigationController?.pushViewController(setRateViewController, animated: true)
                                      })

        let deleteAction = UIAlertAction(title: "삭제하기",
                                         style: .default,
                                         handler: { _ in
                                             self.deleteReview(reviewID: reviewID)
                                         })

        let cancelAction = UIAlertAction(title: "취소하기",
                                         style: .cancel,
                                         handler: nil)

        alert.addAction(fixAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }

    func checkReviewCount() {
        if reviewList.count == 0 {
            myReviewView.myReviewTableView.isHidden = true
            noMyReviewImageView.isHidden = false
        } else {
            myReviewView.myReviewTableView.isHidden = false
            noMyReviewImageView.isHidden = true
        }
    }
    
    private func navigateToLogin() {
        let loginVC = LoginViewController()
        loginVC.toastMessage = "세션이 만료되었습니다. 다시 로그인해주세요."
        loginVC.toastType = .info
        
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.replaceRootViewController(UINavigationController(rootViewController: loginVC))
            }
        }
    }
}

extension MyReviewViewController: UITableViewDelegate {}

extension MyReviewViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        reviewList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewTableCell.identifier, for: indexPath) as? ReviewTableCell ?? ReviewTableCell()
        cell.myPageDataBind(response: reviewList[indexPath.row], nickname: nickname)
        cell.handler = { [weak self] in
            guard let self else { return }
            menuName = reviewList[indexPath.row].menuName
            showFixOrDeleteAlert(reviewID: cell.reviewId,
                                 menuName: menuName)
        }
        cell.selectionStyle = .none
        return cell
    }
}

// MARK: - Server

extension MyReviewViewController {
    private func getMyReview() {
        myProvider.request(.myReview) { response in
            switch response {
            case let .success(moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<MyReviewResponse>.self)
                    guard let data = responseData.result else { return }
                    self.reviewList = data.dataList
                    self.checkReviewCount()
                    self.myReviewView.myReviewTableView.reloadData()
                } catch let err {
                    print(err.localizedDescription)
                    
                    RealmService.shared.resetDB()
                    self.navigateToLogin()
                }
            case let .failure(err):
                print(err.localizedDescription)
                
                RealmService.shared.resetDB()
                self.navigateToLogin()
            }
        }
    }
    
    // 리뷰 삭제 알람 추가
    func deleteReview(reviewID: Int) {
        showCustomDialog(
            title: "리뷰 삭제하기",
            message: "해당 리뷰를 삭제할까요?",
            cancelButtonTitle: "취소하기",
            confirmButtonTitle: "삭제하기"
        ) { [weak self] in
            // '삭제하기' 버튼을 눌렀을 때 실행될 네트워크 요청
            guard let self = self else { return }
            self.reviewProvider.request(.deleteReview(reviewID)) { response in
                switch response {
                case .success:
                    self.getMyReview()
                case let .failure(err):
                    print(err.localizedDescription)
                    RealmService.shared.resetDB()
                    self.navigateToLogin()
                }
            }
        }
    }
}
