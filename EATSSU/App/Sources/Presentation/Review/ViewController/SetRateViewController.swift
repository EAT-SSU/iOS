//
//  SetRateViewController.swift
//  EatSSU-iOS
//
//  Created by 한금준 on 29/11/25.
//

import UIKit
import SnapKit
import Moya

import EATSSUDesign

final class SetRateViewController: BaseViewController, UINavigationControllerDelegate {
    
    // MARK: - Properties
    override var shouldHideTabBar: Bool { true }

    private var reviewType: ReviewType = .variable
    private var mealID: Int?
    private var menuID: Int?
    private var reviewId: Int?

    private var validMenuIDList: [Int] = []
    private var selectedList: [String] = []
    private var likedStates: [Bool] = []
    private var userPickedImage: UIImage?

    private var isReviewSubmitted = false
    
    
    enum ReviewType {
        case fixed
        case variable
    }
    
    // MARK: - UI Components

    private let setRateView = SetRateView()
    private let imagePickerController = UIImagePickerController()
    
    // MARK: - Initializer
    
    init() {
        super.init(nibName: nil, bundle: nil)
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

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTappedImageView))
        setRateView.userReviewImageView.addGestureRecognizer(tapGesture)
    }
    
    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = reviewId != nil ? TextLiteral.Review.fixReview : TextLiteral.Review.leaveReview

        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = nil

        let closeImage = EATSSUDesignAsset.Images.icClose.image.withRenderingMode(.alwaysOriginal)

        let closeUIButton = UIButton(type: .system)
        closeUIButton.setImage(closeImage, for: .normal)
        closeUIButton.tintColor = .clear
        closeUIButton.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        closeUIButton.imageView?.contentMode = .scaleAspectFit

        if let imageView = closeUIButton.imageView {
            imageView.snp.makeConstraints { make in
                make.center.equalToSuperview()
                make.width.height.equalTo(12)
            }
        }

        closeUIButton.addTarget(self, action: #selector(didTapCustomBackButton), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeUIButton)
    }
    
    // MARK: - Setup & Delegate

    private func setupInitialDataFetch() {
        if reviewId == nil {
            if reviewType == .variable, let mealId = mealID {
                fetchValidMenus(mealId: mealId)
            } else if reviewType == .fixed {
                likedStates = [false]
                setRateView.menuTableView.reloadData()
            }
        }
    }

    private func setDelegates() {
        setRateView.menuTableView.register(MenuLikeCell.self, forCellReuseIdentifier: MenuLikeCell.identifier)
        setRateView.menuTableView.dataSource = self
        setRateView.menuTableView.delegate = self
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        setRateView.userReviewTextView.delegate = self
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    // MARK: - Data Binding

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

    func dataBindForFix(menuNames: [String], menuIds: [Int], likedStates: [Bool]) {
        self.selectedList = menuNames
        self.validMenuIDList = menuIds
        self.likedStates = likedStates
        self.reviewType = .fixed
        
        setRateView.menuLabel.text = TextLiteral.Review.recommendMenu(name: menuNames.first ?? "")
        setRateView.menuTableView.reloadData()
        view.setNeedsLayout()
    }

    func dataBindForFix(list: [String], reviewId: Int) {
        self.selectedList = list
        self.reviewId = reviewId
        self.likedStates = Array(repeating: false, count: list.count)
        
        setRateView.menuLabel.text = TextLiteral.Review.recommendMenu(name: list[0])
        setRateView.selectImageButton.isHidden = true
        setRateView.nextButton.setTitle(TextLiteral.Review.fixReviewComplete, for: .normal)
    }

    func dataBindForFix(
        list: [String],
        reviewId: Int,
        rating: Int?,
        content: String?,
        imageUrls: [String],
        menuIds: [Int],
        likedMenuIds: [Int]
    ) {
        self.selectedList = list
        self.reviewId = reviewId
        self.validMenuIDList = menuIds

        if menuIds.count == 1 {
            self.reviewType = .fixed
            self.menuID = menuIds.first
        } else {
            self.reviewType = .variable
        }
 
        self.likedStates = menuIds.map { menuId in
            likedMenuIds.contains(menuId)
        }

        setRateView.menuLabel.text = list.count == 1
            ? TextLiteral.Review.recommendMenu(name: list[0])
            : TextLiteral.Review.recommendMenuTitle

        if let rating = rating {
            setRateView.rateView.currentStar = rating
            setRateView.rateView.settingStarForFix(currentStar: rating)
        }

        if let content = content, !content.isEmpty {
            setRateView.userReviewTextView.text = content
            setRateView.userReviewTextView.textColor = .black
            setRateView.maximumWordLabel.text = TextLiteral.Review.characterCount(current: content.count, max: 300)
        }

        if let firstImageUrl = imageUrls.first, !firstImageUrl.isEmpty {
            setRateView.userReviewImageView.kfSetImage(url: firstImageUrl)
            setRateView.updateImageViewState(image: setRateView.userReviewImageView.image, count: 1, isHidden: false)
        } else {
            setRateView.updateImageViewState(image: nil, count: 0, isHidden: true)
        }
   
        setRateView.nextButton.setTitle(TextLiteral.Review.complete, for: .normal)
        setRateView.menuTableView.reloadData()
        view.setNeedsLayout()
    }
    
    /// 수정할 리뷰의 기존 내용을 화면에 표시
    func settingForReviewFix(data: ReviewListItem) {
        // 별점 설정
        setRateView.rateView.currentStar = Int(data.rating)
        setRateView.rateView.settingStarForFix(currentStar: Int(data.rating))
        
        // 리뷰 텍스트 설정
        setRateView.userReviewTextView.text = data.content ?? ""
        setRateView.userReviewTextView.textColor = .black
        setRateView.maximumWordLabel.text = "\(data.content?.count ?? 0) / 300"

        if let imageUrl = data.imageUrls.first, !imageUrl.isEmpty {
            setRateView.userReviewImageView.kfSetImage(url: imageUrl)
            setRateView.updateImageViewState(image: setRateView.userReviewImageView.image, count: 1, isHidden: false)
        } else {
            setRateView.updateImageViewState(image: nil, count: 0, isHidden: true)
        }

        if let menuLikes = data.menu {
            self.likedStates = validMenuIDList.map { menuId in
                return menuLikes.first(where: { $0.menuId == menuId })?.isLike ?? false
            }
        }
        setRateView.menuTableView.reloadData()
    }
    
    // MARK: - Menu Like Logic
    
    /// 리뷰 좋아요/취소 상태를 토글
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

    @objc func didSelectedImage() {
        present(imagePickerController, animated: true)
    }

    @objc func didTappedImageView() {
        userPickedImage = nil
        setRateView.updateImageViewState(image: nil, count: 0, isHidden: true)
    }
    
    // MARK: - Custom Back Button Action
    
    @objc private func didTapCustomBackButton() {
        checkReviewStatusAndConfirmExit { [weak self] shouldPop in
            guard let self = self else { return }
            
            if shouldPop {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - Review Submission Logic

    @objc
    func tappedNextButton() {
        guard !isReviewSubmitted else { return }

        guard setRateView.rateView.currentStar != 0 else {
            showToast(message: TextLiteral.Review.inputRating, type: .info)
            return
        }

        isReviewSubmitted = true
        setRateView.nextButton.isEnabled = false

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
    
    /// 리뷰 작성/수정 완료 후 이전 화면
    private func moveToReviewVC() {
        if let myReviewVC = navigationController?.viewControllers.first(where: { $0 is MyReviewViewController }) as? MyReviewViewController {
            navigationController?.popToViewController(myReviewVC, animated: true)
            return
        }

        if let reviewVC = navigationController?.viewControllers.first(where: { $0 is ReviewViewController }) as? ReviewViewController {
            reviewVC.setReviewSubmittedSuccessfully()
            navigationController?.popToViewController(reviewVC, animated: true)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                reviewVC.refreshAllData()
            }
            
            if let homeVC = navigationController?.viewControllers.first as? HomeViewController {
                homeVC.refreshAfterReview()
            }
            return
        }

        navigationController?.popViewController(animated: true)
    }
}

// MARK: - API Call & Logic

extension SetRateViewController {
    
    /// Meal(Variable) 리뷰 작성을 위한 유효 메뉴 목록을 요청
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
                    self.showToast(message: TextLiteral.Review.loadMenuListFail)
                }
            }
        }
    }
    
    private func sendFixReview() {
        guard let reviewId = reviewId else {
            showToast(message: TextLiteral.Review.noReviewInfoForFix)
            return
        }

        _Concurrency.Task {
            do {
                let menuLikes: [MenuLike] = validMenuIDList.enumerated().map { (index, menuId) in
                    MenuLike(menuId: menuId, isLike: likedStates[index])
                }

                let rawText = setRateView.userReviewTextView.text ?? ""
                let trimmedText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
                let content = trimmedText.isEmpty || trimmedText == placeholderText ? nil : trimmedText

                let request = FixedReviewRequestDTO(
                    rating: setRateView.rateView.currentStar,
                    menuLikes: menuLikes,
                    content: content ?? ""
                )
                
                try await postFixReview(reviewId: reviewId, request: request)
                
                await MainActor.run {
                    self.isReviewSubmitted = true
                    self.showToast(message: TextLiteral.Review.fixReviewSuccess)
                    self.moveToReviewVC()
                }
                
            } catch {
                await MainActor.run {
                    print("❌ Review 수정 업로드 실패: \(error)")
                    self.isReviewSubmitted = false
                    self.setRateView.nextButton.isEnabled = true
                    self.showToast(message: TextLiteral.Review.fixReviewFail)
                }
            }
        }
    }
    
    private func sendMealReview() {
        guard let mealId = mealID else {
            showToast(message: TextLiteral.Review.noMealInfo)
            return
        }

        let rawText = setRateView.userReviewTextView.text ?? ""
        let trimmedText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        let content = trimmedText.isEmpty || trimmedText == placeholderText ? nil : trimmedText

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
                    content: content,
                    imageUrls: imageUrl != nil ? [imageUrl!] : []
                )
                try await postMealReview(request: request)

                await MainActor.run {
                    self.isReviewSubmitted = true
                    self.moveToReviewVC()
                }

            } catch {
                await MainActor.run {
                    print("❌ Meal 리뷰 업로드 실패: \(error)")
                    self.isReviewSubmitted = false
                    self.setRateView.nextButton.isEnabled = true
                    self.showToast(message: TextLiteral.Review.uploadReviewFail)
                }
            }
        }
    }

    private func sendMenuReview() {
        guard let menuId = menuID ?? validMenuIDList.first else {
            showToast(message: TextLiteral.Review.noMenuInfo)
            return
        }

        let rawText = setRateView.userReviewTextView.text ?? ""
        let trimmedText = rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        let content = trimmedText.isEmpty || trimmedText == placeholderText ? nil : trimmedText

        _Concurrency.Task {
            do {
                var imageUrl: String?
                if let image = userPickedImage {
                    imageUrl = try await uploadImage(image: image)
                }

                let menuLike = MenuLike(
                    menuId: menuId,
                    isLike: likedStates.first ?? false
                )

                let request = WriteReviewMenuRequest(
                    rating: setRateView.rateView.currentStar,
                    menuLike: menuLike,
                    content: content,
                    imageUrls: imageUrl != nil ? [imageUrl!] : []
                )

                try await postMenuReview(request: request)

                await MainActor.run {
                    self.isReviewSubmitted = true
                    self.moveToReviewVC()
                }

            } catch {
                await MainActor.run {
                    print("❌ Menu 리뷰 업로드 실패: \(error)")
                    self.isReviewSubmitted = false
                    self.setRateView.nextButton.isEnabled = true
                    self.showToast(message: TextLiteral.Review.uploadReviewFail)
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

    private var placeholderText: String {
        return TextLiteral.Review.inputDetailReview
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

extension SetRateViewController: UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            userPickedImage = image
            setRateView.updateImageViewState(image: image, count: 1, isHidden: false)
        }
        picker.dismiss(animated: true)
    }
    
    private func checkReviewStatusAndConfirmExit(completion: @escaping (Bool) -> Void) {
        let textHasContent = setRateView.userReviewTextView.text != placeholderText && !(setRateView.userReviewTextView.text ?? "").isEmpty
        let isReviewStarted: Bool = setRateView.rateView.currentStar > 0 || textHasContent
        
        if reviewId == nil, isReviewStarted {
            let title = TextLiteral.Review.askLeave
            let message = TextLiteral.Review.leaveWarning
            self.showCustomDialog(
                title: title,
                message: message,
                cancelButtonTitle: TextLiteral.Review.leave,
                confirmButtonTitle: TextLiteral.Review.continueWriting,
                cancelAction: {
                    completion(true)
                }
            )
        } else {
            completion(true)
        }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == navigationController?.interactivePopGestureRecognizer else {
            return true
        }
        
        let textHasContent = setRateView.userReviewTextView.text != placeholderText
        && !(setRateView.userReviewTextView.text ?? "").isEmpty
        let isReviewStarted = setRateView.rateView.currentStar > 0 || textHasContent
        
        if reviewId == nil, isReviewStarted {
            checkReviewStatusAndConfirmExit { [weak self] shouldPop in
                guard let self = self else { return }
                if shouldPop {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            return false
        }
        return true
    }
}

// MARK: - Keyboard Handling

extension SetRateViewController {
    @objc func keyboardWillShow(_ noti: NSNotification) {
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height + self.view.safeAreaInsets.bottom)
                self.navigationController?.isNavigationBarHidden = true
            }
        }
    }

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
