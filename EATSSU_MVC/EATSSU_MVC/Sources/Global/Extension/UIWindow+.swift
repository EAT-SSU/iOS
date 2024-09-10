//
//  UIWindow+.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/10/04.
//

import UIKit

extension UIWindow {
  
  /// Window의 RootViewController에 접근해서 전환하는 메소드입니다.
  func replaceRootViewController(_ replacementController: UIViewController) {
    UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
      self.rootViewController = replacementController
    }
  }
}
