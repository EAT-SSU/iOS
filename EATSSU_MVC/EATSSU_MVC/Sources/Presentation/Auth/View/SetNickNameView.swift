//
//  SetNickNameView.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/03.
//

import UIKit

import SnapKit
import Then

import EATSSUDesign

/*
 해야 할 일
 - 관심사 분리 명확히 하기
 - View에 컨트롤러나 모델에서 사용하는 영역들이 있으면 안됨
 - 데이터 프로퍼티와 닉네임 유효성 검사는 컨트롤러와 모델로 이관
 */

final class SetNickNameView: BaseUIView {
    // MARK: - Properties

    private var userNickname: String = ""

    // MARK: - UI Components

    /// "EAT-SSU에서 사용할 닉네임을 설정해 주세요" 레이블
    private let nickNameLabel = UILabel().then {
        $0.text = "EAT-SSU에서 사용할\n닉네임을 설정해 주세요"
        $0.numberOfLines = 2
        $0.font = EATSSUFontFamily.Pretendard.bold.font(size: 18)
    }

    /*
     /// 닉네임 입력 텍스트필드
       public let inputNickNameTextField = UITextField().then {
           $0.placeholder = TextLiteral.inputNickName
         $0.font = EATSSUFontFamily.Pretendard.medium.font(size: 14)
         $0.backgroundColor = EATSSUAsset.Color.GrayScale.gray100.color
           $0.textColor = .black
           $0.setRoundBorder()
           $0.addLeftPadding()
           $0.clearButtonMode = .whileEditing
       }
     */

    /// 닉네임 입력 텍스트필드
    public let inputNickNameTextField = ESTextField(placeholder: TextLiteral.inputNickName).then { _ in
        /*
         해야 할 일
         - 현재 ESTextField로서는 크게 문제가 없는데, 혹시 모르는 추가 설정이 놓친 게 없나 검토 필요
         */
    }

    /*
     /// "중복확인" 버튼
     ///
     /// 해당 버튼 프로퍼티는 구 버전입니다.
     /// ESButton 클래스를 모듈로 분리했습니다.
     /// 혹시 모를 버그를 위해서 주석처리해 두겠습니다.
     public var nicknameDoubleCheckButton = PostUIButton().then {
         $0.setRoundBorder(borderColor: EATSSUAsset.Color.Main.primary.color, borderWidth: 0, cornerRadius: 10)
         $0.addTitleAttribute(
           title: "중복 확인",
           titleColor: .white,
           fontName: EATSSUFontFamily.Pretendard.bold.font(size: 14)
         )
           $0.isEnabled = false
       }
       */

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

    /*
      /// "완료하기" 버튼
      ///
      /// 해당 버튼 프로퍼티는 구 버전입니다.
      /// ESButton 클래스를 모듈로 분리했습니다.
      /// 혹시 모를 버그를 위해서 주석처리해 두겠습니다.
     public var completeSettingNickNameButton = PostUIButton().then {
           $0.addTitleAttribute(
             title: TextLiteral.completeLabel,
             titleColor: .white,
             fontName: EATSSUFontFamily.Pretendard.bold.font(size: 18)
           )
         $0.setRoundBorder(
           borderColor: EATSSUAsset.Color.Main.primary.color,
           borderWidth: 0,
           cornerRadius: 10
         )
           $0.isEnabled = false
       }
     */

    /// "완료하기" 버튼
    public var completeSettingNickNameButton = ESButton(size: .big, title: "완료하기").then { esButton in
        /*
         해야 할 일
         - 초기 버튼의 세팅값을 false로 주는 항목은 ESButton 초기화 값으로 할당하고 싶다.
         - 하지만 계산된 프로퍼티로 설계되어 있어서 어떻게 해야 할 지 모르겠다.
         */
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
}

// MARK: - UITextFieldDelegate

extension SetNickNameView: UITextFieldDelegate {
    /// return 클릭 시, 키보드 내려감

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    /// textFiled 유효성 검사

    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let inputValue = textField.text?.trimmingCharacters(in: .whitespaces) else { return }

        if inputValue.isEmpty {
            textFieldSettingWhenEmpty(textField)
            return
        }
        checkNicknameValidation(textField)
    }

    /// clearButton delegate

    func textFieldShouldClear(_: UITextField) -> Bool {
        nicknameDoubleCheckButton.isEnabled = false
        completeSettingNickNameButton.isEnabled = false
        return true
    }
}

// MARK: - Validation userInfo

private extension SetNickNameView {
    /// 입력 없는 경우

    func textFieldSettingWhenEmpty(_: UITextField) {
        nicknameValidationMessageLabel.text = NicknameTextFieldResultType.textFieldEmpty.hintMessage
        nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.textFieldEmpty.textColor
    }

    /// 닉네임 형식 검사

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

    /// Input 변경 시

    func nicknameInputChanged(nickname: String) -> Bool {
        /// 텍스트 변경 시, 완료하기 버튼 false 처리
        completeSettingNickNameButton.isEnabled = false

        if nickname.count > 1 && nickname.count < 9 {
            nicknameDoubleCheckButton.isEnabled = true
            return true
        } else {
            nicknameDoubleCheckButton.isEnabled = false
            return false
        }
    }
}
