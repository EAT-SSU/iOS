//
//  ESTextField.swift
//  EATSSUComponents
//
//  Created by Jiwoong CHOI on 8/29/24.
//

import Foundation
import UIKit

import SnapKit

/*
 해야 할 일
 - enumeration들을 Namespace라는 폴더로 따로 정리하는 방법은 어떨까?
 */
public enum TextFieldStatus {
    case pass
    case error
}

final public class ESTextField: UITextField {
    
    // MARK: - Properties
    
    private enum Size {
        static let height: CGFloat = 52.adjusted
    }

    private var guide: String
    private var status: TextFieldStatus {
        didSet {
            self.changeTextFieldStatus(status: status)
        }
    }
    
    // MARK: - Intializer
    
    public init(placeholder: String) {
      self.guide = placeholder
      self.status = .pass
      
      super.init(frame: .zero)
      self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
  // MARK: - Functions

    override public func didMoveToSuperview() {
      self.setLayout()
    }
    
    private func configureUI() {
        self.placeholder = guide
        self.font = .body2
        self.textColor = .gray700
        self.backgroundColor = .gray100
        self.setRoundBorder()
        self.setPlaceholderColor()
        self.addLeftPadding(width: 12.adjusted)
    }
    
    private func setLayout() {
        self.snp.makeConstraints {
            $0.height.equalTo(Size.height)
        }
    }
    
    private func changeTextFieldStatus(status: TextFieldStatus) {
        switch status {
        case .pass:
          self.layer.borderColor = EATSSUComponentsAsset.Colors.GrayScaleColor.gray300.color.cgColor
        case .error:
          self.layer.borderColor = EATSSUComponentsAsset.Colors.RedColor.error.color.cgColor
        }
    }
}
