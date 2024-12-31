//
//  ReportViewController.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 8/30/24.
//

// Swift Module
import UIKit

import Moya

// External Module
import SnapKit

final class ReportViewController: BaseViewController {
    // MARK: - Properties

    // View Properties
    private let reportView = ReportView()
    private let scrollView = UIScrollView()

    // Variable Properties
    private var isChecked = false
    private var isReasonSelected = false
    private var status: Int = .init()
    private var buttonArray: [UIButton] = []
    private var contentArray: [String?] = []
    private var reviewID: Int = .init()
    private let reviewProvider = MoyaProvider<ReviewRouter>(plugins: [MoyaLoggingPlugin()])

    // MARK: - View Life Cycle

    override func viewWillAppear(_: Bool) {
        addKeyboardNotifications()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        setLayout()
        setScrollViewSetting()
        setDelegate()
        addArray()
        setButtonEvent()
        setCustomNavigationBar()
    }

    override func viewWillDisappear(_: Bool) {
        removeKeyboardNotifications()
    }

    // MARK: - Methods

    override func configureUI() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        scrollView.addSubview(reportView)
        reportView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)

            make.height.equalTo(800)
        }
    }

    override func setLayout() {
        super.setLayout()
    }

    private func setScrollViewSetting() {
        scrollView.frame = view.bounds
        scrollView.contentSize = reportView.intrinsicContentSize

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = false

        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
    }

    override func setButtonEvent() {
        [reportView.unrelatedToMenuButton,
         reportView.inappropriateContentButton,
         reportView.inappropriatePromotionButton,
         reportView.offTopicContentButton,
         reportView.copyrightInfringementButton,
         reportView.otherReasonButton].forEach {
            $0.addTarget(self, action: #selector(checkButtonIsTapped(_:)), for: .touchUpInside)
        }
        reportView.sendToEATSSUButton.addTarget(self, action: #selector(sendButtonIsTapped), for: .touchUpInside)
    }

    func bindData(reviewID: Int) {
        self.reviewID = reviewID
    }

    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        title = "신고하기"

        let navBarApperance = UINavigationBarAppearance()
        navBarApperance.configureWithOpaqueBackground()

        navBarApperance.titleTextAttributes = [
            .foregroundColor: EATSSUAsset.Color.GrayScale.gray700.color,
            .font: EATSSUFontFamily.Pretendard.bold.font(size: 18),
        ]
        navBarApperance.backgroundColor = .white
        navBarApperance.shadowColor = nil

        navigationController?.navigationBar.standardAppearance = navBarApperance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarApperance
    }

    private func addArray() {
        reportView.unrelatedToMenuButton.tag = 0
        reportView.inappropriateContentButton.tag = 1
        reportView.inappropriatePromotionButton.tag = 2
        reportView.offTopicContentButton.tag = 3
        reportView.copyrightInfringementButton.tag = 4
        reportView.otherReasonButton.tag = 5

        [reportView.unrelatedToMenuButton,
         reportView.inappropriateContentButton,
         reportView.inappropriatePromotionButton,
         reportView.offTopicContentButton,
         reportView.copyrightInfringementButton,
         reportView.otherReasonButton].forEach {
            buttonArray.append($0)
        }

        [reportView.unrelatedToMenuButton.titleLabel?.text,
         reportView.inappropriateContentButton.titleLabel?.text,
         reportView.inappropriatePromotionButton.titleLabel?.text,
         reportView.offTopicContentButton.titleLabel?.text,
         reportView.copyrightInfringementButton.titleLabel?.text,
         reportView.otherReasonButton.titleLabel?.text].forEach {
            contentArray.append($0)
        }
    }

    @objc
    private func sendButtonIsTapped() {
        if isReasonSelected {
            postReport(reviewID: reviewID, content: contentArray[status] ?? "")
        } else {
            view.showToast(message: "사유를 선택해주세요!")
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
            reportView.reviewReportReasonTextView.isEditable = true
        } else {
            reportView.reviewReportReasonTextView.isEditable = false
        }
    }

    private func setDelegate() {
        reportView.reviewReportReasonTextView.delegate = self
    }

    @objc
    private func keyboardWillShow(_ noti: NSNotification) {
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

    @objc
    private func keyboardWillHide(_: NSNotification) {
        view.transform = .identity
    }

    /// 노티피케이션을 추가하는 메서드
    private func addKeyboardNotifications() {
        // 키보드가 나타날 때 앱에게 알리는 메서드 추가
        NotificationCenter
            .default
            .addObserver(self,
                         selector: #selector(keyboardWillShow(_:)),
                         name: UIResponder.keyboardWillShowNotification,
                         object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 추가
        NotificationCenter
            .default
            .addObserver(self,
                         selector: #selector(keyboardWillHide(_:)),
                         name: UIResponder.keyboardWillHideNotification,
                         object: nil)
    }

    /// 노티피케이션을 제거하는 메서드
    private func removeKeyboardNotifications() {
        // 키보드가 나타날 때 앱에게 알리는 메서드 제거
        NotificationCenter
            .default
            .removeObserver(self,
                            name: UIResponder.keyboardWillShowNotification,
                            object: nil)
        // 키보드가 사라질 때 앱에게 알리는 메서드 제거
        NotificationCenter
            .default
            .removeObserver(self,
                            name: UIResponder.keyboardWillHideNotification,
                            object: nil)
    }

    private func showSuccessAlert() {
        let alert = UIAlertController(title: "리뷰 신고 성공",
                                      message: "신고가 성공적으로 접수되었어요!",
                                      preferredStyle: UIAlertController.Style.alert)

        let okAction = UIAlertAction(title: "리뷰 화면으로 돌아가기",
                                     style: .default,
                                     handler: { [weak self] _ in
                                         self?.navigationController?.popViewController(animated: true)
                                     })

        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

extension ReportViewController: UITextViewDelegate {
    func textView(_: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = reportView.reviewReportReasonTextView.text.count - range.length + text.count
        reportView.characterCountLabel.text = "\(reportView.reviewReportReasonTextView.text.count) / 300"

        if newLength > 300 {
            return false
        } else {
            return true
        }
    }
}

// MARK: - Server

extension ReportViewController {
    private func postReport(reviewID: Int, content: String) {
        var reportType = String()
        var reportContent = String()
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
            reportContent = reportView.reviewReportReasonTextView.text
        default:
            reportType = ""
            reportContent = ""
        }

        let param = ReportRequest(reviewId: reviewID,
                                  reportType: reportType,
                                  content: reportContent)

        reviewProvider.request(.report(param: param)) { response in
            switch response {
            case .success:
                do {
                    self.showSuccessAlert()
                }
            case let .failure(err):
                print(err.localizedDescription)
                self.view.showToast(message: "잠시후 다시 시도해주세요.")
            }
        }
    }
}
