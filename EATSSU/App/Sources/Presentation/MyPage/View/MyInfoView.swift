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

/// 사용자의 닉네임과 소속(단과대학 및 학과)을 설정하는 화면의 View
final class MyInfoView: BaseUIView {
    // MARK: - Properties

    /// 사용자가 입력한 닉네임 값
    var userNickname: String = ""

    /// 닉네임 중복 확인(검증)이 완료되었는지 여부.
    var isNicknameVerified: Bool = false

    // MARK: - UI Components

    /// 닉네임 설정 안내 문구
    let nicknameSettingLabel = UILabel().then {
        $0.text = "닉네임 설정"
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

    /// "변경하기" 버튼
    let completeButton = ESButton(size: .big, title: ESTextLiteral.MyPage.change).then {
        $0.isEnabled = false
    }

    /// 소속 설정 UILabel (단과대학 선택)
    let affiliationLabel = UILabel().then {
        $0.text = ESTextLiteral.MyPage.affiliationSetting
        $0.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 14)
    }

    /// 단과대학 선택용 TextField (직접 입력 불가, Picker로만 선택)
    let affiliationTextField = ESTextField(placeholder: "소속(단과대학)을 선택하세요.").then {
        $0.tintColor = .clear // 커서 비표시
        $0.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 14)
    }

    // MARK: - 학과 선택 UI Components

    /// 학과 선택 UILabel
    let departmentLabel = UILabel().then {
        $0.text = "학과 선택"
        $0.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 14)
    }

    /// 학과 선택용 TextField (직접 입력 불가, Picker로만 선택)
    let departmentTextField = ESTextField(placeholder: "학과를 선택하세요.").then {
        $0.tintColor = .clear // 커서 비표시
        $0.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 14)
    }

    // MARK: - [Picker] 단과대학 및 학과 선택을 위한 Picker Views

    /// 단과대학 목록
    private let colleges = [
        "인문대", "자연대", "법과대", "사회대",
        "경통대", "경영대", "공과대", "IT대", "자유전공",
    ]

    /// 단과대학 선택용 UIPickerView
    private let affiliationPicker = UIPickerView()

    /// 학과 선택용 UIPickerView
    private let departmentPicker = UIPickerView()

    /// 단과대학별 학과 목록 (자유전공은 학과가 없으므로 제외)
    private let departments: [String: [String]] = [
        "인문대": ["기독교학과", "국어국문학과", "영어영문학과", "독어독문학과", "불어불문학과", "중어중문학과", "일어일문학과", "철학과", "사학과", "예술창작학부", "스포츠학부"],
        "자연대": ["수학과", "물리학과", "화학과", "정보통계수리학과", "의생명시스템학부"],
        "법과대": ["법학과", "국제법무학과"],
        "사회대": ["사회복지학부", "행정학부", "정치외교학과", "정보사회학과", "언론홍보학과", "평생교육학과"],
        "경통대": ["경제학과", "글로벌통상학과", "금융경제학과", "국제무역학과", "통상산업학과"],
        "경영대": ["경영학부", "벤처중소기업학과", "회계학과", "금융학부", "벤처경영학과", "혁신경영학과", "복지경영학과", "회계세무학과"],
        "공과대": ["화학공학과", "산업정보시스템공학과", "전기공학부", "기계공학부", "건축학부", "신소재공학과"],
        "IT대": ["컴퓨터학부", "전자정보공학부", "글로벌미디어학부", "소프트웨어학부", "스마트시스템소프트웨어학과", "미디어경영학과", "전자정보공학부", "정보보호학과"],
    ]

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureTextFieldDelegate()

        // [Picker 설정] 단과대학 Picker
        affiliationPicker.delegate = self
        affiliationPicker.dataSource = self
        affiliationTextField.inputView = affiliationPicker
        affiliationTextField.delegate = self

        // [Picker 설정] 학과 Picker
        departmentPicker.delegate = self
        departmentPicker.dataSource = self
        departmentTextField.inputView = departmentPicker
        departmentTextField.delegate = self

        // 초기에는 학과 선택 UI 숨김 (자유전공 선택 시 학과 선택이 필요없음)
        departmentLabel.isHidden = true
        departmentTextField.isHidden = true
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
            affiliationTextField,
            departmentLabel,
            departmentTextField
        )
    }

    /// 레이아웃 설정 메서드
    override func setLayout() {
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
        affiliationLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameStackView.snp.bottom).offset(40)
            $0.leading.equalTo(nicknameStackView.snp.leading)
        }
        affiliationTextField.snp.makeConstraints {
            $0.top.equalTo(affiliationLabel.snp.bottom).offset(8)
            $0.leading.equalTo(nicknameStackView.snp.leading)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(48)
        }
        departmentLabel.snp.makeConstraints {
            $0.top.equalTo(affiliationTextField.snp.bottom).offset(16)
            $0.leading.equalTo(affiliationTextField)
        }
        departmentTextField.snp.makeConstraints {
            $0.top.equalTo(departmentLabel.snp.bottom).offset(8)
            $0.leading.equalTo(affiliationTextField)
            $0.trailing.equalToSuperview().inset(16)
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

    /// 닉네임 필드에 한해 값이 변경될 때 호출
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if textField == nicknameTextField {
            // 닉네임이 변경되면 이전 검증 결과 초기화
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
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == nicknameTextField {
            nicknameCheckButton.isEnabled = false
            updateCompleteButtonState()
        }
        return true
    }

    /// affiliationTextField와 departmentTextField는 직접 입력을 막음 (Picker로만 선택)
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn _: NSRange,
                   replacementString _: String) -> Bool
    {
        if textField == affiliationTextField || textField == departmentTextField {
            return false
        }
        return true
    }
}

// MARK: - UIPickerViewDataSource, UIPickerViewDelegate

extension MyInfoView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in _: UIPickerView) -> Int { 1 }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        if pickerView == affiliationPicker {
            return colleges.count
        } else if pickerView == departmentPicker {
            if let selectedCollege = affiliationTextField.text,
               let deptArray = departments[selectedCollege]
            {
                return deptArray.count
            }
            return 0
        }
        return 0
    }

    func pickerView(_ pickerView: UIPickerView,
                    titleForRow row: Int,
                    forComponent _: Int) -> String?
    {
        if pickerView == affiliationPicker {
            return colleges[row]
        } else if pickerView == departmentPicker {
            if let selectedCollege = affiliationTextField.text,
               let deptArray = departments[selectedCollege]
            {
                return deptArray[row]
            }
            return nil
        }
        return nil
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        if pickerView == affiliationPicker {
            let selectedCollege = colleges[row]
            affiliationTextField.text = selectedCollege
            affiliationTextField.resignFirstResponder()
            updateCompleteButtonState()

            // 자유전공 선택 시 학과 UI를 숨기고, 그 외에는 보이도록 처리
            if selectedCollege == "자유전공" {
                departmentLabel.isHidden = true
                departmentTextField.isHidden = true
                departmentTextField.text = ""
            } else {
                departmentLabel.isHidden = false
                departmentTextField.isHidden = false
                departmentTextField.text = ""
                departmentPicker.reloadAllComponents()
            }
        } else if pickerView == departmentPicker {
            if let selectedCollege = affiliationTextField.text,
               let deptArray = departments[selectedCollege]
            {
                let selectedDepartment = deptArray[row]
                departmentTextField.text = selectedDepartment
                departmentTextField.resignFirstResponder()
                updateCompleteButtonState()
            }
        }
    }
}

// MARK: - Validation User Information

extension MyInfoView {
    /// 닉네임 입력 값이 없을 때 기본 메시지 표시
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
     닉네임이 변경되었을 때 유효성 검사 및 중복 확인 버튼 활성화 설정

     - Parameter nickname: 사용자가 입력한 닉네임
     - Returns: 유효하면 `true`, 그렇지 않으면 `false`
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

    /// 닉네임(중복 확인 완료) 또는 소속(단과대 및 해당 학과 선택) 중 하나라도 설정되어 있으면 완료 버튼 활성화
    func updateCompleteButtonState() {
        let nickname = nicknameTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let affiliation = affiliationTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        let department = departmentTextField.text?.trimmingCharacters(in: .whitespaces) ?? ""

        // 닉네임이 입력되어 있다면, 중복 확인(검증)이 완료되어야 함
        let isNicknameReady = !nickname.isEmpty && isNicknameVerified

        // 소속(단과대) 선택 시, 자유전공이면 학과 선택 없이 완료 가능, 그 외엔 학과 선택도 필요함.
        let isAffiliationReady: Bool = if affiliation == "자유전공" {
            !affiliation.isEmpty
        } else {
            !affiliation.isEmpty && !department.isEmpty
        }

        completeButton.isEnabled = isNicknameReady || isAffiliationReady
    }
}
