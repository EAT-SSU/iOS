//
//  UserWithdrawView.swift
//  EAT-SSU
//
//  Created by 박윤빈 on 6/3/24.
//

import UIKit

import SnapKit
import Then

enum ValidationLabelState {
    case unCorrected
    case corrected
    case pleaseEnter
}

final class UserWithdrawView: BaseUIView {
    
    // MARK: - Properties
    
    private var userNickname: String = ""
    
    // MARK: - UI Components
    
    private let nickNameLabel = UILabel()
    private let subscription = UILabel()
    public let inputNickNameTextField = UITextField()
    public var nickNameStateGuideLabel =  UILabel()
    public var completeSignOutButton = PostUIButton()
    private lazy var nickNameInputStackView: UIStackView = UIStackView(
      arrangedSubviews: [
        inputNickNameTextField,
        nickNameStateGuideLabel
      ]
    )
    
    // MARK: - Intializer
    
    init(nickName: String) {
        super.init(frame: CGRect())
        self.userNickname = nickName
		self.inputNickNameTextField.placeholder = nickName
		self.setTextFieldDelegate()
		self.setProperties()
		self.configureUI()
    }
    
    // MARK: - Functions
    
    override func configureUI() {
        self.addSubviews(
          nickNameLabel,
          subscription,
          nickNameInputStackView,
          completeSignOutButton
        )
        
        subscription.addLineHeight(lineHeight: 18)
    }
    
    override func setLayout() {
        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().inset(16)
        }
        
        subscription.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(8)
            $0.leading.equalTo(nickNameLabel)
        }
        
        nickNameInputStackView.snp.makeConstraints {
            $0.top.equalTo(subscription.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        inputNickNameTextField.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        completeSignOutButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
          $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(26)
            $0.height.equalTo(50)
        }
    }
    
    private func setProperties() {
        nickNameLabel.do {
          $0.text = TextLiteral.MyPage.confirmWithdrawal
            $0.font = .bold(size: 16)
        }
        
        subscription.do {
          $0.text = TextLiteral.MyPage.withdrawalNotice
            $0.numberOfLines = 2
            $0.font = .medium(size: 12)
            $0.textColor = .gray700
        }
        
        inputNickNameTextField.do {
            $0.font = .regular(size: 12)
            $0.textColor = .black
            $0.setRoundBorder()
            $0.addLeftPadding()
            $0.clearButtonMode = .whileEditing
        }
        
        nickNameStateGuideLabel.do {
            $0.text = TextLiteral.inputNickName
            $0.textColor = .gray700
            $0.font = .medium(size: 10)
        }
        
        nickNameInputStackView.do {
            $0.axis = .vertical
            $0.spacing = 8.0
        }
        
        completeSignOutButton.do {
          $0.addTitleAttribute(title: TextLiteral.MyPage.withdraw,
                                 titleColor: .white,
                                 fontName: .bold(size: 18))
            $0.setRoundBorder(borderColor: .gray300, borderWidth: 0, cornerRadius: 10)
            $0.isEnabled = false
        }
    }
    
    private func setTextFieldDelegate() {
        inputNickNameTextField.delegate = self
    }
    
    private func setValidationLabel(state: ValidationLabelState) {
        switch state {
        case .corrected:
			nickNameStateGuideLabel.text = TextLiteral.MyPage.validInputMessage
            nickNameStateGuideLabel.textColor = .systemGreen
            completeSignOutButton.isEnabled = true
        case .unCorrected:
            nickNameStateGuideLabel.do {
				$0.isHidden = false
				$0.text = TextLiteral.MyPage.invalidNicknameMessage
                $0.textColor = .primary
            }
            completeSignOutButton.isEnabled = false
        case .pleaseEnter:
            nickNameStateGuideLabel.do {
                $0.isHidden = false
                $0.text = TextLiteral.inputNickName
                $0.textColor = .gray700
            }
            completeSignOutButton.isEnabled = false
        }
    }
    
}

// MARK: - UITextFieldDelegate

extension UserWithdrawView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        guard let inputValue = textField.text?.trimmingCharacters(in: .whitespaces) else { return }
        
        if inputValue.isEmpty {
            textFieldSettingWhenEmpty(textField)
            return
        }
        checkIsNickNameCorrect(textField)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        completeSignOutButton.isEnabled = false
        return true
    }
}

private extension UserWithdrawView {
    
    func textFieldSettingWhenEmpty(_ textField: UITextField) {
        setValidationLabel(state: .pleaseEnter)
    }
    
    func checkIsNickNameCorrect(_ textField: UITextField) {
        if let userNickname = textField.text {
            if userNickname == self.userNickname {
                setValidationLabel(state: .corrected)
            } else {
                setValidationLabel(state: .unCorrected)
            }
        }
    }
}
