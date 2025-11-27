//
//  SetNickNameView.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/03.
//

import UIKit

import SnapKit

import EATSSUDesign

final class SetNickNameView: BaseUIView {
    // MARK: - Properties

    private var userNickname: String = ""
    public let collegeDropDownView = DropDownView(title: "단과대", items: [])
    public let departmentDropDownView = DropDownView(title: "학과", items: [])
    private var isNicknameChecked = false
    private var selectedCollege: String?
    private var selectedDepartment: String?
    
    public var onSelectCollege: ((String) -> Void)?
    public var onSelectDepartment: ((String) -> Void)?

    // MARK: - UI Components

    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임 설정"
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
        return label
    }()

    public let inputNickNameTextField: ESTextField = {
        let textField = ESTextField(placeholder: TextLiteral.inputNickName)
        return textField
    }()

    public var nicknameDoubleCheckButton: ESButton = {
        let button = ESButton(size: .small, title: "중복 확인")
        button.isEnabled = false
        return button
    }()

    public var nicknameValidationMessageLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.hintInputNickName
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray400.color
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)
        return label
    }()

    private lazy var setNickNameStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            inputNickNameTextField,
            nicknameValidationMessageLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 8.0
        return stackView
    }()

    private let affiliationLabel: UILabel = {
        let label = UILabel()
        label.text = "소속 설정"
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
        return label
    }()

    private lazy var affiliationStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            collegeDropDownView,
            departmentDropDownView
        ])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()

    private let connectedAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "연결된 계정"
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
        return label
    }()

    private let accountTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "없음"
        label.font = .button2
        return label
    }()

    private let accountTypeImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }
        return imageView
    }()

    private lazy var accountStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [accountTypeLabel, accountTypeImage])
        stack.axis = .horizontal
        stack.alignment = .bottom
        stack.spacing = 5
        return stack
    }()

    private lazy var totalAccountStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            connectedAccountLabel,
            accountStackView
        ])
        stack.axis = .horizontal
        stack.alignment = .bottom
        stack.spacing = 20
        return stack
    }()

    public var completeSettingNickNameButton: ESButton = {
        let button = ESButton(size: .big, title: "저장하기")
        button.isEnabled = false
        return button
    }()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        setTextFieldDelegate()
        bindCollegeDepartmentDropDown()
    }

    // MARK: - Functions

    override func configureUI() {
        addSubviews(
            nickNameLabel,
            setNickNameStackView,
            nicknameDoubleCheckButton,
            affiliationLabel,
            affiliationStackView,
            totalAccountStackView,
            completeSettingNickNameButton
        )
    }

    override func setLayout() {
        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.leading.equalToSuperview().inset(24)
        }
        
        inputNickNameTextField.snp.makeConstraints {
            $0.height.equalTo(52)
        }
        
        setNickNameStackView.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(24)
            $0.trailing.equalTo(nicknameDoubleCheckButton.snp.leading).offset(-5)
        }
        
        nicknameDoubleCheckButton.snp.makeConstraints {
            $0.top.equalTo(inputNickNameTextField)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(52)
        }
        
        affiliationLabel.snp.makeConstraints {
            $0.top.equalTo(setNickNameStackView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(24)
        }

        affiliationStackView.snp.makeConstraints {
            $0.top.equalTo(affiliationLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }
        collegeDropDownView.snp.makeConstraints { $0.height.equalTo(52) }
        departmentDropDownView.snp.makeConstraints { $0.height.equalTo(52) }

        totalAccountStackView.snp.makeConstraints {
            $0.top.equalTo(affiliationStackView.snp.bottom).offset(40)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        completeSettingNickNameButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalTo(safeAreaLayoutGuide).inset(26)
            $0.height.equalTo(52)
        }
    }

    func setTextFieldDelegate() {
        inputNickNameTextField.delegate = self
    }

    private func bindCollegeDepartmentDropDown() {
        collegeDropDownView.onSelectItem = { [weak self] college in
            guard let self else { return }
            selectedCollege = college

            departmentDropDownView.updateItems([])
            departmentDropDownView.setTitle("학과")
            selectedDepartment = nil
            updateCompleteButtonState()

            onSelectCollege?(college)
        }

        departmentDropDownView.onSelectItem = { [weak self] department in
            guard let self else { return }
            selectedDepartment = department
            updateCompleteButtonState()
            onSelectDepartment?(department)
        }
    }

    private func updateCompleteButtonState() {
        let isCollegeSelected = selectedCollege != nil && selectedCollege != "단과대"
        let isDepartmentSelected = selectedDepartment != nil && selectedDepartment != "학과"
        completeSettingNickNameButton.isEnabled = isNicknameChecked && isCollegeSelected && isDepartmentSelected
    }

    public func setNicknameChecked(_ checked: Bool) {
        isNicknameChecked = checked
        updateCompleteButtonState()
    }

    public func setAccountInfo() {
        if let accountType = UserInfoManager.shared.getCurrentUserInfo()?.accountType {
            switch accountType {
            case .apple:
                accountTypeLabel.text = "APPLE"
                accountTypeImage.image = EATSSUDesignAsset.Images.signWithApple.image
            case .kakao:
                accountTypeLabel.text = "카카오"
                accountTypeImage.image = EATSSUDesignAsset.Images.signWithKakao.image
            }
        }
    }
    
    func updateCheckResultUI(isAvailable: Bool) {
        let resultType: NicknameTextFieldResultType = isAvailable ? .nicknameTextFieldValid : .nicknameTextFieldDuplicated
        
        nicknameValidationMessageLabel.text = resultType.hintMessage
        nicknameValidationMessageLabel.textColor = resultType.textColor
        inputNickNameTextField.layer.borderWidth = 1.0
        inputNickNameTextField.layer.borderColor = resultType.borderColor.cgColor
    }
    
    public func updateCollegeItems(_ items: [String]) {
        collegeDropDownView.updateItems(items)
    }

    public func updateDepartmentItems(_ items: [String]) {
        departmentDropDownView.updateItems(items)
    }
}

// MARK: - UITextFieldDelegate

extension SetNickNameView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
