//
//  SetNickNameViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/04.
//

import UIKit

import Moya

final class SetNickNameViewController: BaseViewController {
    // MARK: - Properties

    var currentKeyboardHeight: CGFloat = 0.0
    private let nicknameProvider = MoyaProvider<UserNicknameRouter>(session: Session(interceptor: AuthInterceptor.shared))
    private let myProvider = MoyaProvider<MyRouter>(session: Session(interceptor: AuthInterceptor.shared))
    private var originalNickname: String?
    private var originalDepartmentName: String?
    private var isNicknameChecked: Bool = false
    
    // MARK: - UI Components
    
    private let setNickNameView = SetNickNameView()
    private var colleges: [LookupItemDTO] = []
    private var departments: [LookupItemDTO] = []

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboard()
        bindDropdownCallbacks()
        fetchColleges()
        
        setNickNameView.inputNickNameTextField.addTarget(self,
                                                         action: #selector(nicknameTextFieldDidChange),
                                                         for: .editingChanged)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNickNameView.setAccountInfo()
    }

    override func viewWillDisappear(_: Bool) {
        removeKeyboardNotifications()
    }

    // MARK: - Functions

    override func configureUI() {
        view.addSubviews(setNickNameView)
    }

    override func setLayout() {
        setNickNameView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = TextLiteral.setNickName
    }

    override func setButtonEvent() {
        setNickNameView.completeSettingNickNameButton.addTarget(self, action: #selector(tappedCompleteNickNameButton), for: .touchUpInside)
        setNickNameView.nicknameDoubleCheckButton.addTarget(self, action: #selector(tappedCheckButton), for: .touchUpInside)
    }
    
    private func bindDropdownCallbacks() {
        setNickNameView.onSelectCollege = { [weak self] collegeName in
            guard let self,
                  let id = self.colleges.first(where: { $0.name == collegeName })?.id
            else { return }
            self.fetchDepartments(collegeId: id)
            self.updateSaveButtonState()
        }
        setNickNameView.onSelectDepartment = { [weak self] departmentName in
            self?.updateSaveButtonState()
        }
    }
    
    private func populateUIWithSavedData() {
            guard let userInfo = UserInfoManager.shared.getCurrentUserInfo() else { return }
            
            self.originalNickname = userInfo.nickname
            self.originalDepartmentName = userInfo.departmentName
                
            setNickNameView.inputNickNameTextField.text = userInfo.nickname
            setNickNameView.nicknameDoubleCheckButton.isEnabled = false
            setNickNameView.completeSettingNickNameButton.isEnabled = false
                
            if let collegeName = userInfo.collegeName,
            let collegeId = self.colleges.first(where: { $0.name == collegeName })?.id {
            setNickNameView.collegeDropDownView.setTitle(collegeName)
            
            fetchDepartments(collegeId: collegeId) { [weak self] in
                if let departmentName = userInfo.departmentName {
                    self?.setNickNameView.departmentDropDownView.setTitle(departmentName)
                }
            }
        }
    }

    @objc
    func tappedCompleteNickNameButton() {
        let newNickname = setNickNameView.inputNickNameTextField.text ?? ""
        let selectedDepartmentName = setNickNameView.departmentDropDownView.getSelectedTitle()
        
        let hasNicknameChanged = newNickname != self.originalNickname
        let hasDepartmentChanged = selectedDepartmentName != self.originalDepartmentName && selectedDepartmentName != nil
        
        // 변경 사항이 없으면 함수를 종료합니다. (버튼 비활성화 로직으로 인해 호출될 일은 없지만, 안전장치)
        guard hasNicknameChanged || hasDepartmentChanged else {
            print("변경된 정보가 없습니다.")
            return
        }

        let dispatchGroup = DispatchGroup()
        var isNicknameUpdateSuccess = true
        var isDepartmentUpdateSuccess = true

        // 1. 닉네임이 변경되었을 경우에만 닉네임 설정 API 호출
        if hasNicknameChanged {
            dispatchGroup.enter()
            setUserNickname(newNickname) { success in
                isNicknameUpdateSuccess = success
                dispatchGroup.leave()
            }
        }

        // 2. 소속 학과가 변경되었을 경우에만 학과 설정 API 호출
        if hasDepartmentChanged {
            guard let departmentName = selectedDepartmentName,
                  let departmentId = self.departments.first(where: { $0.name == departmentName })?.id else {
                print("유효하지 않은 학과 정보입니다.")
                return
            }
            dispatchGroup.enter()
            setUserDepartment(departmentId: departmentId) { success in
                isDepartmentUpdateSuccess = success
                dispatchGroup.leave()
            }
        }
        
        // 3. 모든 API 호출이 완료된 후, 결과에 따라 처리
        dispatchGroup.notify(queue: .main) {
            if isNicknameUpdateSuccess && isDepartmentUpdateSuccess {
                self.showCompletionAlert()
            } else {
                // 각 API 호출 실패 시 이미 로그인 화면으로 전환하는 로직이 있으므로,
                // 여기서는 별도 처리가 필요하지 않습니다.
                print("정보 업데이트 중 오류가 발생했습니다.")
            }
        }
    }
    
    @objc
    private func nicknameTextFieldDidChange(_ textField: UITextField) {
        let newNickname = textField.text ?? ""
        let isNicknameChanged = (newNickname != originalNickname)
        
        // 닉네임이 변경되었다면, 중복 확인 상태를 초기화합니다.
        if isNicknameChanged {
            self.isNicknameChecked = false
        }
        
        // 닉네임이 비어있는 경우
        if newNickname.isEmpty {
            setNickNameView.nicknameValidationMessageLabel.text = NicknameTextFieldResultType.textFieldEmpty.hintMessage
            setNickNameView.nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.textFieldEmpty.textColor
            setNickNameView.nicknameDoubleCheckButton.isEnabled = false
        // 글자 수 유효성 검사 (2~8자)
        } else if !(2...8).contains(newNickname.count) {
            setNickNameView.nicknameValidationMessageLabel.text = NicknameTextFieldResultType.nicknameTextFieldOver.hintMessage
            setNickNameView.nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldOver.textColor
            setNickNameView.nicknameDoubleCheckButton.isEnabled = false
        // 닉네임이 변경되었고, 글자 수도 유효한 경우
        } else if isNicknameChanged {
            setNickNameView.nicknameValidationMessageLabel.text = NicknameTextFieldResultType.nicknameTextFieldDoubleCheck.hintMessage
            setNickNameView.nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldDoubleCheck.textColor
            setNickNameView.nicknameDoubleCheckButton.isEnabled = true
        // 닉네임이 원래대로 돌아온 경우
        } else {
            setNickNameView.nicknameValidationMessageLabel.text = "" // 안내 문구 없음
            setNickNameView.nicknameDoubleCheckButton.isEnabled = false
        }
        
        updateSaveButtonState()
    }
    
    private func updateSaveButtonState() {
        let nicknameText = setNickNameView.inputNickNameTextField.text ?? ""
        let selectedDepartment = setNickNameView.departmentDropDownView.getSelectedTitle()

        // 조건 1: 닉네임 상태가 유효한가? (원래 닉네임이거나, 변경 후 중복 확인을 통과했거나)
        let isNicknameStateValid = (nicknameText == originalNickname) || isNicknameChecked
        
        // 조건 2: 무언가 변경되었는가? (닉네임이 다르거나, 학과가 다르거나)
        let hasNicknameChanged = (nicknameText != originalNickname)
        let hasDepartmentChanged = (selectedDepartment != originalDepartmentName) && (selectedDepartment != nil)
        
        // 최종 결정: 닉네임 상태가 유효하고, 무언가 변경되었을 때만 '저장하기' 버튼 활성화
        setNickNameView.completeSettingNickNameButton.isEnabled = isNicknameStateValid && (hasNicknameChanged || hasDepartmentChanged)
    }
    
    @objc
    private func tappedCheckButton() {
        checkNickname(nickname: setNickNameView.inputNickNameTextField.text ?? "")
    }

    // MARK: - keyboard 감지

    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }

    @objc
    func keyboardWillShow(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let updateKeyboardHeight = keyboardSize.height
            let difference = updateKeyboardHeight - currentKeyboardHeight

            setNickNameView.completeSettingNickNameButton.frame.origin.y -= difference
            currentKeyboardHeight = updateKeyboardHeight
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            setNickNameView.completeSettingNickNameButton.frame.origin.y += currentKeyboardHeight
            currentKeyboardHeight = 0.0
        }
    }
    
    private func navigateToLogin() {
        let loginVC = LoginViewController()
        loginVC.toastMessage = "세션이 만료되었습니다. 다시 로그인해주세요."
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.replaceRootViewController(UINavigationController(rootViewController: loginVC))
            }
        }
    }
}

// MARK: - Network

extension SetNickNameViewController {
    private func setUserNickname(_ nickname: String, completion: @escaping (Bool) -> Void) {
        nicknameProvider.request(.setNickname(nickname: nickname)) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                if let user = UserInfoManager.shared.getCurrentUserInfo() {
                    UserInfoManager.shared.updateNickname(for: user, nickname: nickname)
                }
                completion(true)
            case .failure:
                RealmService.shared.resetDB()
                self.navigateToLogin()
                completion(false)
            }
        }
    }

    private func checkNickname(nickname: String) {
        nicknameProvider.request(.checkNickname(nickname: nickname)) { response in
            switch response {
            case let .success(moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<Bool>.self)
                    guard let data = responseData.result else { return }
                    
                    if data {
                        self.view.showToast(message: "사용 가능한 닉네임이에요")
                        self.setNickNameView.setNicknameChecked(true)
                        self.setNickNameView.nicknameValidationMessageLabel.text = NicknameTextFieldResultType.nicknameTextFieldValid.hintMessage
                        self.setNickNameView.nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldValid.textColor
                        self.setNickNameView.completeSettingNickNameButton.isEnabled = true
                        self.isNicknameChecked = true
                    } else {
                        self.view.showToast(message: "이미 사용 중인 닉네임이에요")
                        self.setNickNameView.completeSettingNickNameButton.isEnabled = data
                        self.setNickNameView.nicknameValidationMessageLabel.text = NicknameTextFieldResultType.nicknameTextFieldDuplicated.hintMessage
                        self.setNickNameView.nicknameValidationMessageLabel.textColor = NicknameTextFieldResultType.nicknameTextFieldDuplicated.textColor
                        self.isNicknameChecked = false
                    }
                    self.updateSaveButtonState()
                    
                } catch let err {
                    print(err.localizedDescription)
                    
                    RealmService.shared.resetDB()
                    self.navigateToLogin()
                }
            case let .failure(err):
                print(err.localizedDescription)
                
                RealmService.shared.resetDB()
                self.navigateToLogin()
            }
        }
    }
    
    private func setUserDepartment(departmentId: Int, completion: @escaping (Bool) -> Void) {
        nicknameProvider.request(.setDepartment(departmentId: departmentId)) { result in
            switch result {
            case .success:
                print("학과 등록 성공: ID \(departmentId)")
                if let user = UserInfoManager.shared.getCurrentUserInfo() {
                    let collegeName = self.setNickNameView.collegeDropDownView.getSelectedTitle()
                    let departmentName = self.setNickNameView.departmentDropDownView.getSelectedTitle()
                    let collegeId = self.colleges.first(where: { $0.name == collegeName })?.id
                    
                    UserInfoManager.shared.updateDepartment(for: user,
                                                            collegeId: collegeId,
                                                            collegeName: collegeName,
                                                            departmentId: departmentId,
                                                            departmentName: departmentName)
                }
                completion(true)
            case .failure(let error):
                print("학과 등록 실패: \(error.localizedDescription)")
                RealmService.shared.resetDB()
                self.navigateToLogin()
                completion(false)
            }
        }
    }
    
    private func fetchColleges() {
        myProvider.request(.colleges) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(res):
                do {
                   let decoded = try res.map(CollegesResponseDTO.self)
                   let list = decoded.result ?? []
                   self.colleges = list
                   self.setNickNameView.updateCollegeItems(list.map(\.name))
                   self.populateUIWithSavedData()
                } catch {
                    print("단과대 파싱 실패: \(error.localizedDescription)")
                }
            case let .failure(err):
                print("단과대 조회 실패: \(err.localizedDescription)")
            }
        }
    }

    private func fetchDepartments(collegeId: Int, completion: (() -> Void)? = nil) {
        myProvider.request(.departments(collegeId: collegeId)) { [weak self] result in
            guard let self else { return }
            switch result {
            case let .success(res):
                do {
                    let decoded = try res.map(DepartmentsResponseDTO.self)
                    let list = decoded.result ?? []
                    self.departments = list
                    self.setNickNameView.updateDepartmentItems(list.map(\.name))
                    completion?()
                } catch {
                    print("학과 파싱 실패: \(error.localizedDescription)")
                    completion?()
                }
            case let .failure(err):
                print("학과 조회 실패: \(err.localizedDescription)")
                completion?()
            }
        }
    }
    
    private func showCompletionAlert() {
        self.showAlertController(title: "완료",
                                 message: "정보 수정이 완료되었습니다.",
                                 style: .cancel) {
            if let myPageVC = self.navigationController?
                .viewControllers
                .first(where: { $0 is MyPageViewController }) {
                self.navigationController?.popToViewController(myPageVC, animated: true)
            } else {
                let homeVC = HomeViewController()
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    keyWindow.replaceRootViewController(
                        UINavigationController(rootViewController: homeVC)
                    )
                }
            }
        }
    }
}
