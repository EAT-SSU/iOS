//
//  WriteReviewViewController.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/03/25.
//

import UIKit

import SnapKit
import Then
import Moya

// 사용 x
class WriteReviewViewController: BaseViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Properties

    var personalRate = 0
    var grade: Int = 0
    var tag: [String] = []
    var isPhotoExist: Bool = false
    private var starButtons: [UIButton] = []
    let writeReviewProvider = MoyaProvider<WriteReviewRouter>(plugins: [MoyaLoggingPlugin()])
    
    // MARK: - UI Components

    let imagePickerController = UIImagePickerController()
    
    private var menuLabel: UILabel = {
        let label = UILabel()
        label.text = "김치볶음밥 & 계란국을 평가해주세요"
        label.font = .bold(size: 20)
        label.textColor = .black
        return label
    }()
    
    lazy var starStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 9
        stackView.backgroundColor = .systemBackground
        return stackView
    }()
    
    private lazy var starFillImage: UIImage? = {
        return UIImage(named: "starFilledBig.svg")
    }()
    
    private lazy var starEmptyImage: UIImage? = {
        return UIImage(named: "starEmptyBig.svg")
    }()
    
    private let userReviewTextView: UITextView = {
        let textView = UITextView()
        textView.font = .medium(size: 16)
        textView.layer.cornerRadius = 10
        textView.backgroundColor = .gray100
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.gray200.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        return textView
    }()
    
    private let maximumWordLabel: UILabel = {
        let label = UILabel()
        label.text = "최대 150자"
        label.font = .medium(size: 12)
        label.textColor = .gray700
        return label
    }()
    
    private var updateReviewButton: UIButton = {
        let button = UIButton()
        button.setTitle("리뷰 등록하기", for: .normal)
        button.backgroundColor = .primary
        button.layer.cornerRadius = 10
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .semiBold(size: 18)
        return button
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
        $0.font = .medium(size: 12)
        $0.textColor = .gray300
    }
    
    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationBar()
        setStarButtons()
        
        userReviewTextView.delegate = self
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
    }
    
    // MARK: - Functions
    
    override func configureUI() {
        view.addSubviews(menuLabel,
                         starStackView,
                         userReviewTextView,
                         maximumWordLabel,
                         updateReviewButton,
                         selectImageButton,
                         userReviewImageView,
                         deleteMethodLabel
        )
    }
    
    override func setLayout() {
        menuLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(130)
            make.centerX.equalToSuperview()
        }
                
        starStackView.snp.makeConstraints { make in
            make.top.equalTo(menuLabel.snp.bottom).offset(11)
            make.centerX.equalToSuperview()
        }
        
        userReviewTextView.snp.makeConstraints { make in
            make.top.equalTo(starStackView.snp.bottom).offset(33)
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
        
        updateReviewButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-61)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }
        
        deleteMethodLabel.snp.makeConstraints {
            $0.top.equalTo(selectImageButton.snp.bottom).offset(7)
            $0.trailing.equalTo(userReviewTextView)
        }
    }
    
    override func setButtonEvent() {
        updateReviewButton.addTarget(self, action: #selector(userTappedNextButton), for: .touchUpInside)
    }
    
    // FIXME: - TextView placeholder 커스텀 수정
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            self.userReviewTextView.resignFirstResponder()
        }
    
    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = "리뷰 남기기"
    }
    
    func setStarButtons() {
        for i in 0...personalRate - 1 {
            let button = UIButton()
            button.setImage(starFillImage, for: .normal)
            button.snp.makeConstraints { make in
                make.height.equalTo(23.88)
                make.width.equalTo(24.99)
            }
            button.tag = i
            starButtons += [button]
            starStackView.addArrangedSubview(button)
        }
        
        for i in personalRate..<5 {
            let button = UIButton()
            button.setImage(starEmptyImage, for: .normal)
            button.snp.makeConstraints { make in
                make.height.equalTo(23.88)
                make.width.equalTo(24.99)
            }
            button.tag = i
            starButtons += [button]
            starStackView.addArrangedSubview(button)
        }
    }
    
    // UIImagePickerControllerDelegate method
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            userReviewImageView.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc
    func userTappedNextButton() {
        if userReviewTextView.text != "" {
//            postWriteReviewRequest(menuId: 35,
//                                   grade: grade,
//                                   reviewTag: ["GOOD"],
//                                   content: userReviewTextView.text,
//                                   image: userReviewImageView.image ?? UIImage())
            if let reviewViewController = self.navigationController?.viewControllers.first(where: { $0 is ReviewViewController }) {
                self.navigationController?.popToViewController(reviewViewController, animated: true)
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
    }
    
    func getGradeTag(grade: Int, tag: [String]) {
        self.grade = grade
        self.tag = tag
    }
}

extension WriteReviewViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = userReviewTextView.text.count - range.length + text.count
        if newLength > 150 {
          return false
        }
        return true
    }
}

// MARK: - Server

extension WriteReviewViewController {
    
//    func postWriteReviewRequest(menuId: Int, grade: Int, reviewTag:[String], content: String, image: UIImage) {
//        let imageData = image.jpegData(compressionQuality: 0.5) ?? Data()
//        let reviewContent = ReviewContent.init(mainGrade: 3, amountGrade: 3, tasteGrade: 3, content: "음.....")
//        let param = WriteReviewRequest.init(reviewCreate: reviewContent, multipartFileList: [imageData])
//
//        self.writeReviewProvider.request(.writeReview(param: param, menuId: menuId)) { response in
//            switch response {
//            case.success(let moyaResponse):
//                do {
//                    print(moyaResponse.statusCode)
//                }
//            case .failure(let err):
//                print(err.localizedDescription)
//            }
//        }
//    }
}
