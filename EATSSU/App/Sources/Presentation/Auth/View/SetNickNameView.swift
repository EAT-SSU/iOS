//
//  SetNickNameView.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/03.
//

import UIKit

import EATSSUDesign

import SnapKit
import Then

final class SetNickNameView: BaseUIView {
    // MARK: - Properties

    private var userNickname: String = ""

    // MARK: - UI Components

    /// "EAT-SSU에서 사용할 닉네임을 설정해 주세요" 레이블
    private let nickNameLabel = UILabel().then {
        $0.text = "EAT-SSU에서 사용할\n닉네임을 설정해 주세요"
        $0.numberOfLines = 2
        $0.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 18)
    }

    /// 닉네임 입력 텍스트필드
    public let inputNickNameTextField = ESTextField(placeholder: TextLiteral.inputNickName).then { _ in
        /*
         해야 할 일
         - 현재 ESTextField로서는 크게 문제가 없는데, 혹시 모르는 추가 설정이 놓친 게 없나 검토 필요
         */
    }

    /// "중복확인" 버튼
    public var nicknameDoubleCheckButton = ESButton(size: .small, title: "중복 확인").then { esButton in
        /*
         해야 할 일
         - 초기 버튼의 세팅값을 false로 주는 항목은 ESButton 초기화 값으로 할당하고 싶다.
         - 하지만 계산된 프로퍼티로 설계되어 있어서 어떻게 해야 할 지 모르겠다.
         */
        esButton.isEnabled = false
    }

    /// 닉네임 중복확인 결과 메시지 레이블
    public var nicknameValidationMessageLabel = UILabel().then {
        $0.text = TextLiteral.hintInputNickName
        $0.textColor = EATSSUDesignAsset.Color.GrayScale.gray400.color
        $0.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)
    }

    private lazy var setNickNameStackView: UIStackView = .init(
        arrangedSubviews: [
            inputNickNameTextField,
            nicknameValidationMessageLabel,
        ]
    ).then {
        $0.axis = .vertical
        $0.spacing = 8.0
    }

    /// "완료하기" 버튼
    public var completeSettingNickNameButton = ESButton(size: .big, title: "완료하기").then { esButton in
        esButton.isEnabled = false
    }

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setTextFieldDelegate()
    }

    // MARK: - Functions

    override func configureUI() {
        addSubviews(
            nickNameLabel,
            setNickNameStackView,
            completeSettingNickNameButton,
            nicknameDoubleCheckButton
        )
    }

    override func setLayout() {
        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().inset(16)
        }
        setNickNameStackView.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(nicknameDoubleCheckButton.snp.leading).offset(-5)
        }
        nicknameDoubleCheckButton.snp.makeConstraints {
            $0.top.equalTo(inputNickNameTextField)
            $0.width.equalTo(75)
            $0.height.equalTo(48)
            $0.trailing.equalToSuperview().inset(16)
        }
        inputNickNameTextField.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        completeSettingNickNameButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(self.safeAreaLayoutGuide).inset(26)
            $0.height.equalTo(50)
        }
    }

    func setTextFieldDelegate() {
        inputNickNameTextField.delegate = self
    }
}

// MARK: - UITextFieldDelegate

extension SetNickNameView: UITextFieldDelegate {
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
        checkNicknameValidation(textField)
    }

    func textFieldShouldClear(_: UITextField) -> Bool {
        nicknameDoubleCheckButton.isEnabled = false
        completeSettingNickNameButton.isEnabled = false
        return true
    }
}

// MARK: - Validation User Information

private extension SetNickNameView {
    func textFieldSettingWhenEmpty(_: UITextField) {
        nicknameValidationMessageLabel.text = NicknameTextFieldResultType.textFieldEmpty.hintMessage
        nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.textFieldEmpty.textColor
    }

    func checkNicknameValidation(_ textField: UITextField) {
        if let userNickname = textField.text {
            if nicknameInputChanged(nickname: userNickname) {
                nicknameValidationMessageLabel.text = NicknameTextFieldResultType.nicknameTextFieldDoubleCheck.hintMessage
                nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldDoubleCheck.textColor
            } else {
                nicknameValidationMessageLabel.text = NicknameTextFieldResultType.nicknameTextFieldOver.hintMessage
                nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldOver.textColor
            }
        }
    }

    func nicknameInputChanged(nickname: String) -> Bool {
        completeSettingNickNameButton.isEnabled = false

        if nickname.count > 1, nickname.count < 9 {
            nicknameDoubleCheckButton.isEnabled = true
            return true
        } else {
            nicknameDoubleCheckButton.isEnabled = false
            return false
        }
    }
}
