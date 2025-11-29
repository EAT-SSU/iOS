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
    override var shouldHideTabBar: Bool { true }
    // MARK: - Properties

    // DTO 변경에 따라 타입 수정: MyDataList -> MyReviewListItem
    private var reviewList = [MyReviewListItem]()
    var nickname: String = .init()
    private var menuName: String = .init()

    // MARK: - UI Components

    let myReviewView = MyReviewView()
    
    init(nickname: String) {
        self.nickname = nickname
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setDelegate()
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
        view.addSubviews(myReviewView)
    }

    override func setLayout() {
        myReviewView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setDelegate() {
        myReviewView.myReviewTableView.register(ReviewTableCell.self, forCellReuseIdentifier: ReviewTableCell.identifier)
        myReviewView.myReviewTableView.register(ReviewEmptyViewCell.self, forCellReuseIdentifier: ReviewEmptyViewCell.identifier)
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
            setRateViewController.dataBindForFix(list: [menuName], reviewId: reviewID)
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

extension MyReviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if reviewList.isEmpty {
            return tableView.bounds.height - 150
        }
        return UITableView.automaticDimension
    }
}

extension MyReviewViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return reviewList.isEmpty ? 1 : reviewList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if reviewList.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: ReviewEmptyViewCell.identifier, for: indexPath) as? ReviewEmptyViewCell ?? ReviewEmptyViewCell()
            cell.configureForMyReview()
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewTableCell.identifier, for: indexPath) as? ReviewTableCell ?? ReviewTableCell()
        
        // DTO에 맞게 데이터 바인딩 로직 수정 필요 (ReviewTableCell의 myPageDataBind 함수도 수정되었다고 가정)
        let reviewItem = reviewList[indexPath.row]
        cell.myPageDataBind(response: reviewItem, nickname: nickname)
        
        cell.handler = { [weak self] in
            guard let self else { return }
            
            // DTO 구조에 맞게 메뉴 이름을 reviewItem.menuList에서 가져옴
            let menuName = reviewItem.menuList.first?.name ?? "알 수 없는 메뉴"
            
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
        NetworkService.shared.request(
            MyRouter.getMyReviewList(lastReviewId: nil, page: 0, size: 20),
            responseType: MyReviewResponseDTO.self,
            useAuth: true
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                self.reviewList = response.result.dataList
                self.myReviewView.myReviewTableView.reloadData()
                
            case .failure(let error):
                print("내 리뷰 조회 실패: \(error.localizedDescription)")
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
            guard let self = self else { return }
            
            NetworkService.shared.request(
                ReviewRouter.deleteReview(reviewID),
                responseType: Bool.self,
                useAuth: true
            ) { result in
                switch result {
                case .success:
                    self.getMyReview()
                case .failure(let error):
                    print("리뷰 삭제 실패: \(error.localizedDescription)")
                    RealmService.shared.resetDB()
                    self.navigateToLogin()
                }
            }
        }
    }
}
