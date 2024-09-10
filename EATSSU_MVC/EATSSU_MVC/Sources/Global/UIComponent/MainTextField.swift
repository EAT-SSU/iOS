//
//  MainTextField.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/04/04.
//

import UIKit

import SnapKit
import Then

class MainTextField: UITextField {
    
    private enum Size {
        static let width: CGFloat = 358.0
        static let height: CGFloat = 40.0
    }
    
    // MARK: -properties
    
    var placeHolder: String?
    
    // MARK: -init
    
    init(_ placeHolder: String?) {
        self.placeHolder = placeHolder
        super.init(frame: .zero)
        configureUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - func
    
    func configureUI() {
        layer.cornerRadius = 10
        layer.borderColor = UIColor.primary.cgColor
        layer.borderWidth = 1.0
        placeholder = placeHolder
        leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 10.0, height: 0.0))
        leftViewMode = .always
        font = UIFont.regular(size: 16.0)
    }
    
    func setLayout() {
        self.snp.makeConstraints {
            $0.width.equalTo(Size.width)
            $0.height.equalTo(Size.height)
        }
    }
    
}
