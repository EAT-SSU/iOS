//
//  MyReviewViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/27.
//

import UIKit

import Moya
import SnapKit
import Then

final class MyReviewViewController: BaseViewController {
	// MARK: - Properties
	
	private var myReviewModel = MyReviewModel()
    
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
        
		myReviewModel.getMyReview {
			self.checkReviewCount()
			self.myReviewView.myReviewTableView.reloadData()
		}
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
		myReviewView.myReviewTableView.dataSource = self
	}
    
	private func showFixOrDeleteAlert(reviewID: Int, menuName: String) {
		let alert = UIAlertController(title: "리뷰 수정 혹은 삭제",
		                              message: "작성하신 리뷰를 수정 또는 삭제하시겠습니까?",
		                              preferredStyle: UIAlertController.Style.actionSheet)
		
		let fixAction = UIAlertAction(title: "수정하기", style: .default) { _ in
			let setRateViewController = SetRateViewController()
			setRateViewController.dataBindForFix(list: [menuName], reviewId: reviewID)
			self.navigationController?.pushViewController(setRateViewController, animated: true)
		}
        
		let deleteAction = UIAlertAction(title: "삭제하기",
		                                 style: .default)
		{ _ in
			self.myReviewModel.deleteReview(reviewID: reviewID) {
				self.myReviewModel.getMyReview {
					self.checkReviewCount()
					self.myReviewView.myReviewTableView.reloadData()
				}
				self.view.showToast(message: "삭제되었어요!")
			}
		}
		
		let cancelAction = UIAlertAction(title: "취소하기",
		                                 style: .cancel,
		                                 handler: nil)
        
		alert.addAction(fixAction)
		alert.addAction(deleteAction)
		alert.addAction(cancelAction)
		present(alert, animated: true, completion: nil)
	}
    
	private func checkReviewCount() {
		if myReviewModel.reviewList.count == 0 {
			myReviewView.myReviewTableView.isHidden = true
			noMyReviewImageView.isHidden = false
		} else {
			myReviewView.myReviewTableView.isHidden = false
			noMyReviewImageView.isHidden = true
		}
	}
}

extension MyReviewViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return myReviewModel.reviewList.count
	}
    
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let myReviewCell = tableView.dequeueReusableCell(withIdentifier: ReviewTableCell.identifier, for: indexPath) as? ReviewTableCell ?? ReviewTableCell()
		myReviewCell.myPageDataBind(response: myReviewModel.reviewList[indexPath.row], nickname: myReviewModel.nickName)
		myReviewCell.handler = { [weak self] in
			guard let self else { return }
			myReviewModel.menuName = myReviewModel.reviewList[indexPath.row].menuName
			showFixOrDeleteAlert(reviewID: myReviewCell.reviewId,
								 menuName: myReviewModel.menuName)
		}
		
		myReviewCell.selectionStyle = .none
		return myReviewCell
	}
}
