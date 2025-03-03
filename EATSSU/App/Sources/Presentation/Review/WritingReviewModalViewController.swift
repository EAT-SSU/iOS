//
//  WritingReviewModalViewController.swift
//  EATSSU-DEV
//
//  Created by 최지우 on 2/2/25.
//

import UIKit

import EATSSUDesign

final class WritingReviewModalViewController: BaseViewController {
    
    // MARK: - Properties
    
    // View Properties
//    private let writingReviewModalView = WritingReviewModalView()
    
    private var userPickedImage: UIImage?

    // MARK: - UI Components
    
    // FIXME: - Menu Feedback View TEST
    let menus = ["고구마치즈돈까스", "막국수", "단무지", "요구르트", "파전", "설렁탕"]
    

    private var rateView = RateView()
    private let imagePickerController = UIImagePickerController()
    public let completeReviewButton = ESButton(size: .big, title: "완료하기")
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "리뷰 남기기"
        label.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 16)
        return label
    }()

    private var questionLabel: UILabel = {
        let label = UILabel()
        label.text = "오늘 식사는 어떠셨나요"
        label.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 16)
        return label
    }()

    private let userReviewTextView: UITextView = {
        let textView = UITextView()
        textView.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 14)
        textView.layer.cornerRadius = 12.adjusted
        textView.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray100.color
        textView.layer.borderWidth = 1.adjusted
        textView.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray200.color.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 12.0.adjusted,
                                                   left: 12.0.adjusted,
                                                   bottom: 12.0.adjusted,
                                                   right: 12.0.adjusted)
        textView.text = "메뉴에 대한 상세한 리뷰를 작성해주세요"
        textView.textColor = EATSSUDesignAsset.Color.GrayScale.gray400.color
        return textView
    }()

    private lazy var userReviewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTappedimageView))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGesture)
        return imageView
    }()

    private lazy var selectImageButton: UIButton = {
        let button = UIButton()
        button.setImage(EATSSUDesignAsset.Images.photoUpload.image, for: .normal)
        button.addTarget(self, action: #selector(didSelectedImage), for: .touchUpInside)
        return button
    }()

    private let deleteMethodLabel: UILabel = {
        let label = UILabel()
        label.text = "이미지 클릭 시, 삭제됩니다"
        label.font = .caption3
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray500.color
        return label
    }()

    private let maximumWordLabel: UILabel = {
        let label = UILabel()
        label.text = "0 / 300"
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 10)
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray400.color
        return label
    }()

//    private var nextButton: UIButton = {
//        var config = UIButton.Configuration.plain()
//        var container = AttributeContainer()
//        container.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 16)
//        container.foregroundColor = EATSSUDesignAsset.Color.Main.primary.color
//        config.attributedTitle = AttributedString("완료하기", attributes: container)
//        config.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
//        let button = UIButton(configuration: config)
//        return button
//    }()
    
//    lazy var sv: UIStackView = {
//        let mf = MenuFeedbackView()
//        mf.configure(with: "떡국")
//        let sv = UIStackView(arrangedSubviews: [mf])
//        sv.axis = .vertical
//        return sv
//    }()
    
    let sv: MenuFeedbackView = {
        let a = MenuFeedbackView()
        a.configure(with: "고구마치즈돈까스")
        return a
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegate()
        
        
        
//        for menu in menus {
//            let menuView = MenuFeedbackView()
//            menuView.configure(with: menu)
//            sv.addSubview(menuView)
//        }
    }

    override func viewWillAppear(_: Bool) {
        addKeyboardNotifications()
    }

    override func viewWillDisappear(_: Bool) {
        removeKeyboardNotifications()
    }

    // MARK: - Functions

    override func configureUI() {
        dismissKeyboard()
        view.addSubviews(
            titleLabel,
            questionLabel,
            rateView,
            sv,
            maximumWordLabel,
            selectImageButton,
            userReviewImageView,
            userReviewTextView,
            deleteMethodLabel,
            completeReviewButton)
    }

    override func setLayout() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(20)
            make.centerX.equalToSuperview()
        }

        questionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }

        rateView.snp.makeConstraints { make in
            make.top.equalTo(questionLabel.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
            make.height.equalTo(24)
        }
        
        sv.snp.makeConstraints { make in
            make.top.equalTo(rateView.snp.bottom).offset(40)
            make.horizontalEdges.equalToSuperview().inset(48)
            make.height.equalTo(28)
        }

        userReviewTextView.snp.makeConstraints { make in
            make.top.equalTo(sv.snp.bottom).offset(40)
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
            $0.width.height.equalTo(60)
        }

        deleteMethodLabel.snp.makeConstraints {
            $0.top.equalTo(selectImageButton.snp.bottom).offset(7)
            $0.leading.equalTo(selectImageButton)
        }
        
        completeReviewButton.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(40)
        }
    }

    override func setButtonEvent() {
        completeReviewButton.addTarget(self, action: #selector(tappedNextButton), for: .touchUpInside)
    }
    
    @objc
    func didSelectedImage() {
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @objc
    func didTappedimageView() {
        userReviewImageView.image = nil
        userPickedImage = nil
    }
    
    @objc
    func tappedNextButton() {
        
    }

    func setDelegate() {
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
    }

//    private func prepareForNextReview() {
//        let setRateVC = SetRateViewController()
//        setRateVC.dataBind(list: selectedList,
//                           idList: selectedIDList,
//                           reviewList: reviewList,
//                           currentPage: currentPage + 1)
//        navigationController?.pushViewController(setRateVC, animated: true)
//    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension WritingReviewModalViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            userReviewImageView.image = image
            userPickedImage = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UINavigationControllerDelegate

extension WritingReviewModalViewController: UINavigationControllerDelegate {
//    func navigationController(_: UINavigationController, willShow viewController: UIViewController, animated _: Bool) {
//        if viewController == self {
//            // Pop 되기 직전의 로직을 여기서 실행
//            print("Back button pressed, will pop the current view controller")
//        }
//    }

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

#if DEBUG
import SwiftUI

struct aPreview: PreviewProvider {
    static var previews: some View {
        WritingReviewModalViewController().toPreview()
    }
}
#endif
