//
//  WriteReviewRouter.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/05/30.
//

import UIKit

import Moya

enum WriteReviewRouter {
    case uploadImage(image: UIImage?)
    // MARK: - New V2 APIs
    case writeMenuReview(param: WriteReviewMenuRequest)
    case writeMealReview(param: WriteReviewMealRequest)
    case fixReview(reviewId: Int, param: FixedReviewRequestDTO)
}

extension WriteReviewRouter: TargetType {
    var baseURL: URL {
        URL(string: Config.baseURL)!
    }
    
    var path: String {
        switch self {
        case .uploadImage:
            "/reviews/upload/image"
            // MARK: - New V2 Paths
        case .writeMenuReview:
            "/v2/reviews/menu"
        case .writeMealReview:
            "/v2/reviews/meal"
        case .fixReview(reviewId: let reviewId, param: _):
            "/v2/reviews/\(reviewId)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .uploadImage, .writeMenuReview, .writeMealReview:
                .post
        case .fixReview:
                .patch
        }
    }
    
    var task: Moya.Task {
        switch self {
        case let .uploadImage(image: image):
            var multipartData = [MultipartFormData]()
            guard let unwrappedImage = image else { return .requestPlain }
            if let imageData = unwrappedImage.resize(newWidth: 300.adjusted).jpegData(compressionQuality: 0.3) {
                multipartData.append(MultipartFormData(provider: .data(imageData),
                                                       name: "image",
                                                       fileName: "image.jpeg",
                                                       mimeType: "image/jpeg"))
            }
            return .uploadMultipart(multipartData)
            
            // MARK: - New V2 Tasks (JSON Encoded)
        case let .writeMenuReview(param: param):
            return .requestJSONEncodable(param)
        case let .writeMealReview(param: param):
            return .requestJSONEncodable(param)
        case let .fixReview(reviewId: _, param: param):
            return .requestJSONEncodable(param)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .writeMenuReview, .writeMealReview, .fixReview:
            return ["Content-Type": "application/json"]
        case .uploadImage:
            return ["Content-Type": "multipart/form-data"]
        }
    }
}

extension WriteReviewRouter {
    var validationType: ValidationType {
        .successCodes
    }
}
