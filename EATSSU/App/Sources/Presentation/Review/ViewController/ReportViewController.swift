//
//  ReportViewController.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 8/30/24.
//

import UIKit

import Moya
import SnapKit
import FirebaseAnalytics

import EATSSUDesign

final class ReportViewController: BaseViewController {
    // MARK: - Properties
    
    // View Properties
    private let reportView = ReportView()
    private let scrollView = UIScrollView()
    
    private let sendToEATSSUButton = ESButton(size: .big, title: "EAT SSU 팀에게 보내기")
    
    // Variable Properties
    private var isChecked = false
    private var isReasonSelected = false
    private var status: Int = .init()
    private var buttonArray: [UIButton] = []
    private var contentArray: [String?] = []
    private var reviewID: Int = .init()
    
    override var shouldHideTabBar: Bool {
        return true
    }
    
    // MARK: - View Life Cycle
    
    override func viewWillAppear(_: Bool) {
        addKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        logScreenView(screenID: FirebaseScreenID.Review.V1.review_v1_5)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setLayout()
        setScrollViewSetting()
        addArray()
        setButtonEvent()
        setCustomNavigationBar()
        
        sendToEATSSUButton.isEnabled = false
    }
    
    override func viewWillDisappear(_: Bool) {
        removeKeyboardNotifications()
    }
    
    // MARK: - Methods
    
    override func configureUI() {
        view.addSubview(sendToEATSSUButton)
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(sendToEATSSUButton.snp.top)
        }
        
        
        sendToEATSSUButton.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view).inset(24)
//            make.height.equalTo(52)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
        }
        
        
        scrollView.addSubview(reportView)
        reportView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
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
        
        sendToEATSSUButton.addTarget(self, action: #selector(sendButtonIsTapped), for: .touchUpInside)
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
            .foregroundColor: UIColor.gray700,
            .font: EATSSUDesignFontFamily.Pretendard.bold.font(size: 18),
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
            showToast(message: "사유를 선택해주세요!", type: .info)
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

        if status == 5 {
            reportView.enableTextView()
        } else {
            reportView.disableTextView()
        }
        
        sendToEATSSUButton.isEnabled = true
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
        guard let navigationController = self.navigationController,
              navigationController.viewControllers.count > 1 else {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        let viewControllers = navigationController.viewControllers
        let previousVC = viewControllers[viewControllers.count - 2]
        
        self.navigationController?.popViewController(animated: true)
        
        navigationController.transitionCoordinator?.animate(alongsideTransition: nil, completion: { _ in
            previousVC.showToast(message: "신고가 성공적으로 접수되었어요!", type: .success)
        })
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
        
        NetworkService.shared.request(
            ReviewRouter.report(param: param),
            responseType: Bool.self,
            useAuth: true
        ) { [weak self] result in
            switch result {
            case .success:
                self?.showSuccessAlert()
                
            case .failure(let error):
                print("신고 실패: \(error.localizedDescription)")
                self?.showToast(message: "잠시 후 다시 시도해주세요.", type: .danger)
            }
        }
    }
}
