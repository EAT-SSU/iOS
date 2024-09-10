//
//  MainButton.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/04/03.
//

import UIKit

import SnapKit
import Then

class MainButton: UIButton {
    
    private enum Size {
        static let height: CGFloat = 48.adjusted
    }
    
    // MARK: - property
    
    var title: String? {
        didSet {
            setupTitleAttribute()
        }
    }
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - func
    
    func configureUI() {
        titleLabel?.font = .button1
        titleLabel?.textColor = .white
        backgroundColor = EATSSUAsset.Color.Main.primary.color
        layer.cornerRadius = 10
    }
    
    func setLayout() {
        self.snp.makeConstraints {
            $0.height.equalTo(Size.height)
        }
    }
    
    func setupTitleAttribute() {
        if let buttonTitle = title {
            setTitle(buttonTitle, for: .normal)
        }
    }
}
