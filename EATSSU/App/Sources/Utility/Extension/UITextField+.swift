//
//  UITextField+.swift
//  EATSSU
//
//  Created by 최지우 on 2023/04/06.
//

import UIKit

import EATSSUDesign

extension UITextField {
    /// 텍스트 필드의 왼쪽에 기본 크기의 패딩을 추가합니다.
    ///
    /// 텍스트 필드의 왼쪽에 빈 `UIView`를 추가하여 텍스트가 왼쪽에서
    /// 일정 간격을 두고 시작되도록 설정합니다.
    func addLeftPadding() {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: -14, height: -10))
        leftView = paddingView
        leftViewMode = ViewMode.always
    }

    /// 지정된 너비만큼 왼쪽 패딩을 추가합니다.
    ///
    /// - Parameter width: 왼쪽 패딩의 너비 (포인트 단위).
    ///
    /// 이 메서드를 사용하면 원하는 크기의 패딩을 동적으로 설정할 수 있습니다.
    func addLeftPadding(width: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: frame.height))
        leftView = paddingView
        leftViewMode = .always
    }

    /// 지정된 너비만큼 오른쪽 패딩을 추가합니다.
    ///
    /// - Parameter width: 오른쪽 패딩의 너비 (포인트 단위).
    ///
    /// 텍스트 필드의 오른쪽 여백을 설정할 수 있습니다.
    func addRightPadding(width: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: frame.height))
        rightView = paddingView
    }

    /// 텍스트 필드의 왼쪽에 이미지를 추가합니다.
    ///
    /// - Parameter image: 왼쪽에 표시할 `UIImage` 객체.
    ///
    /// 주어진 이미지는 `UIImageView`로 설정되며, 텍스트 필드의 왼쪽에 배치됩니다.
    func addLeftImage(image: UIImage) {
        let leftImage = UIImageView(frame: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
        leftImage.image = image
        leftView = leftImage
        leftViewMode = .always
    }

    /// EATSSU 디자인 시스템을 적용한 텍스트 필드의 테두리를 설정합니다.
    ///
    /// 이 메서드는 다음과 같은 스타일을 적용합니다:
    /// - 테두리 색상: `EATSSUDesignAsset`의 `GrayScale.gray200`
    /// - 테두리 두께: 1.0 pt
    /// - 모서리 둥글기: 10 pt
    func setRoundBorder() {
        layer.masksToBounds = true
        layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray200.color.cgColor
        layer.borderWidth = 1.0
        layer.cornerRadius = 10
    }
}
