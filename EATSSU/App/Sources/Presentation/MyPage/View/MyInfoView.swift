//
//  MyInfoView.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 01/31/25.
//

import UIKit

import EATSSUDesign

import SnapKit
import Then

/// 사용자의 닉네임을 설정하는 화면의 View
final class MyInfoView: BaseUIView {
    // MARK: - Properties

    /// 사용자가 입력한 닉네임 값
    var userNickname: String = ""

    /// 닉네임 중복 확인(검증)이 완료되었는지 여부.
    var isNicknameVerified: Bool = false

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

    // MARK: - [추가] 단과대학 선택을 위한 프로퍼티

    /// 단과대학 목록
    private let colleges = [
        "인문대", "자연대", "법과대", "사회대",
        "경통대", "경영대", "공과대", "IT대", "자유전공",
    ]

    /// 단과대학 선택용 UIPickerView
    private let affiliationPicker = UIPickerView()

    /// 사용자 소속(단과대학)을 보여줄 TextField (직접 입력 불가, Picker로만 선택)
    let affiliationTextField = ESTextField(placeholder: "소속을 선택하세요.").then {
        $0.tintColor = .clear // 커서 비표시
    }

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTextFieldDelegate()

        // [추가] affiliationPicker 설정
        affiliationPicker.delegate = self
        affiliationPicker.dataSource = self

        // [추가] affiliationTextField에서 직접 키보드가 뜨지 않고 Picker가 뜨도록 설정
        affiliationTextField.inputView = affiliationPicker
        // [추가] affiliationTextField도 UITextFieldDelegate 처리
        affiliationTextField.delegate = self
    }

    // MARK: - Functions

    /// UI 구성 요소를 추가하는 메서드
    override func configureUI() {
        addSubviews(
            nicknameSettingLabel,
            nicknameStackView,
            completeButton,
            nicknameCheckButton,
            affiliationLabel,
            // [추가] affiliationTextField도 뷰에 추가
            affiliationTextField
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

        // [추가] affiliationTextField 오토레이아웃
        affiliationTextField.snp.makeConstraints {
            $0.top.equalTo(affiliationLabel.snp.bottom).offset(8)
            $0.leading.equalTo(nicknameStackView.snp.leading)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(48)
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

    /// 사용자의 닉네임 입력 값이 변경될 때 호출 (닉네임 필드에 한해서만 처리)
    func textFieldDidChangeSelection(_ textField: UITextField) {
        // 닉네임 TextField에 대해서만 처리하도록 함
        if textField == nicknameTextField {
            // 닉네임 입력 변경 시에는 이전 검증 결과를 초기화
            isNicknameVerified = false

            guard let inputValue = textField.text?.trimmingCharacters(in: .whitespaces) else { return }
            if inputValue.isEmpty {
                updateTextFieldForEmptyState()
                updateCompleteButtonState()
                return
            }
            validateNickname(textField)
            updateCompleteButtonState()
        }
    }

    /// 입력 필드를 초기화할 때 호출 (버튼 비활성화)
    func textFieldShouldClear(_: UITextField) -> Bool {
        nicknameCheckButton.isEnabled = false
        updateCompleteButtonState()
        return true
    }

    // [추가] affiliationTextField에 대해서는 '직접 입력'을 막아준다.
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn _: NSRange,
                   replacementString _: String) -> Bool
    {
        // affiliationTextField는 Picker만 사용하도록 직접 입력 불가
        if textField == affiliationTextField {
            return false
        }
        // 닉네임 TextField 등 다른 TextField에는 기존 로직(기본 true) 적용
        return true
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension MyInfoView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in _: UIPickerView) -> Int {
        1
    }

    func pickerView(_: UIPickerView,
                    numberOfRowsInComponent _: Int) -> Int
    {
        colleges.count
    }

    func pickerView(_: UIPickerView,
                    titleForRow row: Int,
                    forComponent _: Int) -> String?
    {
        colleges[row]
    }

    func pickerView(_: UIPickerView,
                    didSelectRow row: Int,
                    inComponent _: Int)
    {
        affiliationTextField.text = colleges[row]
        // 단과대학 선택 시에는 닉네임 중복확인 버튼 활성화와 관련된 로직은 건드리지 않음.
        // 대신 완료 버튼 활성화 상태를 업데이트
        updateCompleteButtonState()
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
     닉네임이 변경되었을 때 유효성 검사를 수행하고 중복확인 버튼 활성화 여부를 설정

     - Parameter nickname: 사용자가 입력한 닉네임
     - Returns: 닉네임이 유효한 경우 `true`, 그렇지 않으면 `false`
     */
    func isNicknameValid(_ nickname: String) -> Bool {
        if nickname.count > 1, nickname.count < 9 {
            nicknameCheckButton.isEnabled = true
            return true
        } else {
            nicknameCheckButton.isEnabled = false
            return false
        }
    }

    /// 닉네임(중복 확인 완료) 또는 소속 중 하나라도 설정되어 있으면 완료 버튼을 활성화한다.
    func updateCompleteButtonState() {
        let nickname = nicknameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let affiliation = affiliationTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        // 닉네임이 입력되어 있다면, 중복 확인(검증)이 완료되어야 완료 버튼 활성화.
        let isNicknameReady = nickname.isEmpty ? false : isNicknameVerified
        completeButton.isEnabled = isNicknameReady || !affiliation.isEmpty
    }
}
