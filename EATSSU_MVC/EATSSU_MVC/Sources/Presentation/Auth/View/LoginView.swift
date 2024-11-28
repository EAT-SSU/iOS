//
//  LoginView.swift
//  iOS
//
//  Created by 최지우 on 2023/06/26.
//

import UIKit

import SnapKit
import Then

import EATSSUDesign

final class LoginView: BaseUIView {
    // MARK: - UI Components
    
    private let logoImage = UIImageView().then {
        $0.image = EATSSUAsset.Images.Version2.authLogo.image
    }
    
    private let logoSubTitle = UIImageView().then { imageView in
        imageView.image = EATSSUAsset.Images.Version2.authSubTitle.image
    }
    
    let appleLoginButton = UIButton().then { button in
        button.setImage(EATSSUAsset.Images.Version2.appleLoginButton.image, for: .normal)
    }
    
    let kakaoLoginButton = UIButton().then { button in
        button.setImage(EATSSUAsset.Images.Version2.kakaoLoginButton.image, for: .normal)
    }
    
    let lookingWithNoSignInButton = UIButton().then { button in
        button.setImage(EATSSUAsset.Images.Version2.lookAroundButton.image, for: .normal)
    }
    
    override func configureUI() {
        addSubviews(
            logoImage,
            logoSubTitle,
            appleLoginButton,
            kakaoLoginButton,
            lookingWithNoSignInButton
        )
    }
    
    override func setLayout() {
        logoImage.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(223)
        }
        
        logoSubTitle.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImage.snp.bottom)
        }
        
        appleLoginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(151)
        }
        
        kakaoLoginButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(90)
        }
        
        lookingWithNoSignInButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.safeAreaLayoutGuide).inset(30)
        }
    }
}

/*
@objc
   private func rightBarButtonTapped() {
       if RealmService.shared.isAccessTokenPresent() {
           let nextVC = MyPageViewController()
           self.navigationController?.pushViewController(nextVC, animated: true)
       } else {
//            showAlertControllerWithCancel(title: "로그인이 필요한 서비스입니다", message: "로그인 하시겠습니까?", confirmStyle: .default) {
//                self.changeIntoLoginViewController()
//            }
           
           let modalVC = LoginPromptViewController()
           modalVC.modalPresentationStyle = .pageSheet
           
           // Check if UISheetPresentationController is available (iOS 15+)
           if let sheet = modalVC.sheetPresentationController {
               let small = UISheetPresentationController.Detent.Identifier("small")
//                let smallDetent = UISheetPresentationController.Detent.custom(identifier: smallId) { context in
//                    return 270
//                }
//                sheet.detents = [smallDetent]
               sheet.detents = [
                   .custom(identifier: small) { context in
                       0.3 * context.maximumDetentValue
                   }
               ]
               
//                sheet.prefersGrabberVisible = true
               sheet.prefersScrollingExpandsWhenScrolledToEdge = false
               sheet.preferredCornerRadius = 30
           }
           present(modalVC, animated: true, completion: nil)
           
       }
   }
*/
