//
//  MyReviewViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/27.
//

import UIKit

import Moya
import SnapKit

final class MyReviewViewController: BaseViewController {
    override var shouldHideTabBar: Bool { true }
    
    // MARK: - Properties

    private var reviewList = [MyReviewListItem]()
    var nickname: String = .init()

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
        view.backgroundColor = .white
        view.addSubviews(myReviewView)
    }

    override func setLayout() {
        myReviewView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setDelegate() {
        myReviewView.myReviewTableView.register(
            ReviewTableCell.self,
            forCellReuseIdentifier: ReviewTableCell.identifier
        )
        myReviewView.myReviewTableView.register(
            ReviewEmptyViewCell.self,
            forCellReuseIdentifier: ReviewEmptyViewCell.identifier
        )
        myReviewView.myReviewTableView.delegate = self
        myReviewView.myReviewTableView.dataSource = self
    }

    func dataBind(nickname: String) {
        self.nickname = nickname
    }

    private func showFixOrDeleteAlert(reviewID: Int, reviewItem: MyReviewListItem) {
        let alert = UIAlertController(
            title: TextLiteral.MyPage.fixOrDeleteReview,
            message: TextLiteral.MyPage.askFixOrDeleteReview,
            preferredStyle: UIAlertController.Style.actionSheet
        )

        let fixAction = UIAlertAction(
            title: TextLiteral.Common.fix,
            style: .default,
            handler: { _ in
                let setRateViewController = SetRateViewController()
                
                // ✅ 모든 메뉴 정보 전달
                let menuNames = reviewItem.menuList.map { $0.name }
                let menuIds = reviewItem.menuList.map { $0.id }
                let likedMenuIds = reviewItem.menuList.filter { $0.isLike }.map { $0.id }
                
                setRateViewController.dataBindForFix(
                    list: menuNames,
                    reviewId: reviewID,
                    rating: reviewItem.rating,
                    content: reviewItem.content,
                    imageUrls: reviewItem.imageUrls,
                    menuIds: menuIds,
                    likedMenuIds: likedMenuIds
                )
                
                self.navigationController?.pushViewController(setRateViewController, animated: true)
            }
        )

        let deleteAction = UIAlertAction(
            title: TextLiteral.Common.delete,
            style: .default,
            handler: { _ in
                self.deleteReview(reviewID: reviewID)
            }
        )

        let cancelAction = UIAlertAction(
            title: TextLiteral.Common.cancelDark,
            style: .cancel,
            handler: nil
        )

        alert.addAction(fixAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func navigateToLogin() {
        let loginVC = LoginViewController()
        loginVC.toastMessage = TextLiteral.Common.sessionExpired
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
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ReviewEmptyViewCell.identifier,
                for: indexPath
            ) as? ReviewEmptyViewCell ?? ReviewEmptyViewCell()
            cell.configureForMyReview()
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ReviewTableCell.identifier,
            for: indexPath
        ) as? ReviewTableCell ?? ReviewTableCell()
        
        let reviewItem = reviewList[indexPath.row]
        cell.myPageDataBind(response: reviewItem, nickname: nickname)
        
        cell.handler = { [weak self] in
            guard let self else { return }
            
            // ✅ reviewItem 전체를 전달
            self.showFixOrDeleteAlert(
                reviewID: reviewItem.reviewId,
                reviewItem: reviewItem
            )
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
                self.reviewList = response.dataList
                self.myReviewView.myReviewTableView.reloadData()
                
                // 빈 상태 이미지 표시 여부
                self.myReviewView.noReviewImageView.isHidden = !self.reviewList.isEmpty
                
            case .failure(let error):
                print("내 리뷰 조회 실패: \(error.localizedDescription)")
                RealmService.shared.resetDB()
                self.navigateToLogin()
            }
        }
    }
    
    func deleteReview(reviewID: Int) {
        showCustomDialog(
            title: TextLiteral.MyPage.deleteMyReview,
            message: TextLiteral.MyPage.askDeleteMyReview,
            cancelButtonTitle: TextLiteral.Common.cancelDark,
            confirmButtonTitle: TextLiteral.Common.delete
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
                    self.showToast(message: TextLiteral.MyPage.deleteMyReviewSuccess)
                case .failure(let error):
                    print("리뷰 삭제 실패: \(error.localizedDescription)")
                    RealmService.shared.resetDB()
                    self.navigateToLogin()
                }
            }
        }
    }
}
