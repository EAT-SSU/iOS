//
//  MyReviewViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/27.
//

import UIKit

import SnapKit
import Then
import Moya

final class MyReviewViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let myProvider = MoyaProvider<MyRouter>(plugins: [MoyaLoggingPlugin()])
    private let reviewProvider = MoyaProvider<ReviewRouter>(plugins: [MoyaLoggingPlugin()])

    private var reviewList = [MyDataList]()
    var nickname: String = String()
    private var menuName: String = String()
    
    // MARK: - UI Components
    
    let myReviewView = MyReviewView()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getMyReview()
    }
    
    // MARK: - Functions
    
    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = TextLiteral.myReview
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
    
    func dataBind(nikcname: String) {
        self.nickname = nikcname
    }
    
    private func showFixOrDeleteAlert(reviewID: Int, menuName: String) {
        let alert = UIAlertController(title: "리뷰 수정 혹은 삭제",
                                      message: "작성하신 리뷰를 수정 또는 삭제하시겠습니까?",
                                      preferredStyle: UIAlertController.Style.actionSheet
        )
        
        let fixAction = UIAlertAction(title: "수정하기",
                                      style: .default,
                                      handler: { fixAction in
            let setRateViewController = SetRateViewController()
            setRateViewController.dataBindForFix(list: [menuName], reivewId: reviewID)
            self.navigationController?.pushViewController(setRateViewController, animated: true)
        })
        
        let deleteAction = UIAlertAction(title: "삭제하기",
                                      style: .default,
                                      handler: { deleteAction in
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
}

extension MyReviewViewController: UITableViewDelegate {}

extension MyReviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviewList.count
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
        self.myProvider.request(.myReview) { response in
            switch response {
            case .success(let moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<MyReviewResponse>.self)
                    self.reviewList = responseData.result.dataList
                    self.checkReviewCount()
                    self.myReviewView.myReviewTableView.reloadData()
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
                self.getMyReview()
                self.view.showToast(message: "삭제되었어요 !")
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}
