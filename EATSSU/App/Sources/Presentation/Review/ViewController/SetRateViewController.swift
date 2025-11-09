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

    private var currentPage: Int = 0 {
        didSet {
//            menuLabel.text = "\(selectedList[currentPage]) 을/를 추천하시겠어요?"
            if currentPage == selectedList.count - 1 {
                nextButton.setTitle("리뷰 남기기", for: .normal)
            }
        }
    }

    private var userPickedImage: UIImage?
    private var reviewList: [(BeforeSelectedImageDTO, UIImage?)] = []
    private var selectedIDList: [Int] = []
    private var selectedList: [String] = []
    private var reviewId: Int?
    
    // 좋아요 상태를 보관 (selectedList와 같은 인덱스)
        private var likedStates: [Bool] = []
    private var menuTableViewHeightConstraint: Constraint?

    // MARK: - UI Components

    private var rateView = RateView()
    private var tasteRateView = RateView()
    private var quantityRateView = RateView()
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

    private let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = .primary
        return view
    }()

    private var menuLabel: UILabel = {
        let label = UILabel()
//        label.text = "김치볶음밥 & 계란국을 추천하시겠어요?"
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

//    private var tasteLabel: UILabel = {
//        let label = UILabel()
//        label.text = "맛"
//        label.font = .subtitle1
//        label.textColor = .black
//        return label
//    }()
//
//    private var quantityLabel: UILabel = {
//        let label = UILabel()
//        label.text = "양"
//        label.font = .subtitle1
//        label.textColor = .black
//        return label
//    }()

//    private lazy var tasteStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .horizontal
//        stackView.spacing = 16.adjusted
//        stackView.alignment = .center
//        return stackView
//    }()
//
//    private lazy var quantityStackView: UIStackView = {
//        let stackView = UIStackView()
//        stackView.axis = .horizontal
//        stackView.spacing = 16.adjusted
//        stackView.alignment = .center
//        return stackView
//    }()

    private let userReviewTextView: UITextView = {
        let textView = UITextView()
        textView.font = .body1
        textView.layer.cornerRadius = 10.adjusted
        textView.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray100.color
        textView.layer.borderWidth = 1.adjusted
        textView.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray300.color.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 16.0.adjusted, left: 16.0.adjusted, bottom: 16.0.adjusted, right: 16.0.adjusted)
//        textView.text = "3글자 이상 작성해주세요!"
        textView.text = "메뉴에 대한 상세한 리뷰를 작성해주세요"
        textView.textColor = .gray500
        return textView
    }()

    private lazy var userReviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTappedimageView))
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.tintColor = .lightGray
        button.addTarget(self, action: #selector(didTappedimageView), for: .touchUpInside)
        button.isHidden = true // Hide close button initially
        return button
    }()
    
//    private lazy var imageContainerView: UIView = {
//        let view = UIView()
//        view.layer.cornerRadius = 10
//        view.clipsToBounds = true
//        return view
//    }()

    private lazy var imageContainer: UIView = {
        let view = UIView()
        view.addSubview(selectImageButton)
        view.addSubview(imageCountLabel)
        return view
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
        button.contentVerticalAlignment = .center
        button.contentHorizontalAlignment = .center
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

    private var nextButton: MainButton = {
        let button = MainButton()
        button.title = "다음 단계로"
        return button
    }()

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegate()
        
        // 더미데이터 지정
            selectedList = ["김치볶음밥", "돈까스", "된장찌개", "샐러드", "라면"]

            // 좋아요 상태 배열도 맞춰서 초기화
            likedStates = Array(repeating: false, count: selectedList.count)

            // 테이블 갱신
            menuTableView.reloadData()
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


    // MARK: - Functions

    override func configureUI() {
        dismissKeyboard()
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(rateView,
                                menuLabel,
//                                tasteLabel,
//                                quantityLabel,
                                detailLabel,
                                
                                menuTableView,
//                                tasteStackView,
//                                quantityStackView,
                                userReviewTextView,
                                maximumWordLabel,
                                selectImageButton,
                                imageCountLabel,
                                userReviewImageView,
                                closeButton,
//                                imageContainerView,
                                deleteMethodLabel,
                                nextButton)

//        tasteStackView.addArrangedSubviews([tasteLabel,
//                                            tasteRateView])

//        quantityStackView.addArrangedSubviews([quantityLabel,
//                                               quantityRateView])
//        imageContainerView.addSubview(userReviewImageView)
//        imageContainerView.addSubview(closeButton)
    }

    override func setLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
//                $0.bottom.equalToSuperview()
//            $0.height.equalTo(200)
            menuTableViewHeightConstraint = $0.height.equalTo(0).constraint // 처음엔 0으로
            }

//        tasteStackView.snp.makeConstraints { make in
//            make.top.equalTo(detailLabel.snp.bottom).offset(30)
//            make.centerX.equalToSuperview()
//        }
//
//        quantityStackView.snp.makeConstraints { make in
//            make.top.equalTo(tasteStackView.snp.bottom).offset(30)
//            make.centerX.equalToSuperview()
//        }

        nextButton.snp.makeConstraints { make in
            make.top.equalTo(maximumWordLabel.snp.bottom).offset(132)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-15)
        }

        for i in 0 ... 4 {
            tasteRateView.buttons[i].snp.makeConstraints { make in
                make.height.equalTo(28)
                make.width.equalTo(29.3)
            }

            quantityRateView.buttons[i].snp.makeConstraints { make in
                make.height.equalTo(28)
                make.width.equalTo(29.3)
            }
        }

        userReviewTextView.snp.makeConstraints { make in
//            make.top.equalTo(quantityStackView.snp.bottom).offset(40)
            make.top.equalTo(menuTableView.snp.bottom).offset(40)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(181)
        }

        maximumWordLabel.snp.makeConstraints { make in
            make.top.equalTo(userReviewTextView.snp.bottom).offset(7)
            make.trailing.equalTo(userReviewTextView)
        }

        selectImageButton.snp.makeConstraints {
            $0.top.equalTo(maximumWordLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().offset(15)
            $0.width.equalTo(60)
            $0.height.equalTo(60)
        }

        imageCountLabel.snp.makeConstraints {
            $0.top.equalTo(selectImageButton.snp.bottom).offset(-19)
            $0.centerX.equalTo(selectImageButton)
            $0.width.equalTo(selectImageButton)
        }

        userReviewImageView.snp.makeConstraints {
            $0.top.equalTo(maximumWordLabel.snp.bottom).offset(15)
            $0.leading.equalTo(selectImageButton.snp.trailing).offset(13)
            $0.width.equalTo(60)
            $0.height.equalTo(60)
        }
//        imageContainerView.snp.makeConstraints {
//            $0.top.equalTo(maximumWordLabel.snp.bottom).offset(15)
//            $0.leading.equalTo(selectImageButton.snp.trailing).offset(13)
//            $0.width.height.equalTo(70)   // 원하는 크기로 조절
//        }
        
//        userReviewImageView.snp.makeConstraints {
////            $0.edges.equalToSuperview()
//            $0.size.equalTo(60)
//
//        }

        
        closeButton.snp.makeConstraints {
            $0.top.equalTo(userReviewImageView.snp.top).offset(-6)
            $0.trailing.equalTo(userReviewImageView.snp.trailing).offset(6)
            $0.size.equalTo(24)
        }

        deleteMethodLabel.snp.makeConstraints {
            $0.top.equalTo(selectImageButton.snp.bottom).offset(7)
            $0.leading.equalTo(selectImageButton)
        }
    }

    override func setButtonEvent() {
        nextButton.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
    }

    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        if reviewId != nil {
            navigationItem.title = "리뷰 수정하기"
        } else {
            navigationItem.title = "리뷰 남기기"
        }
    }

    func dataBind(list: [String], idList: [Int], reviewList: [(BeforeSelectedImageDTO, UIImage?)]?, currentPage: Int) {
        selectedList = list
        selectedIDList = idList
        if let reviewList {
                self.reviewList = reviewList
            } else {
                self.reviewList = Array(repeating: (BeforeSelectedImageDTO(mainRating: 0,
                                                                           amountRating: nil,
                                                                           tasteRating: nil,
                                                                           content: ""),
                                                    nil), count: idList.count)
            }
        self.currentPage = currentPage
    }
    
    // 좋아요 토글 메서드 (여기가 없으면 'Cannot find toggleLike' 에러)
    private func toggleLike(for index: Int) {
        likedStates[index].toggle()
        let idx = IndexPath(row: index, section: 0)

        if let cell = menuTableView.cellForRow(at: idx) as? MenuLikeCell {
            cell.dataBind(menu: selectedList[index], isLiked: likedStates[index])
        } else {
            menuTableView.reloadRows(at: [idx], with: .none)
        }
    }

    func dataBindForFix(list: [String], reivewId: Int) {
        selectedList = list
        reviewId = reivewId
        menuLabel.text = "\(selectedList[0]) 을/를 추천하시겠어요?"
        selectImageButton.isHidden = true
        deleteMethodLabel.isHidden = true
        nextButton.setTitle("리뷰 수정 완료하기", for: .normal)
    }

    func setDelegate() {
        menuTableView.register(MenuLikeCell.self, forCellReuseIdentifier: MenuLikeCell.identifier)
        menuTableView.dataSource = self
        menuTableView.delegate = self
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false

        userReviewTextView.delegate = self
    }

    @objc
    func tappedNextButton() {
        if userReviewTextView.text == "3글자 이상 작성해주세요!" || userReviewTextView.text.count < 3 {
            showToast(message: "리뷰를 3글자 이상 작성해주세요!", type: .info)
        } else {
            if rateView.currentStar != 0, quantityRateView.currentStar != 0, tasteRateView.currentStar != 0 {
                // 리뷰 작성하기 버튼이 isEnabled = true일 때의 area
                let param = BeforeSelectedImageDTO(mainRating: rateView.currentStar,
                                                   amountRating: quantityRateView.currentStar,
                                                   tasteRating: tasteRateView.currentStar,
                                                   content: userReviewTextView.text)

                switch reviewId {
                case .none:
                    /// 현재 이미지를 별도 변수에 저장
                    let currentImage = userPickedImage
                    reviewList[currentPage] = (param, currentImage)
                    
                    /// 현재 페이지가 마지막 메뉴에 대한 리뷰페이지일 때의 액션
                    if currentPage == selectedList.count - 1 {
                        navigationController?.isNavigationBarHidden = false
                        sendDataIfCurrentPageIsLast()
                    } else {
                        // 다음 리뷰를 위해 현재 화면의 이미지 초기화
                        userPickedImage = nil
                        userReviewImageView.image = nil
                        imageCountLabel.text = "사진 0/1"
                        prepareForNextReview()
                    }

                case let .some(reviewID):
                    patchFixedReview(reviewId: reviewID, param: param)
                }

            } else {
                showToast(message: "별점을 모두 입력해주세요!", type: .info)
            }
        }
    }

    private func sendDataIfCurrentPageIsLast() {
        _Concurrency.Task {
            do {
                for (index, review) in reviewList.enumerated() {
                    let (reviewDTO, image) = review
                    
                    // Firebase 이벤트 로그
                    let photoAttached = (image != nil) ? 1 : 0
                    let rating = reviewDTO.mainRating
                    let selection = self.selectedList.count
                    ReviewAnalyticsManager.shared.logCompleteReviewV1(photoAttached: photoAttached, rating: rating, selection: selection)
                    
                    // 순차적으로 업로드
                    try await uploadReview(reviewDTO: reviewDTO, image: image, menuId: selectedIDList[index])
                }
                
                await MainActor.run {
                    self.moveToReviewVC()
                }
                
            } catch {
                await MainActor.run {
                    print("리뷰 업로드 실패: \(error)")
                    self.showToast(message: "리뷰 업로드에 실패했습니다.")
                }
            }
        }
    }
    
    private func uploadReview(reviewDTO: BeforeSelectedImageDTO, image: UIImage?, menuId: Int) async throws {
        if let image = image {
            // 이미지 업로드 후 리뷰 작성
            let imageUrl = try await uploadImage(image: image)
            let request = WriteReviewRequest(content: reviewDTO, imageURL: imageUrl)
            try await postReview(request: request, menuId: menuId)
        } else {
            // 이미지 없이 리뷰만 작성
            let request = WriteReviewRequest(content: reviewDTO, imageURL: "")
            try await postReview(request: request, menuId: menuId)
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

    @objc
    func didSelectedImage() {
        present(imagePickerController, animated: true, completion: nil)
    }

    @objc
    func didTappedimageView() {
        userReviewImageView.image = nil // 이미지 삭제
        userPickedImage = nil
        imageCountLabel.text = "사진 0/1"
        closeButton.isHidden = true // Hide close button when image is cleared
    }

    private func prepareForNextReview() {
        let setRateVC = SetRateViewController()
        setRateVC.dataBind(list: selectedList,
                           idList: selectedIDList,
                           reviewList: reviewList,
                           currentPage: currentPage + 1)
        navigationController?.pushViewController(setRateVC, animated: true)
    }

    // 리뷰 리스트 보는 화면으로 넘어가도록 하는 함수
    private func moveToReviewVC() {
        if let reviewViewController = navigationController?.viewControllers.first(where: { $0 is ReviewViewController }) {
            navigationController?.popToViewController(reviewViewController, animated: true)
            
            // 네비게이션 스택에서 HomeViewController 찾아서 새로고침
            if let homeVC = navigationController?.viewControllers.first as? HomeViewController {
                homeVC.refreshAfterReview()
            }
        }
    }

    func settingForReviewFix(data: MenuDataList) {
        rateView.currentStar = data.mainRating
        rateView.settingStarForFix(currentStar: data.mainRating)

        quantityRateView.currentStar = data.amountRating ?? 0
        quantityRateView.settingStarForFix(currentStar: data.amountRating ?? 0)

        tasteRateView.currentStar = data.tasteRating ?? 0
        tasteRateView.settingStarForFix(currentStar: data.tasteRating ?? 0)

        userReviewTextView.text = data.content
        userReviewTextView.textColor = .black
    }
    
    
}

// MARK: - Server

extension SetRateViewController {
    /// 이미지 O -> URL 받고, URL을 넣어서 리뷰 작성 요청
    /// 이미지 X -> URL 없이 리뷰 작성 요청
    /// 이미지가 아예 없을 때 어떤 경우로 빠지는지 보고, 거기에서 호출하도록 하기
    private func postReview(request: WriteReviewRequest, menuId: Int) async throws {
        try await withCheckedThrowingContinuation { continuation in
            NetworkService.shared.request(
                WriteReviewRouter.writeNewReview(param: request, menuID: menuId),
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
    
    private func patchFixedReview(reviewId: Int, param: BeforeSelectedImageDTO) {
        NetworkService.shared.request(
            ReviewRouter.fixReview(reviewId, param),
            responseType: Bool.self,
            useAuth: true
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.navigationController?.popViewController(animated: true)
                
            case .failure(let error):
                print("리뷰 수정 실패: \(error.localizedDescription)")
                RealmService.shared.resetDB()
                self.navigateToLogin()
            }
        }
    }
    
    private func navigateToLogin() {
        let loginVC = LoginViewController()
        loginVC.toastMessage = "세션이 만료되었습니다. 다시 로그인해주세요."
        loginVC.toastType = .info
        
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                keyWindow.replaceRootViewController(UINavigationController(rootViewController: loginVC))
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension SetRateViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            userReviewImageView.image = image
            userPickedImage = image
            imageCountLabel.text = "사진 1/1"
            closeButton.isHidden = false // Show close button when image is selected
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate

extension SetRateViewController: UITextViewDelegate {
    func textView(_: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = userReviewTextView.text.count - range.length + text.count
        maximumWordLabel.text = "\(userReviewTextView.text.count) / 300"
        if newLength > 300 {
            return false
        }
        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "3글자 이상 작성해주세요!" {
            textView.text = ""
            textView.textColor = .black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "3글자 이상 작성해주세요!"
            textView.textColor = .gray500
        }
    }
}

// MARK: - UINavigationControllerDelegate

extension SetRateViewController: UINavigationControllerDelegate {
    func navigationController(_: UINavigationController, willShow viewController: UIViewController, animated _: Bool) {
        if viewController == self {
            // Pop 되기 직전의 로직을 여기서 실행
            print("Back button pressed, will pop the current view controller")
        }
    }

    // 키보드가 나타났다는 알림을 받으면 실행할 메서드
    @objc
    func keyboardWillShow(_ noti: NSNotification) {
        // 키보드의 높이만큼 화면을 올려준다.
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -keyboardRectangle.height)
                    self.navigationController?.isNavigationBarHidden = true
                }
            )
        }
    }

    // 키보드가 사라졌다는 알림을 받으면 실행할 메서드
    @objc
    func keyboardWillHide(_: NSNotification) {
        view.transform = .identity
        navigationController?.isNavigationBarHidden = false
    }

    // 노티피케이션을 추가하는 메서드
    func addKeyboardNotifications() {
        // 키보드가 나타날 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }

    // 노티피케이션을 제거하는 메서드
    func removeKeyboardNotifications() {
        // 키보드가 나타날 때 앱에게 알리는 메서드 제거
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillShowNotification,
                                                  object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 제거
        NotificationCenter.default.removeObserver(self,
                                                  name: UIResponder.keyboardWillHideNotification,
                                                  object: nil)
    }
}

extension SetRateViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedList.count   // 리뷰 대상 메뉴 리스트
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MenuLikeCell.identifier, for: indexPath) as? MenuLikeCell else {
            return UITableViewCell()
        }
        
        let menuName = selectedList[indexPath.row]
        let isLiked = likedStates[indexPath.row]
        cell.dataBind(menu: menuName, isLiked: isLiked)
        
        // 인덱스 캡처 대신, 셀로부터 현재 indexPath를 찾아서 토글 (재사용 안전)
                cell.onLikeTapped = { [weak self, weak cell, weak tableView] in
                    guard
                        let self = self,
                        let tableView = tableView,
                        let cell = cell,
                        let tappedIndexPath = tableView.indexPath(for: cell)
                    else { return }
                    self.toggleLike(for: tappedIndexPath.row)
                }
        
        return cell
    }
    
    // 선택 이벤트 (좋아요 버튼 눌렀을 때 등)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(selectedList[indexPath.row]) 선택됨")
        // 선택 효과 제거 (회색 하이라이트 방지)
            tableView.deselectRow(at: indexPath, animated: false)

            // 행을 눌렀을 때도 토글 실행
            toggleLike(for: indexPath.row)
    }
}
