//
//  MyPageTableDefaultCell.swift
//  EATSSU_MVC
//
//  Created by Jiwoong CHOI on 9/19/24.
//

import UIKit

import SnapKit

import EATSSUDesign

final class MyPageTableDefaultCell: UITableViewCell {
    // MARK: - Properties
    
    static let identifier = "MyPageTableDefaultCell"
    
    // MARK: - UI Components
    
    let serviceLabel: UILabel = {
        let label = UILabel()
        label.font = .body1
        label.textColor = .black
        return label
    }()
    
    private let rightTextLabel: UILabel = {
        let label = UILabel()
        label.font = .body2
        label.textColor = .gray600
        label.textAlignment = .right
        return label
    }()
    
    let rigthChevronImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .gray300
        return imageView
    }()
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    private func configureUI() {
        addSubviews(
            serviceLabel,
            rightTextLabel,
            rigthChevronImage
        )
    }
    
    private func setLayout() {
        serviceLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(24)
            $0.centerY.equalToSuperview()
        }
        rightTextLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(46)
            $0.centerY.equalToSuperview()
        }
        rigthChevronImage.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.centerY.equalToSuperview()
        }
    }
    
    /// 마이페이지 메뉴 셀 설정
    /// - MyPageLabels enum을 그대로 받아서 title, rightText, disclosure 표시 여부를 설정합니다.
    /// - MyPageViewController에서 사용하는 기본 설정 함수입니다.
    func configure(with item: MyPageLabels) {
        serviceLabel.text = item.title
        
        if let rightText = item.rightText {
            rightTextLabel.text = rightText
            rightTextLabel.isHidden = false
        } else {
            rightTextLabel.text = nil
            rightTextLabel.isHidden = true
        }
        
        rigthChevronImage.isHidden = !item.showsDisclosure
    }
    
    /// 일반 텍스트 기반 셀 설정
    /// - Parameters:
    ///   - title: 왼쪽에 표시할 메인 텍스트
    ///   - rightText: 오른쪽에 표시할 보조 텍스트. nil이면 숨김 처리됩니다.
    ///   - showsDisclosure: 오른쪽 chevron 표시 여부
    func configure(
        title: String,
        rightText: String? = nil,
        showsDisclosure: Bool = true
    ) {
        serviceLabel.text = title

        if let rightText {
            rightTextLabel.text = rightText
            rightTextLabel.isHidden = false
        } else {
            rightTextLabel.text = nil
            rightTextLabel.isHidden = true
        }

        rigthChevronImage.isHidden = !showsDisclosure
    }
}
