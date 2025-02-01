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
    let nicknameSettingLabel = UILabel().then {
        $0.text = "EAT-SSU에서 사용할\n닉네임을 설정해 주세요"
        $0.numberOfLines = 2
        $0.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 18)
    }

    /// 닉네임 입력 필드
    let nicknameTextField = ESTextField(placeholder: ESTextLiteral.Nickname.inputNickName)

    /// 닉네임 중복 확인 버튼
    let nicknameCheckButton = ESButton(size: .small, title: "중복 확인").then {
        $0.isEnabled = false
    }

    /// 닉네임 검증 결과 메시지를 표시하는 레이블
    let nicknameValidationLabel = UILabel().then {
        $0.text = ESTextLiteral.Nickname.hintInputNickName
        $0.textColor = EATSSUDesignAsset.Color.GrayScale.gray400.color
        $0.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)
    }

    /// 닉네임 입력 필드 및 검증 메시지를 포함하는 StackView
    lazy var nicknameStackView = UIStackView(arrangedSubviews: [
        nicknameTextField,
        nicknameValidationLabel,
    ]).then {
        $0.axis = .vertical
        $0.spacing = 8.0
    }

    /// 완료 버튼
    let completeButton = ESButton(size: .big, title: ESTextLiteral.MyPage.complete).then {
        $0.isEnabled = false
    }

    /// 소속 설정 UILabel
    let affiliationLabel = UILabel().then {
        $0.text = ESTextLiteral.MyPage.affiliationSetting
        $0.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 14)
    }

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTextFieldDelegate()
    }

    // MARK: - Functions

    /// UI 구성 요소를 추가하는 메서드
    override func configureUI() {
        addSubviews(
            nicknameSettingLabel,
            nicknameStackView,
            completeButton,
            nicknameCheckButton,
            affiliationLabel
        )
    }

    /// 레이아웃 설정 메서드
    override func setLayout() {
        affiliationLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameStackView.snp.bottom).offset(40)
            $0.leading.equalTo(nicknameStackView.snp.leading)
        }

        nicknameSettingLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(20)
            $0.leading.equalToSuperview().inset(16)
        }
        nicknameStackView.snp.makeConstraints {
            $0.top.equalTo(nicknameSettingLabel.snp.bottom).offset(16)
            $0.leading.equalToSuperview().inset(16)
            $0.trailing.equalTo(nicknameCheckButton.snp.leading).offset(-5)
        }
        nicknameCheckButton.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField)
            $0.width.equalTo(75)
            $0.height.equalTo(48)
            $0.trailing.equalToSuperview().inset(16)
        }
        nicknameTextField.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        completeButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(26)
            $0.height.equalTo(50)
        }
    }

    /// 닉네임 입력 필드의 delegate 설정
    func configureTextFieldDelegate() {
        nicknameTextField.delegate = self
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
            updateTextFieldForEmptyState()
            return
        }
        validateNickname(textField)
    }

    /// 입력 필드를 초기화할 때 호출 (버튼 비활성화)
    func textFieldShouldClear(_: UITextField) -> Bool {
        nicknameCheckButton.isEnabled = false
        completeButton.isEnabled = false
        return true
    }
}

// MARK: - Validation User Information

private extension MyInfoView {
    /// 닉네임 입력 값이 없을 때 기본 메시지를 표시
    func updateTextFieldForEmptyState() {
        nicknameValidationLabel.text = NicknameTextFieldResultType.textFieldEmpty.hintMessage
        nicknameValidationLabel.textColor = NicknameTextFieldResultType.textFieldEmpty.textColor
    }

    /// 닉네임 유효성 검사
    func validateNickname(_ textField: UITextField) {
        if let userNickname = textField.text {
            if isNicknameValid(userNickname) {
                nicknameValidationLabel.text = NicknameTextFieldResultType.nicknameTextFieldDoubleCheck.hintMessage
                nicknameValidationLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldDoubleCheck.textColor
            } else {
                nicknameValidationLabel.text = NicknameTextFieldResultType.nicknameTextFieldOver.hintMessage
                nicknameValidationLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldOver.textColor
            }
        }
    }

    /**
     닉네임이 변경되었을 때 유효성 검사를 수행하고 버튼 활성화 여부를 설정

     - Parameter nickname: 사용자가 입력한 닉네임
     - Returns: 닉네임이 유효한 경우 `true`, 그렇지 않으면 `false`
     */
    func isNicknameValid(_ nickname: String) -> Bool {
        completeButton.isEnabled = false

        if nickname.count > 1, nickname.count < 9 {
            nicknameCheckButton.isEnabled = true
            return true
        } else {
            nicknameCheckButton.isEnabled = false
            return false
        }
    }
}
