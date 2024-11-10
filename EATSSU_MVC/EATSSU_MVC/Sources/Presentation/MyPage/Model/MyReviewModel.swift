//
//  MyReviewModel.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 11/10/24.
//

import Foundation

import Moya

final class MyReviewModel {
	private let myProvider = MoyaProvider<MyRouter>(plugins: [MoyaLoggingPlugin()])
	private let reviewProvider = MoyaProvider<ReviewRouter>(plugins: [MoyaLoggingPlugin()])

	var reviewList = [MyDataList]()
	var nickName = ""
	var menuName = ""

	func getMyReview(completion: @escaping () -> Void) {
		self.myProvider.request(.myReview) { response in
			switch response {
			case .success(let moyaResponse):
				do {
					let responseData = try moyaResponse.map(BaseResponse<MyReviewResponse>.self)
					self.reviewList = responseData.result.dataList
					completion()
				} catch (let err) {
					print(err.localizedDescription)
				}
			case .failure(let err):
				print(err.localizedDescription)
			}
		}
	}

	func deleteReview(reviewID: Int, completion: @escaping () -> Void) {
		self.reviewProvider.request(.deleteReview(reviewID)) { response in
			switch response {
			case .success:
				completion()
			case .failure(let err):
				print(err.localizedDescription)
			}
		}
	}
}
