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
    case writeNewReview(param: WriteReviewRequest, menuID: Int)
    case writeReview(param: WriteReviewRequest, image: [UIImage?], menuId: Int)
}

extension WriteReviewRouter: TargetType, AccessTokenAuthorizable {
    var baseURL: URL {
        return URL(string: Config.baseURL)!
    }

    var path: String {
        switch self {
        case .writeReview(param: _, image: _, menuId: let menuId):
            return "/reviews/\(menuId)"
        case .uploadImage:
            return "/reviews/upload/image"
        case .writeNewReview(param: _, menuID: let menuId):
            return "/reviews/write/\(menuId)"
        }
    }

    var method: Moya.Method {
        switch self {
        case .writeReview, .uploadImage, .writeNewReview:
            return .post
        }
    }

    var task: Moya.Task {
        switch self {
        case .writeReview(param: let param, image: let imageList, menuId: _):
            var multipartData = [MultipartFormData]()
            do {
                let jsonData = try JSONEncoder().encode(param)
                multipartData.append(MultipartFormData(provider: .data(jsonData),
                                                       name: "createReviewRequest",
                                                       mimeType: "application/json"))
            } catch {
                print("Error encoding ReviewRequest: \(error)")
                return .requestPlain
            }

            for fileData in imageList {
                if let unwrappedImage = fileData {
                    if let imageData = unwrappedImage.resize(newWidth: 300.adjusted).jpegData(compressionQuality: 0.3) {
                        multipartData.append(MultipartFormData(provider: .data(imageData),
                                                               name: "multipartFileList",
                                                               fileName: "image.jpg",
                                                               mimeType: "image/jpeg"))
                    }
                }
            }
            return .uploadMultipart(multipartData)

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

        case let .writeNewReview(param: param, _):
            return .requestJSONEncodable(param)
        }
    }

    var headers: [String: String]? {
        let realm = RealmService()
        let token = realm.getToken()

        switch self {
        case .writeNewReview:
            return ["Content-Type": "application/json",
                    "Authorization": "Bearer \(token)"]
        case .uploadImage, .writeReview:
            return ["Content-Type": "multipart/form-data",
                    "Authorization": "Bearer \(token)"]
        }
    }

    var authorizationType: Moya.AuthorizationType? {
        switch self {
        default:
            return .bearer
        }
    }
}
