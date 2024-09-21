//
//  RequestView.swift
//  EAT-SSU
//
//  Created by 박윤빈 on 2023/12/27.
//

import UIKit

import SnapKit
import Then

final class RequestView: BaseUIView {
    
    // MARK: - UI Component

    private let requestLabel = UILabel()
    private let emailLabel = UILabel()
    var emailTextField = UITextField()
    private let requestContentLabel = UILabel()
    var contentTextView = UITextView()
    var maximumTextCountLabel = UILabel()
    var sendButton = PostUIButton()
    private lazy var emailStackView = UIStackView(arrangedSubviews: [emailLabel,
                                                                     emailTextField])
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    override func configureUI() {
        super.configureUI()
        self.addSubviews(requestLabel,
                         emailStackView,
                         requestContentLabel,
                         contentTextView,
                         maximumTextCountLabel,
                         sendButton)
        
        requestLabel.do {
            $0.text = TextLiteral.request
            $0.font = .bold(size: 16.adjusted)
            $0.textColor = .black
        }
        
        emailLabel.do {
            $0.text = TextLiteral.email
            $0.font = .medium(size: 16.adjusted)
            $0.textColor = .black
        }
        
        emailTextField.do {
            $0.placeholder = TextLiteral.inputEmail
            $0.font = .medium(size: 14.adjusted)
            $0.textColor = .black
            $0.layer.masksToBounds = true
            $0.layer.borderWidth = 1.0
            $0.layer.cornerRadius = 10
            $0.layer.borderColor = UIColor.gray200.cgColor
            $0.addLeftPadding()
        }
        
        requestContentLabel.do {
            $0.text = TextLiteral.requestContent
            $0.font = .medium(size: 16.adjusted)
            $0.textColor = .black
        }
        
        contentTextView.do {
            $0.font = .medium(size: 16.adjusted)
            $0.layer.cornerRadius = 5
            $0.backgroundColor = .white
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.gray200.cgColor
            $0.text = "여기에 내용을 작성해주세요."
            $0.textColor = .gray500
            $0.textContainerInset = UIEdgeInsets(top: 16.0, left: 8.5, bottom: 16.0, right: 8.5)
        }
        
        maximumTextCountLabel.do {
            $0.text = TextLiteral.requestMaximumText
            $0.font = .medium(size: 12.adjusted)
            $0.textColor = .gray700
        }
        
        emailStackView.do {
            $0.axis = .horizontal
            $0.spacing = 30.adjusted
            $0.alignment = .center
            $0.distribution = .fillProportionally
        }
        
        sendButton.do {
            $0.addTitleAttribute(title: "전송하기",
                                 titleColor: .white,
                                 fontName: .bold(size: 14.adjusted))
            $0.isEnabled = true
        }
    }
    
    override func setLayout() {
        requestLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.equalToSuperview().inset(16.adjusted)
        }
        
        emailTextField.snp.makeConstraints {
            $0.height.equalTo(42.adjusted)
        }
        
        emailStackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.top.equalTo(requestLabel.snp.bottom).offset(16.adjusted)
        }
        
        requestContentLabel.snp.makeConstraints {
            $0.top.equalTo(emailStackView.snp.bottom).offset(17.adjusted)
            $0.leading.equalToSuperview().inset(16.adjusted)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(requestContentLabel.snp.bottom).offset(6.adjusted)
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.height.equalTo(270.adjusted)
        }
        
        maximumTextCountLabel.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(6.adjusted)
            $0.trailing.equalToSuperview().inset(16.adjusted)
        }
        
        sendButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(16.adjusted)
            $0.bottom.equalToSuperview().inset(50.adjusted)
            $0.height.equalTo(48.adjusted)
        }
    }
}
