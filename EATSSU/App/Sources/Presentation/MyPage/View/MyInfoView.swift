//
//  MyInfoView.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 01/31/25.
//

import EATSSUDesign
import SnapKit
import Then
import UIKit

/// 사용자의 닉네임을 설정하는 화면의 View
final class MyInfoView: BaseUIView {
    // MARK: - Properties

    /// 사용자가 입력한 닉네임 값
    var userNickname: String = ""

    // MARK: - UI Components

    /// 닉네임 설정 안내 문구
    private let nickNameLabel = UILabel().then {
        $0.text = "EAT-SSU에서 사용할\n닉네임을 설정해 주세요"
        $0.numberOfLines = 2
        $0.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 18)
    }

    /// 닉네임 입력 필드
    let inputNickNameTextField = ESTextField(placeholder: ESTextLiteral.Nickname.inputNickName)

    /// 닉네임 중복 확인 버튼
    let nicknameDoubleCheckButton = ESButton(size: .small, title: "중복 확인").then {
        $0.isEnabled = false
    }

    /// 닉네임 검증 결과 메시지를 표시하는 레이블
    let nicknameValidationMessageLabel = UILabel().then {
        $0.text = ESTextLiteral.Nickname.hintInputNickName
        $0.textColor = EATSSUDesignAsset.Color.GrayScale.gray400.color
        $0.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)
    }

    /// 닉네임 입력 필드 및 검증 메시지를 포함하는 StackView
    private lazy var setNickNameStackView = UIStackView(arrangedSubviews: [
        inputNickNameTextField,
        nicknameValidationMessageLabel,
    ]).then {
        $0.axis = .vertical
        $0.spacing = 8.0
    }

    /// 완료 버튼
    let completeSettingNickNameButton = ESButton(size: .big, title: "완료하기").then {
        $0.isEnabled = false
    }

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setTextFieldDelegate()
    }

    // MARK: - Functions

    /// UI 구성 요소를 추가하는 메서드
    override func configureUI() {
        addSubviews(
            nickNameLabel,
            setNickNameStackView,
            completeSettingNickNameButton,
            nicknameDoubleCheckButton
        )
    }

    /// 레이아웃 설정 메서드
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
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(26)
            $0.height.equalTo(50)
        }
    }

    /// 닉네임 입력 필드의 delegate 설정
    func setTextFieldDelegate() {
        inputNickNameTextField.delegate = self
    }
}

// MARK: - UITextFieldDelegate

extension MyInfoView: UITextFieldDelegate {
    /// 사용자가 Return 키를 누르면 키보드를 내림
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /// 사용자의 닉네임 입력 값이 변경될 때 호출
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let inputValue = textField.text?.trimmingCharacters(in: .whitespaces) else { return }

        if inputValue.isEmpty {
            textFieldSettingWhenEmpty()
            return
        }
        checkNicknameValidation(textField)
    }

    /// 입력 필드를 초기화할 때 호출 (버튼 비활성화)
    func textFieldShouldClear(_: UITextField) -> Bool {
        nicknameDoubleCheckButton.isEnabled = false
        completeSettingNickNameButton.isEnabled = false
        return true
    }
}

// MARK: - Validation User Information

private extension MyInfoView {
    /// 닉네임 입력 값이 없을 때 기본 메시지를 표시
    func textFieldSettingWhenEmpty() {
        nicknameValidationMessageLabel.text = NicknameTextFieldResultType.textFieldEmpty.hintMessage
        nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.textFieldEmpty.textColor
    }

    /// 닉네임 유효성 검사
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

    /**
     닉네임이 변경되었을 때 유효성 검사를 수행하고 버튼 활성화 여부를 설정

     - Parameter nickname: 사용자가 입력한 닉네임
     - Returns: 닉네임이 유효한 경우 `true`, 그렇지 않으면 `false`
     */
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
