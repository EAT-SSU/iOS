//
//  UserWithdrawView.swift
//  EAT-SSU
//
//  Created by 박윤빈 on 6/3/24.
//

import UIKit

import SnapKit

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
    public var nickNameStateGuideLabel = UILabel()
    public var completeSignOutButton = PostUIButton()
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
            $0.height.equalTo(50)
        }
    }

    private func setProperties() {
        nickNameLabel.text = TextLiteral.MyPage.confirmWithdrawal
        nickNameLabel.font = .bold(size: 16)

        subscription.text = TextLiteral.MyPage.withdrawalNotice
        subscription.numberOfLines = 2
        subscription.font = .medium(size: 12)
        subscription.textColor = .gray700

        inputNickNameTextField.font = .regular(size: 12)
        inputNickNameTextField.textColor = .black
        inputNickNameTextField.setRoundBorder()
        inputNickNameTextField.addLeftPadding()
        inputNickNameTextField.clearButtonMode = .whileEditing

        nickNameStateGuideLabel.text = TextLiteral.inputNickName
        nickNameStateGuideLabel.textColor = .gray700
        nickNameStateGuideLabel.font = .medium(size: 10)

        nickNameInputStackView.axis = .vertical
        nickNameInputStackView.spacing = 8.0

        completeSignOutButton.addTitleAttribute(
            title: TextLiteral.MyPage.withdraw,
            titleColor: .white,
            fontName: .bold(size: 18)
        )
        completeSignOutButton.setRoundBorder(borderColor: .gray300, borderWidth: 0, cornerRadius: 10)
        completeSignOutButton.isEnabled = false
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
            nickNameStateGuideLabel.isHidden = false
            nickNameStateGuideLabel.text = TextLiteral.MyPage.invalidNicknameMessage
            nickNameStateGuideLabel.textColor = .primary
            completeSignOutButton.isEnabled = false

        case .pleaseEnter:
            nickNameStateGuideLabel.isHidden = false
            nickNameStateGuideLabel.text = TextLiteral.inputNickName
            nickNameStateGuideLabel.textColor = .gray700
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

    func textFieldShouldClear(_: UITextField) -> Bool {
        completeSignOutButton.isEnabled = false
        return true
    }
}

private extension UserWithdrawView {
    func textFieldSettingWhenEmpty(_: UITextField) {
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
