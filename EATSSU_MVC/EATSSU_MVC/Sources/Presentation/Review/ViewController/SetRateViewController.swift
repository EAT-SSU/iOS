//
//  setRateViewController.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/03/23.
//

import UIKit

import SnapKit
import Then
import Moya

final class SetRateViewController: BaseViewController {
    
    // MARK: - Properties

    private let writeReviewProvider = MoyaProvider<WriteReviewRouter>(plugins: [MoyaLoggingPlugin()])
    private let reviewProvider = MoyaProvider<ReviewRouter>(plugins: [MoyaLoggingPlugin()])
    private var currentPage: Int = 0 {
        didSet {
            menuLabel.text = "\(selectedList[currentPage]) 을/를 추천하시겠어요?"
            if currentPage == selectedList.count - 1 {
                self.nextButton.setTitle("리뷰 남기기", for: .normal)
            }
        }
    }
    private var userPickedImage: UIImage?
    private var reviewList: [(BeforeSelectedImageDTO, UIImage?)] = []
    private var selectedIDList: [Int] = []
    private var selectedList: [String] = []

    
    /// [리뷰 수정하기]에 필요한 reviewID
    /// 해당 값이 존재하지 않으면, 리뷰 작성하기 기능을 수행 중인 것이다
    private var reviewId: Int?
    
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
        label.text = "김치볶음밥 & 계란국을 추천하시겠어요?"
        label.font = .subtitle1
        label.textColor = .black
        return label
    }()
    
    private var detailLabel: UILabel = {
        let label = UILabel()
        label.text = "해당 메뉴에 대한 상세한 평가를 남겨주세요."
        label.font = .body3
        label.textColor = EATSSUAsset.Color.GrayScale.gray600.color
        return label
    }()
    
    private var tasteLabel: UILabel = {
        let label = UILabel()
        label.text = "맛"
        label.font = .subtitle1
        label.textColor = .black
        return label
    }()
    
    private var quantityLabel: UILabel = {
        let label = UILabel()
        label.text = "양"
        label.font = .subtitle1
        label.textColor = .black
        return label
    }()
    
    lazy var tasteStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16.adjusted
        $0.alignment = .center
    }
    
    lazy var quantityStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 16.adjusted
        $0.alignment = .center
    }
    
    private let userReviewTextView: UITextView = {
        let textView = UITextView()
        textView.font = .body1
        textView.layer.cornerRadius = 10.adjusted
        textView.backgroundColor = EATSSUAsset.Color.GrayScale.gray100.color
        textView.layer.borderWidth = 1.adjusted
        textView.layer.borderColor = EATSSUAsset.Color.GrayScale.gray300.color.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 16.0.adjusted,
                                                   left: 16.0.adjusted,
                                                   bottom: 16.0.adjusted,
                                                   right: 16.0.adjusted)
        textView.text = "3글자 이상 작성해주세요!"
        textView.textColor = .gray500
        return textView
    }()
    
    private lazy var userReviewImageView = UIImageView().then {
        $0.layer.cornerRadius = 10 // 원하는 둥근 모서리의 크기
        $0.clipsToBounds = true // 이 속성을 true로 설정해야 둥근 모서리가 보입니다.
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTappedimageView))
        $0.isUserInteractionEnabled = true // 사용자 상호작용을 가능하게 설정
        $0.addGestureRecognizer(tapGesture)
    }
    
    private let selectImageButton = UIButton().then {
        $0.setImage(UIImage(named: "AddImageButton"), for: .normal)
        $0.addTarget(self, action: #selector(didSelectedImage), for: .touchUpInside)
    }

    private let deleteMethodLabel = UILabel().then {
        $0.text = "이미지 클릭 시, 삭제됩니다"
        $0.font = .caption3
        $0.textColor = EATSSUAsset.Color.GrayScale.gray500.color
    }
    
    private let maximumWordLabel: UILabel = {
        let label = UILabel()
        label.text = "0 / 300"
        label.font = .caption2
        label.textColor = EATSSUAsset.Color.GrayScale.gray600.color
        return label
    }()
    
    private var nextButton = MainButton().then {
        $0.title = "다음 단계로"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDelegate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardNotifications()
    }

    // MARK: - Functions
    
    override func configureUI() {
        dismissKeyboard()
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubviews(rateView,
                                menuLabel,
                                tasteLabel,
                                quantityLabel,
                                detailLabel,
                                tasteStackView,
                                quantityStackView,
                                userReviewTextView,
                                maximumWordLabel,
                                selectImageButton,
                                userReviewImageView,
                                deleteMethodLabel,
                                nextButton)
        
        tasteStackView.addArrangedSubviews([tasteLabel,
                                            tasteRateView])
        
        quantityStackView.addArrangedSubviews([quantityLabel,
                                               quantityRateView])
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
        
        tasteStackView.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        
        quantityStackView.snp.makeConstraints { make in
            make.top.equalTo(tasteStackView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(maximumWordLabel.snp.bottom).offset(132)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        for i in 0...4 {
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
            make.top.equalTo(quantityStackView.snp.bottom).offset(40)
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
        
        userReviewImageView.snp.makeConstraints {
            $0.top.equalTo(maximumWordLabel.snp.bottom).offset(15)
            $0.leading.equalTo(selectImageButton.snp.trailing).offset(13)
            $0.width.equalTo(60)
            $0.height.equalTo(60)
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
        self.selectedList = list
        self.selectedIDList = idList
        if let reviewList = reviewList {
            self.reviewList = reviewList
        } else {
            self.reviewList = Array(repeating: (BeforeSelectedImageDTO(mainRating: 0,
                                                                       amountRating: 0,
                                                                       tasteRating: 0,
                                                                       content: ""),
                                                nil), count: idList.count)
        }
        self.currentPage = currentPage
    }
    
    func dataBindForFix(list: [String], reivewId: Int) {
        self.selectedList = list
        self.reviewId = reivewId
        menuLabel.text = "\(selectedList[0]) 을/를 추천하시겠어요?"
        selectImageButton.isHidden = true
        deleteMethodLabel.isHidden = true
        nextButton.setTitle("리뷰 수정 완료하기", for: .normal)
    }
    
    func setDelegate() {
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        
        userReviewTextView.delegate = self
    }
    
    @objc
    func tappedNextButton() {
        
        if userReviewTextView.text == "3글자 이상 작성해주세요!" || userReviewTextView.text.count < 3 {
            view.showToast(message: "리뷰를 3글자 이상 작성해주세요!")
        } else {
            
            if (rateView.currentStar != 0) && (quantityRateView.currentStar != 0) && (tasteRateView.currentStar != 0) {
                // 리뷰 작성하기 버튼이 isEnabled = true일 때의 area
                let param = BeforeSelectedImageDTO.init(mainRating: rateView.currentStar,
                                                        amountRating: quantityRateView.currentStar,
                                                        tasteRating: tasteRateView.currentStar,
                                                        content: userReviewTextView.text
                )
                
                /// 리뷰 데이터는 현재 페이지가 어디든 상관 없이 저장되어야 함
                reviewList[currentPage] = (param, userPickedImage)
                
                switch reviewId {
                case .none:
                    
                    /// 현재 페이지가 마지막 메뉴에 대한 리뷰페이지일 때의 액션
                    if currentPage == selectedList.count - 1 {
                        self.navigationController?.isNavigationBarHidden = false
                        sendDataIfCurrentPageIsLast()
                    } else {
                        prepareForNextReview()
                    }
                    
                case .some(let reviewID):
                    patchFixedReview(reviewId: reviewID, param: param)
                }
                
            } else {
                view.showToast(message: "별점을 모두 입력해주세요 !")
            }
        }
    }
    
    private func sendDataIfCurrentPageIsLast() {
        for (index, review) in reviewList.enumerated() {
            let (reviewDTO, image) = review
            if image != nil {
                postReviewImage(param: reviewDTO,
                                image: image,
                                menuId: selectedIDList[index])
            } else {
                let reviewDTO = WriteReviewRequest(content: reviewDTO, imageURL: "")
                postNewWriteReview(param: reviewDTO,
                                   menuID: selectedIDList[index])
            }
        }
    }
    

    @objc
    func didSelectedImage() {
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc
    func didTappedimageView() {
        userReviewImageView.image = nil // 이미지 삭제
        userPickedImage = nil
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
        if let reviewViewController = self.navigationController?.viewControllers.first(where: { $0 is ReviewViewController }) {
            self.navigationController?.popToViewController(reviewViewController, animated: true)
        }
    }
    
    func settingForReviewFix(data: MenuDataList) {
        rateView.currentStar = data.mainRating
        rateView.settingStarForFix(currentStar: data.mainRating)
        
        quantityRateView.currentStar = data.amountRating
        quantityRateView.settingStarForFix(currentStar: data.amountRating)

        tasteRateView.currentStar = data.tasteRating
        tasteRateView.settingStarForFix(currentStar: data.tasteRating)
        
        userReviewTextView.text = data.content
        userReviewTextView.textColor = .black
    }
}

// MARK: - Server

extension SetRateViewController {
    
    /// 이미지 O -> URL 받고, URL을 넣어서 리뷰 작성 요청
    /// 이미지 X -> URL 없이 리뷰 작성 요청
    /// 이미지가 아예 없을 때 어떤 경우로 빠지는지 보고, 거기에서 호출하도록 하기
    private func postReviewImage(param: BeforeSelectedImageDTO, image: UIImage?, menuId: Int) {
        self.writeReviewProvider.request(.uploadImage(image: image)) { response in
            switch response {
            case .success(let moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<UploadImageResponse>.self)
                    let reviewDTO = WriteReviewRequest.init(content: param, imageURL: responseData.result.url)
                    self.postNewWriteReview(param: reviewDTO, menuID: menuId)
                } catch(let err) {
                    print(err.localizedDescription)
                    let reviewDTO = WriteReviewRequest.init(content: param, imageURL: nil)
                    self.postNewWriteReview(param: reviewDTO, menuID: menuId)
                }
                
            case .failure(let err):
                print(err.localizedDescription)
                let reviewDTO = WriteReviewRequest.init(content: param, imageURL: nil)
                self.postNewWriteReview(param: reviewDTO, menuID: menuId)
            }
        }
    }
    
    private func postNewWriteReview(param: WriteReviewRequest,
                                    menuID: Int) {
        self.writeReviewProvider.request(.writeNewReview(param: param,
                                                         menuID: menuID)) { response in
            switch response {
            case .success(_):
                do {
                    if self.currentPage == self.reviewList.count - 1 {
                        self.moveToReviewVC()
                    }
                }
                
            case .failure(let err):
                print(err.localizedDescription)
                self.view.showToast(message: "리뷰 작성에 실패했어요. 다시 시도해주세요!")
            }
        }
    }
    private func postWriteReview(param: WriteReviewRequest,
                                 image: [UIImage?],
                                 menuId: Int) {
        self.writeReviewProvider.request(.writeReview(param: param, image: image, menuId: menuId)) { response in
            switch response {
            case.success(_):
                do {
                    if self.selectedList.count == 1 {
                        self.moveToReviewVC()
                    } else {
                        self.prepareForNextReview()
                    }
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
    
    // 이거 제대로 작동 되는지 확인하기
    private func patchFixedReview(reviewId: Int, param: BeforeSelectedImageDTO) {
        self.reviewProvider.request(.fixReview(reviewId, param)) { response in
            switch response {
            case.success(let moyaResponse):
                do {
                    print(moyaResponse)
                    self.navigationController?.popViewController(animated: true)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension SetRateViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            userReviewImageView.image = image
            userPickedImage = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate

extension SetRateViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
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
    func keyboardWillHide(_ noti: NSNotification) {
        self.view.transform = .identity
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // 노티피케이션을 추가하는 메서드
    func addKeyboardNotifications() {
        // 키보드가 나타날 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 추가
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)),
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
