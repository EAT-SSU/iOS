//
//  MyPageServiceCell.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/25.
//

import UIKit

final class MyPageServiceCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "MyPageServiceCell"
    
    // MARK: - UI Components
    
    var serviceLabel = UILabel().then {
      $0.font = EATSSUFontFamily.Pretendard.medium.font(size: 16)
      $0.textColor = .black
    }
    
    var rightItemLabel = UILabel().then {
      $0.font = EATSSUFontFamily.Pretendard.regular.font(size: 16)
        $0.textColor = .gray700
    }
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    // MARK: - Functions
    
    func configureUI() {
        self.addSubviews(
          serviceLabel,
          rightItemLabel
        )
    }
    
    func setLayout() {
        serviceLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        rightItemLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }
}
