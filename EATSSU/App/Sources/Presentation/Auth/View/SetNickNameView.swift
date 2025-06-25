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

    // MARK: - UI Components

    // 닉네임 설정
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
    
    // 소속 설정
    private let affiliationLabel: UILabel = {
        let label = UILabel()
        label.text = "소속 설정"
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
        return label
    }()

    public let collegeSelectButton: UIButton = {
        let button = UIButton()
        button.setTitle("단과대", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray100.color
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray300.color.cgColor
        return button
    }()

    public let departmentSelectButton: UIButton = {
        let button = UIButton()
        button.setTitle("학과", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray100.color
        button.layer.cornerRadius = 8
        button.layer.borderWidth = 1
        button.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray300.color.cgColor
        return button
    }()

    private lazy var affiliationStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            collegeSelectButton,
            departmentSelectButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 12
        return stackView
    }()

    // 연결 계정
    private let connectedAccountLabel: UILabel = {
        let label = UILabel()
        label.text = "연결된 계정"
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
        return label
    }()

    public let connectedProviderLabel: UILabel = {
        let label = UILabel()
        label.text = "APPLE" // 예시, 동적으로 설정 가능
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
        return label
    }()

    private let appleIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.signWithApple.image
        imageView.contentMode = .scaleAspectFit
        return imageView
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
    }

    // MARK: - Functions

    override func configureUI() {
        addSubviews(
            nickNameLabel,
            setNickNameStackView,
            nicknameDoubleCheckButton,
            affiliationLabel,
            affiliationStackView,
            connectedAccountLabel,
            connectedProviderLabel,
            appleIconImageView,
            completeSettingNickNameButton
        )
    }

    override func setLayout() {
        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(16)
            $0.leading.equalToSuperview().inset(24)
        }
        setNickNameStackView.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(20)
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
        affiliationLabel.snp.makeConstraints {
            $0.top.equalTo(setNickNameStackView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(24)
        }

        affiliationStackView.snp.makeConstraints {
            $0.top.equalTo(affiliationLabel.snp.bottom).offset(8)
            $0.horizontalEdges.equalToSuperview().inset(24)
        }

        collegeSelectButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }
        departmentSelectButton.snp.makeConstraints {
            $0.height.equalTo(48)
        }

        connectedAccountLabel.snp.makeConstraints {
            $0.top.equalTo(affiliationStackView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().inset(24)
        }

        connectedProviderLabel.snp.makeConstraints {
            $0.centerY.equalTo(connectedAccountLabel)
            $0.trailing.equalTo(appleIconImageView.snp.leading).offset(-4)
        }

        appleIconImageView.snp.makeConstraints {
            $0.centerY.equalTo(connectedAccountLabel)
            $0.trailing.equalToSuperview().inset(24)
            $0.width.height.equalTo(20)
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
