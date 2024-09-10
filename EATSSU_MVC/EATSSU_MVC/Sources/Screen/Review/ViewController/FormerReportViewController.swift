//
//  FormerReportViewController.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/08/15.
//

import UIKit

import SnapKit
import Then
import Moya

/// ReportViewController로 대체되었습니다.
///
/// QA 진행 후 문제가 없으면 제거
final class FormerReportViewController: BaseViewController {

    // MARK: - Properties
    
    private var isChecked = false
    private var isReasonSelected = false
    private var status: Int = Int()
    private var buttonArray: [UIButton] = []
    private var contentArray: [String?] = []
    private var reviewID: Int = Int()
    private let reviewProvider = MoyaProvider<ReviewRouter>(plugins: [MoyaLoggingPlugin()])

    
    // MARK: - UI Components
    
    private let alertDeclarationLabel = UILabel().then {
        $0.text = "리뷰를 신고하는 이유를 선택해주세요."
        $0.font = .bold(size: 16)
    }

    private let report1Label = UILabel().then {
        $0.text = "메뉴와 관련없는 내용"
    }

    private let report2Label = UILabel().then {
        $0.text = "음란성, 욕설 등 부적절한 내용"
    }

    private let report3Label = UILabel().then {
        $0.text = "부적절한 홍보 또는 광고"
    }

    private let report4Label = UILabel().then {
        $0.text = "리뷰 작성 취지에 맞지 않는 내용 (복사글 등)"
    }

    private let report5Label = UILabel().then {
        $0.text = "저작권 도용 의심 (사진 등)"
    }

    private let report6Label = UILabel().then {
        $0.text = "기타 (하단 내용 작성)"
    }
    
    private var report1Button = UIButton()
    
    private var report2Button = UIButton()
    
    private var report3Button = UIButton()
    
    private var report4Button = UIButton()
    
    private var report5Button = UIButton()
    
    private var report6Button = UIButton()
    
    lazy var report1StackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [report1Button,
                                                       report1Label
                                                      ])
        stackView.axis = .horizontal
        stackView.spacing = 7
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var report2StackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [report2Button,
                                                       report2Label
                                                      ])
        stackView.axis = .horizontal
        stackView.spacing = 7
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var report3StackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [report3Button,
                                                       report3Label
                                                      ])
        stackView.axis = .horizontal
        stackView.spacing = 7
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var report4StackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [report4Button,
                                                       report4Label
                                                      ])
        stackView.axis = .horizontal
        stackView.spacing = 7
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var report5StackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [report5Button,
                                                       report5Label
                                                      ])
        stackView.axis = .horizontal
        stackView.spacing = 7
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var report6StackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [report6Button,
                                                       report6Label
                                                      ])
        stackView.axis = .horizontal
        stackView.spacing = 7
        stackView.alignment = .center
        return stackView
    }()

    lazy var reportStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [report1StackView,
                                                       report2StackView,
                                                       report3StackView,
                                                       report4StackView,
                                                       report5StackView,
                                                       report6StackView
                                                      ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
        return stackView
    }()

    private let userReportTextView: UITextView = {
        let textView = UITextView()
        textView.font = .medium(size: 16)
        textView.layer.cornerRadius = 10
        textView.backgroundColor = .gray100
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.gray200.cgColor
        textView.textContainerInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
        textView.isEditable = false
        return textView
    }()

    private let textLimitLabel = UILabel().then {
        $0.text = "0 / 150"
        $0.font = .medium(size: 12)
        $0.textColor = .gray700
    }

    private let sendButton = MainButton().then {
        $0.title = "EAT SSU에게 보내기"
    }

    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setDelegate()
        addArray()
        setButtonEvent()
        setCustomNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeKeyboardNotifications()
    }

    //MARK: - Functions
    
    override func configureUI() {
        dismissKeyboard()
        view.addSubviews(alertDeclarationLabel,
                         reportStackView,
                         userReportTextView,
                         textLimitLabel,
                         sendButton
                         )
        
        [report1Button, report2Button, report3Button, report4Button, report5Button, report6Button].forEach {
            $0.setImage(ImageLiteral.uncheckedIcon, for: .normal)
            $0.setImage(ImageLiteral.checkedIcon, for: .selected)
        }

        [report1Label,report2Label,report3Label,report4Label,report5Label, report6Label].forEach {
            $0.font = .medium(size: 16)
            $0.textColor = .gray700
        }

    }

    override func setLayout() {
        alertDeclarationLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(30)
            $0.leading.equalToSuperview().offset(16)
        }
        
        reportStackView.snp.makeConstraints {
            $0.top.equalTo(alertDeclarationLabel.snp.bottom).offset(22)
            $0.leading.equalToSuperview().offset(16)
        }
        userReportTextView.snp.makeConstraints {
            $0.top.equalTo(reportStackView.snp.bottom).offset(29)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
            $0.height.equalTo(181)
        }
        textLimitLabel.snp.makeConstraints {
            $0.top.equalTo(userReportTextView.snp.bottom).offset(3)
            $0.trailing.equalToSuperview().inset(16)
        }
        sendButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(17)
        }
    }

    override func setButtonEvent() {
        [report1Button, report2Button, report3Button, report4Button, report5Button, report6Button].forEach {
            $0.addTarget(self, action: #selector(checkButtonIsTapped(_:)), for: .touchUpInside)
        }
        sendButton.addTarget(self, action: #selector(sendButtonIsTapped), for: .touchUpInside)
    }

    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        self.title = "신고하기"
        
        let navBarApperance = UINavigationBarAppearance()
        navBarApperance.configureWithOpaqueBackground()
        
        navBarApperance.titleTextAttributes = [.foregroundColor: UIColor.primary, .font: UIFont.bold(size: 18)]
        navBarApperance.backgroundColor = .white
        navBarApperance.shadowColor = nil

        navigationController?.navigationBar.standardAppearance = navBarApperance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarApperance
    }
    
    private func setDelegate() {
        userReportTextView.delegate = self
    }
    
    private func addArray() {
        report1Button.tag = 0
        report2Button.tag = 1
        report3Button.tag = 2
        report4Button.tag = 3
        report5Button.tag = 4
        report6Button.tag = 5
        
        [report1Button,
         report2Button,
         report3Button,
         report4Button,
         report5Button,
         report6Button].forEach {
            buttonArray.append($0)
        }
        
        [report1Label.text,
         report2Label.text,
         report3Label.text,
         report4Label.text,
         report5Label.text,
         report6Label.text].forEach {
            contentArray.append($0)
        }
    }
    
    @objc
    private func checkButtonIsTapped(_ sender: UIButton) {
        isReasonSelected = true
        if isChecked {
            buttonArray[status].isSelected = false
        }
        sender.isSelected = true
        isChecked = true
        status = sender.tag
        canTextViewUsed(status: status)
    }
    
    private func canTextViewUsed(status: Int) {
        if status == 5 {
            userReportTextView.isEditable = true
        } else {
            userReportTextView.isEditable = false
        }
    }
    
    func bindData(reviewID: Int) {
        self.reviewID = reviewID
    }
    
    @objc
    private func sendButtonIsTapped() {
        if isReasonSelected {
            postReport(reviewID: reviewID, content: contentArray[status] ?? "")
        } else {
            view.showToast(message: "사유를 선택해주세요!")
        }
    }
    
    // 키보드가 나타났다는 알림을 받으면 실행할 메서드
    @objc
    func keyboardWillShow(_ noti: NSNotification) {
        /// 키보드 높이만큼 뷰 올림
        if let keyboardFrame: NSValue = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let buttonHeight = 70.0
            UIView.animate(
                withDuration: 0.3,
                animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -(keyboardRectangle.height - buttonHeight))
                }
            )
        }
    }

    // 키보드가 사라졌다는 알림을 받으면 실행할 메서드
    @objc
    func keyboardWillHide(_ noti: NSNotification) {
        /// 뷰 원상태로 복귀
        self.view.transform = .identity
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
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "리뷰 신고 성공",
                                      message: "신고가 성공적으로 접수되었어요!",
                                      preferredStyle: UIAlertController.Style.alert
        )
        
        let okAction = UIAlertAction(title: "리뷰 화면으로 돌아가기",
                                         style: .default,
                                         handler: { okAction in
            self.navigationController?.popViewController(animated: true)
        })
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate

extension FormerReportViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = userReportTextView.text.count - range.length + text.count
        textLimitLabel.text = "\(userReportTextView.text.count) / 150"
        if newLength > 150 {
          return false
        }
        return true
    }
}

// MARK: - Server

extension FormerReportViewController {
    private func postReport(reviewID: Int, content: String) {
        var reportType: String = String()
        var reportContent: String = String()
        switch content {
        case "메뉴와 관련없는 내용":
            reportType = "NO_ASSOCIATE_CONTENT"
            reportContent = content
        case "음란성, 욕설 등 부적절한 내용":
            reportType = "IMPROPER_CONTENT"
            reportContent = content
        case "부적절한 홍보 또는 광고":
            reportType = "IMPROPER_ADVERTISEMENT"
            reportContent = content
        case "리뷰 작성 취지에 맞지 않는 내용 (복사글 등)":
            reportType = "COPY"
            reportContent = content
        case "저작권 도용 의심 (사진 등)":
            reportType = "COPYRIGHT"
            reportContent = content
        case "기타 (하단 내용 작성)":
            reportType = "EXTRA"
            reportContent = userReportTextView.text
        default:
            reportType = ""
            reportContent = ""
        }
        
        let param = ReportRequest(reviewId: reviewID,
                                  reportType: reportType,
                                  content: reportContent
        )
        
        self.reviewProvider.request(.report(param: param)) { response in
            switch response {
            case.success(_):
                do {
                    self.showSuccessAlert()
                }
            case .failure(let err):
                print(err.localizedDescription)
                self.view.showToast(message: "잠시후 다시 시도해주세요.")
            }
        }
    }
}
