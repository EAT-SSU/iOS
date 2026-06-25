//
//  CustomRadioButton.swift
//  EATSSU
//
//  Created by jeongminji on 5/3/26.
//

import UIKit

import EATSSUDesign

final class CustomRadioButton: UIButton {
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        updateState(isSelected: false)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = bounds.width / 2
    }
    
    // MARK: - Function
    
    private func configureUI() {
        backgroundColor = .clear
        layer.borderWidth = 2
        layer.borderColor = UIColor.gray400.cgColor
    }
    
    func updateState(isSelected: Bool) {
        self.isSelected = isSelected
        
        layer.borderWidth = isSelected ? 6 : 2
        layer.borderColor = isSelected
            ? UIColor.primary.cgColor
            : UIColor.gray400.cgColor
        
        backgroundColor = .clear
        setNeedsLayout()
    }
}
