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
    
    private var userPickedImage: UIImage?
    
    private var validMenuIDList: [Int] = []
    private var selectedList: [String] = []
    private var reviewId: Int?
    
    private var likedStates: [Bool] = []
    private var menuTableViewHeightConstraint: Constraint?
    
    private var reviewType: ReviewType = .variable
    private var mealID: Int?
    private var menuID: Int?
    
    private var isReviewSubmitting = false
    private var isReviewSubmitted = false
    
    enum ReviewType {
        case fixed
        case variable
    }
    
    // MARK: - Initializer
    
    convenience init(mealId: Int) {
        self.init(nibName: nil, bundle: nil)
        self.mealID = mealId
        self.reviewType = .variable
    }
    
    convenience init(menuId: Int) {
        self.init(nibName: nil, bundle: nil)
        self.menuID = menuId
        self.reviewType = .fixed
    }
    
    // MARK: - UI Components
    
    private var rateView = RateView()
    private let imagePickerController = UIImagePickerController()
    
    private var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private var menuLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘의 식사는 어떠셨나요?"
        label.font = .subtitle1
        label.textColor = .black
        return label
    }()
    
    private var detailLabel: UILabel = {
        let label = UILabel()
        label.text = "추천하고 싶은 메뉴가 있나요?"
        label.font = .subtitle1
        label.textColor = .black
        return label
    }()
    
    private let menuTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private let userReviewTextView: UITextView = {
        let textView = UITextView()
        textView.font = .body1
        textView.layer.cornerRadius = 10.adjusted
        textView.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray100.color
        textView.layer.borderWidth = 1.adjusted
        textView.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray300.color.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 16.0.adjusted, left: 16.0.adjusted, bottom: 16.0.adjusted, right: 16.0.adjusted)
        textView.text = "메뉴에 대한 상세한 리뷰를 작성해주세요"
        textView.textColor = .gray500
        return textView
    }()
    
    private lazy var userReviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTappedImageView))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(didTappedImageView), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var selectImageButton: UIButton = {
        let button = UIButton()
        var config = UIButton.Configuration.plain()
        config.image = EATSSUDesignAsset.Images.addImageButton.image
        config.contentInsets = NSDirectionalEdgeInsets(top: -5, leading: 0, bottom: 5, trailing: 0)
        button.configuration = config
        button.addTarget(self, action: #selector(didSelectedImage), for: .touchUpInside)
        button.layer.borderWidth = 1
        button.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray500.color.cgColor
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        return button
    }()
    
    private let imageCountLabel: UILabel = {
        let label = UILabel()
        label.text = "사진 0/1"
        label.font = .caption3
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray500.color
        label.textAlignment = .center
        return label
    }()
    
    private let deleteMethodLabel: UILabel = {
        let label = UILabel()
        label.text = "사진 클릭 시, 삭제됩니다"
        label.font = .caption3
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray500.color
        return label
    }()
    
    private let maximumWordLabel: UILabel = {
        let label = UILabel()
        label.text = "0 / 300"
        label.font = .caption2
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray600.color
        return label
    }()
    
    private let buttonContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 0
        view.clipsToBounds = true
        return view
    }()
    
    private var nextButton: MainButton = {
        let button = MainButton()
        button.title = "리뷰 남기기"
        return button
    }()
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegate()
        
        if reviewType == .variable, let mealId = mealID {
            fetchValidMenus(mealId: mealId)
        } else if reviewType == .fixed {
            setupFixedMenuReview()
        } else if !selectedList.isEmpty {
            likedStates = Array(repeating: false, count: selectedList.count)
            menuTableView.reloadData()
        }
    }
    
    override func viewWillAppear(_: Bool) {
        addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_: Bool) {
        removeKeyboardNotifications()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        menuTableViewHeightConstraint?.update(offset: menuTableView.contentSize.height)
    }
    
    // MARK: - API Calls
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
                    self.menuTableView.reloadData()
                    self.view.setNeedsLayout()
                    
                case .failure(let error):
                    print("❌ Error fetching valid menus: \(error)")
                    self.showToast(message: "메뉴 목록 조회에 실패했습니다.")
                }
            }
        }
    }
    
    private func setupFixedMenuReview() {
        likedStates = [false]
        menuTableView.reloadData()
        view.setNeedsLayout()
    }
    
    // MARK: - UI Configuration
    
    override func configureUI() {
        dismissKeyboard()
        view.addSubviews(scrollView, buttonContainer)
        
        buttonContainer.addSubview(nextButton)
        scrollView.addSubview(contentView)
        contentView.addSubviews(
            rateView,
            menuLabel,
            detailLabel,
            menuTableView,
            userReviewTextView,
            maximumWordLabel,
            selectImageButton,
            imageCountLabel,
            userReviewImageView,
            closeButton,
            deleteMethodLabel
        )
    }
    
    override func setLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        buttonContainer.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-80)
            $0.bottom.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.top.equalToSuperview().offset(12)
        }
        
        contentView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(scrollView)
        }
        
        menuLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }
        
        rateView.snp.makeConstraints { make in
            make.top.equalTo(menuLabel.snp.bottom).offset(17)
            make.centerX.equalToSuperview()
            make.height.equalTo(36.12)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(rateView.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
        }
        
        menuTableView.snp.makeConstraints {
            $0.top.equalTo(detailLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(32)
            $0.trailing.equalToSuperview().offset(-32)
            menuTableViewHeightConstraint = $0.height.equalTo(0).constraint
        }
        
        userReviewTextView.snp.makeConstraints { make in
            make.top.equalTo(menuTableView.snp.bottom).offset(40)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(181)
        }
        
        maximumWordLabel.snp.makeConstraints { make in
            make.top.equalTo(userReviewTextView.snp.bottom).offset(7)
            make.trailing.equalTo(userReviewTextView)
        }
        
        selectImageButton.snp.makeConstraints {
            $0.top.equalTo(maximumWordLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(16) // 인셋 16으로 통일
            $0.width.height.equalTo(60)
        }
        
        imageCountLabel.snp.makeConstraints {
            $0.top.equalTo(selectImageButton.snp.bottom).offset(5)
            $0.centerX.equalTo(selectImageButton)
        }
        
        userReviewImageView.snp.makeConstraints {
            $0.top.equalTo(maximumWordLabel.snp.bottom).offset(15)
            $0.leading.equalTo(selectImageButton.snp.trailing).offset(13)
            $0.width.height.equalTo(60)
        }
        
        deleteMethodLabel.snp.makeConstraints {
            $0.top.equalTo(imageCountLabel.snp.bottom).offset(7)
            $0.leading.equalTo(selectImageButton)
            $0.bottom.equalTo(contentView.snp.bottom).offset(-100)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(userReviewImageView.snp.top).offset(-6)
            $0.trailing.equalTo(userReviewImageView.snp.trailing).offset(6)
            $0.size.equalTo(24)
        }
        
        for i in 0...4 {
            rateView.buttons[i].snp.makeConstraints { make in
                make.width.equalTo(29.3)
            }
        }
    }
    
    override func setButtonEvent() {
        nextButton.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
    }
    
    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = reviewId != nil ? "리뷰 수정하기" : "리뷰 남기기"
    }
    
    // MARK: - Data Binding
    
    func dataBind(list: [String], idList: [Int]) {
        selectedList = list
        validMenuIDList = idList
        likedStates = Array(repeating: false, count: list.count)
        
        if idList.count == 1 {
            reviewType = .fixed
            menuID = idList.first
        } else {
            reviewType = .variable
        }
        
        menuTableView.reloadData()
    }
    
    func dataBindForFix(menuNames: [String], menuIds: [Int], likedStates: [Bool]) {
        self.selectedList = menuNames
        self.validMenuIDList = menuIds
        self.likedStates = likedStates
        self.reviewType = .fixed
        
        menuLabel.text = "\(menuNames.first ?? "") 을/를 추천하시겠어요?"
        menuTableView.reloadData()
        view.setNeedsLayout()
    }
    
    func dataBindForFix(list: [String], reviewId: Int) {
        self.selectedList = list
        self.reviewId = reviewId
        self.likedStates = Array(repeating: false, count: list.count)
        
        menuLabel.text = "\(list[0]) 을/를 추천하시겠어요?"
        selectImageButton.isHidden = true
        deleteMethodLabel.isHidden = true
        nextButton.setTitle("리뷰 수정 완료하기", for: .normal)
    }
    
    func settingForReviewFix(data: ReviewListItem) {
        rateView.currentStar = Int(data.rating)
        rateView.settingStarForFix(currentStar: Int(data.rating))
        userReviewTextView.text = data.content ?? ""
        userReviewTextView.textColor = .black
        maximumWordLabel.text = "\(data.content?.count ?? 0) / 300"
        
        if let imageUrl = data.imageUrls?.first, !imageUrl.isEmpty {
            userReviewImageView.kfSetImage(url: imageUrl)
            imageCountLabel.text = "사진 1/1"
            closeButton.isHidden = false
        }
    }
    
    func setDelegate() {
        menuTableView.register(MenuLikeCell.self, forCellReuseIdentifier: MenuLikeCell.identifier)
        menuTableView.dataSource = self
        menuTableView.delegate = self
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        userReviewTextView.delegate = self
        
        self.navigationController?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    private func toggleLike(for index: Int) {
        likedStates[index].toggle()
        let idx = IndexPath(row: index, section: 0)
        
        if let cell = menuTableView.cellForRow(at: idx) as? MenuLikeCell {
            cell.dataBind(menu: selectedList[index], isLiked: likedStates[index])
        } else {
            menuTableView.reloadRows(at: [idx], with: .none)
        }
    }
    
    // MARK: - Actions
    
    @objc
    func tappedNextButton() {
        // 유효성 검증
        let reviewText = userReviewTextView.text ?? ""
        if reviewText == "메뉴에 대한 상세한 리뷰를 작성해주세요" || reviewText.count < 3 {
            showToast(message: "리뷰를 3글자 이상 작성해주세요!", type: .info)
            return
        }
        
        guard rateView.currentStar != 0 else {
            showToast(message: "별점을 입력해주세요!", type: .info)
            return
        }
        
        isReviewSubmitting = true
        
        if reviewId != nil {
            sendFixReview()
            return
        }
        
        switch reviewType {
        case .variable:
            sendMealReview()
        case .fixed:
            sendMenuReview()
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
                    rating: rateView.currentStar,
                    menuLikes: menuLikes,
                    content: userReviewTextView.text
                )
                
                try await postFixReview(reviewId: reviewId, request: request)
                
                await MainActor.run {
                    self.isReviewSubmitted = true
                    self.moveToReviewVC()
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
                    rating: rateView.currentStar,
                    menuLikes: menuLikes,
                    content: userReviewTextView.text,
                    imageUrls: imageUrl != nil ? [imageUrl!] : nil
                )
                try await postMealReview(request: request)
                
                await MainActor.run {
                    self.isReviewSubmitted = true
                    self.moveToReviewVC()
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
                    rating: rateView.currentStar,
                    menuLike: menuLike,
                    content: userReviewTextView.text,
                    imageUrls: imageUrl != nil ? [imageUrl!] : nil
                )
                
                try await postMenuReview(request: request)
                
                await MainActor.run {
                    self.isReviewSubmitted = true
                    self.moveToReviewVC()
                }
                
            } catch {
                await MainActor.run {
                    print("❌ Menu 리뷰 업로드 실패: \(error)")
                    self.showToast(message: "리뷰 업로드에 실패했습니다.")
                }
            }
        }
    }
    
    private func moveToReviewVC() {
        if let reviewVC = navigationController?.viewControllers.first(where: { $0 is ReviewViewController }) {
            navigationController?.popToViewController(reviewVC, animated: true)
            
            if let homeVC = navigationController?.viewControllers.first as? HomeViewController {
                homeVC.refreshAfterReview()
            }
        }
    }
    
    @objc func didSelectedImage() {
        let originalDelegate = self.navigationController?.delegate
        self.navigationController?.delegate = nil
        
        present(imagePickerController, animated: true) { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self?.navigationController?.delegate = originalDelegate
            }
        }
    }
    
    @objc func didTappedImageView() {
        userReviewImageView.image = nil
        userPickedImage = nil
        imageCountLabel.text = "사진 0/1"
        closeButton.isHidden = true
    }
}

// MARK: - Network

extension SetRateViewController {
    
    private func postMenuReview(request: WriteReviewMenuRequest) async throws {
        try await withCheckedThrowingContinuation { continuation in
            NetworkService.shared.request(
                WriteReviewRouter.writeMenuReview(param: request),
                responseType: Bool.self,
                useAuth: true
            ) { result in
                switch result {
                case .success:
                    print("✅ Menu Review 작성 성공")
                    continuation.resume()
                case .failure(let error):
                    print("❌ Menu Review 작성 실패: \(error)")
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
                    print("✅ Meal Review 작성 성공")
                    continuation.resume()
                case .failure(let error):
                    print("❌ Meal Review 작성 실패: \(error)")
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
                responseType: Bool.self, // 수정 성공 시 Bool (또는 BaseResponse의 result가 nil인 경우)
                useAuth: true
            ) { result in
                switch result {
                case .success:
                    print("✅ Review 수정 성공")
                    continuation.resume()
                case .failure(let error):
                    print("❌ Review 수정 실패: \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension SetRateViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[.originalImage] as? UIImage {
            userReviewImageView.image = image
            userPickedImage = image
            imageCountLabel.text = "사진 1/1"
            closeButton.isHidden = false
        }
        picker.dismiss(animated: true)
    }
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if isReviewSubmitted {
            return
        }
        
        if navigationController is UIImagePickerController {
            return
        }
        
        let isPopping = !navigationController.viewControllers.contains(self)
        
        if isPopping {
            let textHasContent = userReviewTextView.text != "메뉴에 대한 상세한 리뷰를 작성해주세요" && !userReviewTextView.text.isEmpty
            let isReviewStarted: Bool = rateView.currentStar > 0 || textHasContent
            
            if reviewId == nil, isReviewStarted {
                navigationController.viewControllers.append(self)
                
                let title = "작성 취소"
                let message = "작성 중인 리뷰는 저장되지 않습니다. 정말 나가시겠습니까?"
                let confirmButtonTitle = "나가기"
                let cancelButtonTitle = "계속 작성"
                
                showCustomDialog(
                    title: title,
                    message: message,
                    cancelButtonTitle: cancelButtonTitle,
                    confirmButtonTitle: confirmButtonTitle
                ) { [weak self] in
                    guard let self = self else { return }
                    self.navigationController?.delegate = nil
                    self.navigationController?.popViewController(animated: true)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.navigationController?.delegate = self
                    }
                }
            }
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let isReviewStarted: Bool = rateView.currentStar > 0 || !userReviewTextView.text.isEmpty
        if reviewId == nil, isReviewStarted {
            
            let title = "작성 취소"
            let message = "작성 중인 리뷰는 저장되지 않습니다. 정말 나가시겠습니까?"
            let confirmButtonTitle = "나가기"
            let cancelButtonTitle = "계속 작성"
            
            showCustomDialog(
                title: title,
                message: message,
                cancelButtonTitle: cancelButtonTitle,
                confirmButtonTitle: confirmButtonTitle
            ) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            return false
        }
        return true
    }
}

// MARK: - UITextViewDelegate

extension SetRateViewController: UITextViewDelegate {
    func textView(_: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = userReviewTextView.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let newLength = currentText.count + text.count - range.length
        
        if newLength > 300 { return false }
        
        let textToDisplay = currentText.replacingCharacters(in: stringRange, with: text)
        maximumWordLabel.text = "\(textToDisplay.count) / 300"
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "메뉴에 대한 상세한 리뷰를 작성해주세요" {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "메뉴에 대한 상세한 리뷰를 작성해주세요"
            textView.textColor = .gray500
            maximumWordLabel.text = "0 / 300"
        } else {
            maximumWordLabel.text = "\(textView.text.count) / 300"
        }
    }
}

// MARK: - Keyboard Handling

extension SetRateViewController {
    @objc func keyboardWillShow(_ noti: NSNotification) {
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            UIView.animate(withDuration: 0.3) {
                self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height)
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

// MARK: - UITableViewDataSource & Delegate

extension SetRateViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        selectedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuLikeCell.identifier, for: indexPath) as? MenuLikeCell else {
            return UITableViewCell()
        }
        
        cell.dataBind(menu: selectedList[indexPath.row], isLiked: likedStates[indexPath.row])
        cell.onLikeTapped = { [weak self, weak cell, weak tableView] in
            guard let self, let tableView, let cell, let idx = tableView.indexPath(for: cell) else { return }
            self.toggleLike(for: idx.row)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        toggleLike(for: indexPath.row)
    }
}
