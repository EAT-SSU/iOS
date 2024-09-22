//
//  ImageLiteral.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/04/07.
//

import UIKit

// TODO: Tuist가 이미지 리터럴 코드를 생성해주기 때문에 해당 이미지 리터럴 코드를 제거
// FIXME: 아직 코드에서 사용하고 있는 ImageLiteral 코드들을 전부 tuist 생성 코드로 변경

enum ImageLiteral {
    
    // MARK: - logo
    
    static var splashLogo: UIImage { .load(name: "version1/splashLogo")}
    static var EatSSULogo: UIImage { .load(name: "version1/EatSSULogo")}
    
    // MARK: - sign in
    
    static var appleLoginButton: UIImage { .load(name: "version1/appleLoginButton")}
    static var kakaoLoginButton: UIImage { .load(name: "version1/kakaoLoginButton")}
    static var signInImage: UIImage { .load(name: "version1/signInImage")}
    static var lookingButton: UIImage { .load(name: "version1/lookingButton")}
    
    // MARK: - icon
    
    static var menuIcon: UIImage { .load(name: "version1/menuIcon")}
    static var checkedIcon: UIImage {.load(name: "version1/checkedIcon")}
    static var uncheckedIcon: UIImage {.load(name: "version1/uncheckedIcon")}
    static var coordinate: UIImage {.load(name: "version1/coordinate")}
    static var myPageIcon: UIImage {.load(name: "version1/myPageIcon")}
    static var profileIcon: UIImage {.load(name: "version1/profileIcon")}
    static var signInWithKakao: UIImage {.load(name: "version1/signInWithKakao")}
    static var signInWithApple: UIImage {.load(name: "version1/signInWithApple")}
    
    // MARK: - My

    static var greySideButton: UIImage { .load(name: "version1/greySideButton")}
    
    //MARK: - Review
    
    static var noReview: UIImage { .load(name: "version1/noReview")}
    static var noMyReview: UIImage { .load(name: "version1/noMyReview")}
    static var pleaseLogin: UIImage { .load(name: "version1/pleaseLogin")}
}

extension UIImage {
    static func load(name: String) -> UIImage {
        guard let image = UIImage(named: name, in: nil, compatibleWith: nil) else {
            return UIImage()
        }
        return image
    }
    
    static func load(systemName: String) -> UIImage {
        guard let image = UIImage(systemName: systemName, compatibleWith: nil) else {
            return UIImage()
        }
        return image
    }
}
