import UIKit
import SnapKit
import Then
import EATSSUDesign

final class SetNickNameView: BaseUIView {
    // MARK: - Properties

    private var viewModel: SetNickNameViewModel!

    // MARK: - UI Components

    private let nickNameLabel = UILabel().then {
        $0.text = "EAT-SSU에서 사용할\n닉네임을 설정해 주세요"
        $0.numberOfLines = 2
        $0.font = EATSSUFontFamily.Pretendard.bold.font(size: 18)
    }

    public let inputNickNameTextField = ESTextField(placeholder: TextLiteral.inputNickName)

    public var nicknameDoubleCheckButton = ESButton(size: .small, title: "중복 확인").then { esButton in
        esButton.isEnabled = false
    }

    public var nicknameValidationMessageLabel = UILabel().then {
        $0.text = TextLiteral.hintInputNickName
        $0.textColor = EATSSUAsset.Color.GrayScale.gray400.color
        $0.font = EATSSUFontFamily.Pretendard.regular.font(size: 12)
    }

    private lazy var setNickNameStackView: UIStackView = UIStackView(
        arrangedSubviews: [
            inputNickNameTextField,
            nicknameValidationMessageLabel,
        ]
    ).then {
        $0.axis = .vertical
        $0.spacing = 8.0
    }

    public var completeSettingNickNameButton = ESButton(size: .big, title: "완료하기").then { esButton in
        esButton.isEnabled = false
    }

    // MARK: - init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setTextFieldDelegate()
    }

    // MARK: Functions

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

    func bindViewModel(_ viewModel: SetNickNameViewModel) {
        self.viewModel = viewModel
        setupBindings()
    }

    private func setupBindings() {
        viewModel.nicknameValidationMessage.bind { [weak self] message in
            self?.nicknameValidationMessageLabel.text = message
        }

        viewModel.nicknameValidationTextColor.bind { [weak self] color in
            self?.nicknameValidationMessageLabel.textColor = color
        }

        viewModel.isNicknameValid.bind { [weak self] isValid in
            self?.nicknameDoubleCheckButton.isEnabled = isValid
        }

        viewModel.isCompleteButtonEnabled.bind { [weak self] isEnabled in
            self?.completeSettingNickNameButton.isEnabled = isEnabled
        }
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
        viewModel.validateNickname(inputValue)
    }

    func textFieldShouldClear(_: UITextField) -> Bool {
        viewModel.resetValidation()
        return true
    }
}
