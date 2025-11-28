//
//  UserWithdrawView.swift
//  EAT-SSU
//
//  Created by 박윤빈 on 6/3/24.
//

import UIKit
import Combine

import SnapKit

import EATSSUDesign

enum ValidationLabelState {
    case unCorrected
    case corrected
    case pleaseEnter
}

final class UserWithdrawView: BaseUIView {
    // MARK: - Properties

    private var userNickname: String = ""
    private var cancellables = Set<AnyCancellable>()

    // MARK: - UI Components

    private let nickNameLabel = UILabel()
    private let subscription = UILabel()
    public let inputNickNameTextField = UITextField()
    public var nickNameStateGuideLabel = UILabel()
    public var completeSignOutButton = ESButton(size: .big, title: TextLiteral.MyPage.withdraw)
    private lazy var nickNameInputStackView: UIStackView = .init(
        arrangedSubviews: [
            inputNickNameTextField,
            nickNameStateGuideLabel,
        ]
    )

    // MARK: - Intializer

    init(nickName: String) {
        super.init(frame: CGRect())
        userNickname = nickName
        inputNickNameTextField.placeholder = nickName
        setTextFieldDelegate()
        setProperties()
        configureUI()
        bindTextField()
    }

    // MARK: - Functions

    override func configureUI() {
        addSubviews(
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
        }
    }
    
    private func setProperties() {
        nickNameLabel.text = TextLiteral.MyPage.confirmWithdrawal
        nickNameLabel.font = .subtitle1

        subscription.text = TextLiteral.MyPage.withdrawalNotice
        subscription.numberOfLines = 2
        subscription.font = .caption2
        subscription.textColor = .gray700

        inputNickNameTextField.font = .caption2
        inputNickNameTextField.textColor = .gray700Basic
        inputNickNameTextField.setRoundBorder()
        inputNickNameTextField.addLeftPadding()
        inputNickNameTextField.clearButtonMode = .whileEditing
        inputNickNameTextField.layer.borderWidth = 1.0
        inputNickNameTextField.layer.borderColor = UIColor.gray300.cgColor

        nickNameStateGuideLabel.text = TextLiteral.inputNickName
        nickNameStateGuideLabel.textColor = .gray700
        nickNameStateGuideLabel.font = .caption3

        nickNameInputStackView.axis = .vertical
        nickNameInputStackView.spacing = 8.0
        
        completeSignOutButton.isEnabled = false
    }

    private func bindTextField() {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: inputNickNameTextField)
            .compactMap { ($0.object as? UITextField)?.text }
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .sink { [weak self] text in
                guard let self = self else { return }
                self.validateNickname(text)
            }
            .store(in: &cancellables)
    }
    
    private func validateNickname(_ text: String) {
        if text.isEmpty {
            setValidationLabel(state: .pleaseEnter)
        } else if text == userNickname {
            setValidationLabel(state: .corrected)
        } else {
            setValidationLabel(state: .unCorrected)
        }
    }

    private func setValidationLabel(state: ValidationLabelState) {
        switch state {
        case .corrected:
            // 올바른 닉네임 입력 시 -> 회색
            nickNameStateGuideLabel.text = TextLiteral.MyPage.validInputMessage
            nickNameStateGuideLabel.textColor = .gray700
            inputNickNameTextField.layer.borderColor = UIColor.gray300.cgColor
            completeSignOutButton.isEnabled = true

        case .unCorrected:
            // 잘못된 닉네임 입력 시 -> 빨간색
            nickNameStateGuideLabel.isHidden = false
            nickNameStateGuideLabel.text = TextLiteral.MyPage.invalidNicknameMessage
            nickNameStateGuideLabel.textColor = .primary
            inputNickNameTextField.layer.borderColor = UIColor.danger.cgColor
            completeSignOutButton.isEnabled = false

        case .pleaseEnter:
            // 비어있을 때 -> 회색
            nickNameStateGuideLabel.isHidden = false
            nickNameStateGuideLabel.text = TextLiteral.inputNickName
            nickNameStateGuideLabel.textColor = .gray700
            inputNickNameTextField.layer.borderColor = UIColor.gray300.cgColor
            completeSignOutButton.isEnabled = false
        }
    }

    private func setTextFieldDelegate() {
        inputNickNameTextField.delegate = self
    }
}

// MARK: - UITextFieldDelegate

extension UserWithdrawView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldShouldClear(_: UITextField) -> Bool {
        completeSignOutButton.isEnabled = false
        inputNickNameTextField.layer.borderColor = UIColor.gray300.cgColor
        return true
    }
}
