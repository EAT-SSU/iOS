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
//    case writeNewReview(param: WriteReviewRequest, menuID: Int)
//    case writeReview(param: WriteReviewRequest, image: [UIImage?], menuId: Int)
    
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
//        case .writeReview(param: _, image: _, menuId: let menuId):
//            "/reviews/\(menuId)"
        case .uploadImage:
            "/reviews/upload/image"
//        case .writeNewReview(param: _, menuID: let menuId):
//            "/reviews/write/\(menuId)"
            
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
        case /*.writeReview,*/ .uploadImage, /*.writeNewReview,*/ .writeMenuReview, .writeMealReview:
            .post
        case .fixReview:
                    .patch
        }
    }

    var task: Moya.Task {
        switch self {
//        case .writeReview(param: let param, image: let imageList, menuId: _):
//            var multipartData = [MultipartFormData]()
//            do {
//                let jsonData = try JSONEncoder().encode(param)
//                multipartData.append(MultipartFormData(provider: .data(jsonData),
//                                                       name: "createReviewRequest",
//                                                       mimeType: "application/json"))
//            } catch {
//                print("Error encoding ReviewRequest: \(error)")
//                return .requestPlain
//            }
//
//            for fileData in imageList {
//                if let unwrappedImage = fileData {
//                    if let imageData = unwrappedImage.resize(newWidth: 300.adjusted).jpegData(compressionQuality: 0.3) {
//                        multipartData.append(MultipartFormData(provider: .data(imageData),
//                                                               name: "multipartFileList",
//                                                               fileName: "image.jpg",
//                                                               mimeType: "image/jpeg"))
//                    }
//                }
//            }
//            return .uploadMultipart(multipartData)

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

//        case let .writeNewReview(param: param, _):
//            return .requestJSONEncodable(param)
            
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
        case /*.writeNewReview,*/ .writeMenuReview, .writeMealReview, .fixReview:
            return ["Content-Type": "application/json"]
        case .uploadImage/*, .writeReview*/:
            return ["Content-Type": "multipart/form-data"]
        }
    }
}

extension WriteReviewRouter {
    var validationType: ValidationType {
        .successCodes
    }
}
