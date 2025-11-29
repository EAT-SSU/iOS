//
//  SetRateViewController.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/03/23.
//

import UIKit
import SnapKit
import Moya

import EATSSUDesign

final class SetRateViewController: BaseViewController {
    
    // MARK: - Properties
    override var shouldHideTabBar: Bool {
        return true
    }
    
    // Data Model
    private var reviewType: ReviewType = .variable
    private var mealID: Int?
    private var menuID: Int?
    private var reviewId: Int? // 수정 시 사용되는 리뷰 ID
    
    // Review Data State
    private var validMenuIDList: [Int] = []
    private var selectedList: [String] = []
    private var likedStates: [Bool] = []
    private var userPickedImage: UIImage?
    
    // State Flags
    private var isReviewSubmitted = false
    
    enum ReviewType {
        case fixed // 단일 메뉴 리뷰
        case variable // 식단 리뷰 (여러 메뉴)
    }
    
    // MARK: - UI Components
    
    // Root View
    private let setRateView = SetRateView()
    private let imagePickerController = UIImagePickerController()
    
    // MARK: - Initializer
    
    init() {
        super.init(nibName: nil, bundle: nil)
        // 리뷰 수정 모드에서는 이 초기화를 사용하며, reviewType 등은 dataBindForFix에서 설정됩니다.
    }
    
    init(mealId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.mealID = mealId
        self.reviewType = .variable
    }
    
    init(menuId: Int) {
        super.init(nibName: nil, bundle: nil)
        self.menuID = menuId
        self.reviewType = .fixed
        self.validMenuIDList = [menuId]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegates()
        setupInitialDataFetch()
    }
    
    override func viewWillAppear(_: Bool) {
        addKeyboardNotifications()
        if navigationController?.isNavigationBarHidden == true {
            navigationController?.isNavigationBarHidden = false
        }
    }
    
    override func viewWillDisappear(_: Bool) {
        removeKeyboardNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 테이블뷰 content size에 따라 높이 제약조건 업데이트
        setRateView.menuTableViewHeightConstraint?.update(offset: setRateView.menuTableView.contentSize.height)
    }
    
    // MARK: - Configuration
    
    override func configureUI() {
        dismissKeyboard()
        view.addSubview(setRateView)
    }
    
    override func setLayout() {
        setRateView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func setButtonEvent() {
        setRateView.nextButton.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
        setRateView.selectImageButton.addTarget(self, action: #selector(didSelectedImage), for: .touchUpInside)
        setRateView.closeButton.addTarget(self, action: #selector(didTappedImageView), for: .touchUpInside)
        
        // 이미지 뷰 탭 제스처
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTappedImageView))
        setRateView.userReviewImageView.addGestureRecognizer(tapGesture)
    }
    
    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = reviewId != nil ? "리뷰 수정하기" : "리뷰 남기기"
    }
    
    // MARK: - Setup & Delegate
    
    /// 초기 데이터 (유효 메뉴 목록)를 가져오거나 기본 설정을 합니다.
    private func setupInitialDataFetch() {
        if reviewId == nil {
            if reviewType == .variable, let mealId = mealID {
                fetchValidMenus(mealId: mealId)
            } else if reviewType == .fixed {
                // Fixed 메뉴는 초기 좋아요 상태만 설정 (메뉴명은 DataBind에서 처리)
                likedStates = [false]
                setRateView.menuTableView.reloadData()
            }
        }
    }
    
    /// Delegate 및 DataSource를 설정합니다.
    private func setDelegates() {
        setRateView.menuTableView.register(MenuLikeCell.self, forCellReuseIdentifier: MenuLikeCell.identifier)
        setRateView.menuTableView.dataSource = self
        setRateView.menuTableView.delegate = self
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        setRateView.userReviewTextView.delegate = self
        
        self.navigationController?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    // MARK: - Data Binding
    
    /// 일반 리뷰 작성 시 메뉴 목록 데이터를 바인딩합니다.
    func dataBind(list: [String], idList: [Int]) {
        self.selectedList = list
        self.validMenuIDList = idList
        self.likedStates = Array(repeating: false, count: list.count)
        
        if idList.count == 1 {
            self.reviewType = .fixed
            self.menuID = idList.first
        } else {
            self.reviewType = .variable
        }
        
        setRateView.menuTableView.reloadData()
    }
    
    /// 리뷰 수정 (Fixed 타입) 시 데이터를 바인딩합니다. (사용되지 않으나 원본 유지)
    func dataBindForFix(menuNames: [String], menuIds: [Int], likedStates: [Bool]) {
        self.selectedList = menuNames
        self.validMenuIDList = menuIds
        self.likedStates = likedStates
        self.reviewType = .fixed
        
        setRateView.menuLabel.text = "\(menuNames.first ?? "") 을/를 추천하시겠어요?"
        setRateView.menuTableView.reloadData()
        view.setNeedsLayout()
    }
    
    /// 리뷰 수정 모드 시작 시 설정합니다. (리뷰 ID 바인딩)
    func dataBindForFix(list: [String], reviewId: Int) {
        self.selectedList = list
        self.reviewId = reviewId
        self.likedStates = Array(repeating: false, count: list.count)
        
        setRateView.menuLabel.text = "\(list[0]) 을/를 추천하시겠어요?"
        setRateView.selectImageButton.isHidden = true
        setRateView.deleteMethodLabel.isHidden = true
        setRateView.nextButton.setTitle("리뷰 수정 완료하기", for: .normal)
    }
    
    /// 수정할 리뷰의 기존 내용을 화면에 표시합니다.
    func settingForReviewFix(data: ReviewListItem) {
        // 별점 설정
        setRateView.rateView.currentStar = Int(data.rating)
        setRateView.rateView.settingStarForFix(currentStar: Int(data.rating))
        
        // 리뷰 텍스트 설정
        setRateView.userReviewTextView.text = data.content ?? ""
        setRateView.userReviewTextView.textColor = .black
        setRateView.maximumWordLabel.text = "\(data.content?.count ?? 0) / 300"
        
        // 이미지 설정 (kfSetImage는 Kingfisher 확장 가정)
        if let imageUrl = data.imageUrls?.first, !imageUrl.isEmpty {
            setRateView.userReviewImageView.kfSetImage(url: imageUrl)
            setRateView.updateImageViewState(image: setRateView.userReviewImageView.image, count: 1, isHidden: false)
        } else {
            setRateView.updateImageViewState(image: nil, count: 0, isHidden: true)
        }
        
        // 좋아요 상태 복원
        if let menuLikes = data.menu {
            self.likedStates = validMenuIDList.map { menuId in
                return menuLikes.first(where: { $0.menuId == menuId })?.isLike ?? false
            }
        }
        setRateView.menuTableView.reloadData()
    }
    
    // MARK: - Menu Like Logic
    
    /// 리뷰 좋아요/취소 상태를 토글합니다.
    private func toggleLike(for index: Int) {
        likedStates[index].toggle()
        let idx = IndexPath(row: index, section: 0)
        
        if let cell = setRateView.menuTableView.cellForRow(at: idx) as? MenuLikeCell {
            cell.dataBind(menu: selectedList[index], isLiked: likedStates[index])
        } else {
            setRateView.menuTableView.reloadRows(at: [idx], with: .none)
        }
    }
    
    // MARK: - Image Handling Actions
    
    /// 이미지 선택 버튼 탭 시 ImagePicker를 표시합니다.
    @objc func didSelectedImage() {
        let originalDelegate = self.navigationController?.delegate
        self.navigationController?.delegate = nil
        
        present(imagePickerController, animated: true) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.navigationController?.delegate = originalDelegate
            }
        }
    }
    
    /// 이미지 뷰 탭 또는 삭제 버튼 탭 시 이미지를 삭제합니다.
    @objc func didTappedImageView() {
        userPickedImage = nil
        setRateView.updateImageViewState(image: nil, count: 0, isHidden: true)
    }
    
    // MARK: - Review Submission Logic
    
    /// 리뷰 작성/수정 버튼 탭 시 호출됩니다.
    @objc
    func tappedNextButton() {
        
        // 1. 유효성 검증
        if setRateView.userReviewTextView.text == "메뉴에 대한 상세한 리뷰를 작성해주세요" || (setRateView.userReviewTextView.text ?? "").count < 3 {
            showToast(message: "리뷰를 3글자 이상 작성해주세요!", type: .info)
            return
        }
        
        guard setRateView.rateView.currentStar != 0 else {
            showToast(message: "별점을 입력해주세요!", type: .info)
            return
        }
        
        // 2. 리뷰 전송 분기
        if reviewId != nil {
            sendFixReview()
        } else {
            switch reviewType {
            case .variable:
                sendMealReview()
            case .fixed:
                sendMenuReview()
            }
        }
    }
    
    /// 리뷰 작성/수정 완료 후 ReviewViewController로 돌아갑니다.
    private func moveToReviewVC() {
        if let reviewVC = navigationController?.viewControllers.first(where: { $0 is ReviewViewController }) {
            navigationController?.popToViewController(reviewVC, animated: true)
            
            if let homeVC = navigationController?.viewControllers.first as? HomeViewController {
                homeVC.refreshAfterReview()
            }
        }
    }
}

// MARK: - API Call & Logic

extension SetRateViewController {
    
    /// Meal(Variable) 리뷰 작성을 위한 유효 메뉴 목록을 요청합니다.
    private func fetchValidMenus(mealId: Int) {
        NetworkService.shared.request(
            ReviewRouter.getValidMenusForReview(mealId),
            responseType: ReviewValidMenusResponse.self,
            useAuth: true
        ) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.selectedList = data.menuList.map { $0.name }
                    self.validMenuIDList = data.menuList.map { $0.menuId }
                    self.likedStates = Array(repeating: false, count: self.selectedList.count)
                    
                    self.setRateView.menuTableView.reloadData()
                    self.view.setNeedsLayout()
                    
                case .failure(let error):
                    print("❌ Error fetching valid menus: \(error)")
                    self.showToast(message: "메뉴 목록 조회에 실패했습니다.")
                }
            }
        }
    }
    
    private func sendFixReview() {
        guard let reviewId = reviewId else {
            showToast(message: "수정할 리뷰 정보가 없습니다.")
            return
        }
        
        _Concurrency.Task {
            do {
                let menuLikes: [MenuLike] = validMenuIDList.enumerated().map { (index, menuId) in
                    MenuLike(menuId: menuId, isLike: likedStates[index])
                }
                
                let request = FixedReviewRequestDTO(
                    rating: setRateView.rateView.currentStar,
                    menuLikes: menuLikes,
                    content: setRateView.userReviewTextView.text
                )
                
                try await postFixReview(reviewId: reviewId, request: request)
                
                await MainActor.run {
                    self.isReviewSubmitted = true
                    self.moveToReviewVC()
                    self.showToast(message: "리뷰가 성공적으로 수정되었습니다.")
                }
                
            } catch {
                await MainActor.run {
                    print("❌ Review 수정 업로드 실패: \(error)")
                    self.showToast(message: "리뷰 수정에 실패했습니다.")
                }
            }
        }
    }
    
    private func sendMealReview() {
        guard let mealId = mealID else {
            showToast(message: "식단 정보가 없습니다.")
            return
        }
        
        _Concurrency.Task {
            do {
                var imageUrl: String?
                if let image = userPickedImage {
                    imageUrl = try await uploadImage(image: image)
                }
                let menuLikes = validMenuIDList.enumerated().map { (index, menuId) in
                    MenuLike(menuId: menuId, isLike: likedStates[index])
                }
                
                let request = WriteReviewMealRequest(
                    mealId: mealId,
                    rating: setRateView.rateView.currentStar,
                    menuLikes: menuLikes,
                    content: setRateView.userReviewTextView.text,
                    imageUrls: imageUrl != nil ? [imageUrl!] : nil
                )
                try await postMealReview(request: request)
                
                await MainActor.run {
                    self.isReviewSubmitted = true
                    self.moveToReviewVC()
                    self.showToast(message: "리뷰가 성공적으로 작성되었습니다.")
                }
                
            } catch {
                await MainActor.run {
                    print("❌ Meal 리뷰 업로드 실패: \(error)")
                    self.showToast(message: "리뷰 업로드에 실패했습니다.")
                }
            }
        }
    }
    
    private func sendMenuReview() {
        guard let menuId = menuID ?? validMenuIDList.first else {
            showToast(message: "메뉴 정보가 없습니다.")
            return
        }
        
        _Concurrency.Task {
            do {
                var imageUrl: String?
                if let image = userPickedImage {
                    imageUrl = try await uploadImage(image: image)
                }
                
                let menuLike = MenuLikeItem(
                    menuId: menuId,
                    isLike: likedStates.first ?? false
                )
                
                let request = WriteReviewMenuRequest(
                    rating: setRateView.rateView.currentStar,
                    menuLike: menuLike,
                    content: setRateView.userReviewTextView.text,
                    imageUrls: imageUrl != nil ? [imageUrl!] : nil
                )
                
                try await postMenuReview(request: request)
                
                await MainActor.run {
                    self.isReviewSubmitted = true
                    self.moveToReviewVC()
                    self.showToast(message: "리뷰가 성공적으로 작성되었습니다.")
                }
                
            } catch {
                await MainActor.run {
                    print("❌ Menu 리뷰 업로드 실패: \(error)")
                    self.showToast(message: "리뷰 업로드에 실패했습니다.")
                }
            }
        }
    }
    
    // MARK: - Network Utility Methods (Private)
    
    private func postMenuReview(request: WriteReviewMenuRequest) async throws {
        try await withCheckedThrowingContinuation { continuation in
            NetworkService.shared.request(
                WriteReviewRouter.writeMenuReview(param: request),
                responseType: Bool.self,
                useAuth: true
            ) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func postMealReview(request: WriteReviewMealRequest) async throws {
        try await withCheckedThrowingContinuation { continuation in
            NetworkService.shared.request(
                WriteReviewRouter.writeMealReview(param: request),
                responseType: Bool.self,
                useAuth: true
            ) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func uploadImage(image: UIImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            NetworkService.shared.request(
                WriteReviewRouter.uploadImage(image: image),
                responseType: UploadImageResponse.self,
                useAuth: true
            ) { result in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data.url)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    private func postFixReview(reviewId: Int, request: FixedReviewRequestDTO) async throws {
        try await withCheckedThrowingContinuation { continuation in
            NetworkService.shared.request(
                WriteReviewRouter.fixReview(reviewId: reviewId, param: request),
                responseType: Bool.self,
                useAuth: true
            ) { result in
                switch result {
                case .success:
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource & Delegate

extension SetRateViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuLikeCell.identifier, for: indexPath) as? MenuLikeCell else {
            return UITableViewCell()
        }
        
        cell.dataBind(menu: selectedList[indexPath.row], isLiked: likedStates[indexPath.row])
        
        // Controller가 Cell의 좋아요 탭 이벤트를 처리합니다.
        cell.onLikeTapped = { [weak self] in
            guard let self else { return }
            self.toggleLike(for: indexPath.row)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        toggleLike(for: indexPath.row)
    }
}

// MARK: - UITextViewDelegate

extension SetRateViewController: UITextViewDelegate {
    
    // 플레이스홀더 텍스트
    private var placeholderText: String {
        return "메뉴에 대한 상세한 리뷰를 작성해주세요"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let finalLength = currentText.count + text.count - range.length
        
        if finalLength > 300 { return false }
        
        let textToDisplay = currentText.replacingCharacters(in: stringRange, with: text)
        setRateView.maximumWordLabel.text = "\(textToDisplay.count) / 300"
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            setRateView.setInitialTextViewState()
        } else {
            setRateView.maximumWordLabel.text = "\(textView.text.count) / 300"
        }
    }
}

// MARK: - ImagePicker & Navigation Delegate

extension SetRateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            userPickedImage = image
            setRateView.updateImageViewState(image: image, count: 1, isHidden: false)
        }
        picker.dismiss(animated: true)
    }
    
    // 뒤로가기 제스처 및 버튼 탭 시 리뷰 작성 여부 확인 로직
    private func checkReviewStatusAndConfirmExit() -> Bool {
        let textHasContent = setRateView.userReviewTextView.text != placeholderText && !(setRateView.userReviewTextView.text ?? "").isEmpty
        let isReviewStarted: Bool = setRateView.rateView.currentStar > 0 || textHasContent
        
        if reviewId == nil, isReviewStarted {
            
            let title = "작성 취소"
            let message = "작성 중인 리뷰는 저장되지 않습니다. 정말 나가시겠습니까?"
            let confirmButtonTitle = "나가기"
            let cancelButtonTitle = "계속 작성"
            
            self.showCustomDialog(
                title: title,
                message: message,
                cancelButtonTitle: cancelButtonTitle,
                confirmButtonTitle: confirmButtonTitle
            ) { [weak self] in
                // 다이얼로그에서 '나가기' 선택 시 실제로 pop
                self?.navigationController?.popViewController(animated: true)
            }
            return false // Pop 방지
        }
        return true // Pop 허용
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if isReviewSubmitted { return }
        if navigationController is UIImagePickerController { return }
        
        let isPopping = !navigationController.viewControllers.contains(self)
        if isPopping {
            navigationController.viewControllers.append(self)
            
            if checkReviewStatusAndConfirmExit() {
                navigationController.delegate = nil
                navigationController.popViewController(animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.navigationController?.delegate = self
                }
            }
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return checkReviewStatusAndConfirmExit()
    }
}

// MARK: - Keyboard Handling

extension SetRateViewController {
    // 키보드 등장 시 View를 위로 올립니다.
    @objc func keyboardWillShow(_ noti: NSNotification) {
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height + self.view.safeAreaInsets.bottom)
                self.navigationController?.isNavigationBarHidden = true
            }
        }
    }
    
    // 키보드 사라질 때 View를 원래 위치로 되돌립니다.
    @objc func keyboardWillHide(_: NSNotification) {
        view.transform = .identity
        navigationController?.isNavigationBarHidden = false
    }
    
    func addKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}
