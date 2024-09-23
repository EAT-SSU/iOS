//
//  ReportView.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 8/30/24.
//

// Swift Module
import UIKit

// External Dependency
import SnapKit

// EATSSU Module
import EATSSUComponents

final class ReportView: BaseUIView {
  
  // MARK: - Properties
  
  
  // MARK: - UI Components
  
  /// "리뷰 신고 사유를 알려주세요" 레이블
  private let reviewReportReasonLabel: UILabel = {
    let label = UILabel()
    label.text = "리뷰 신고 사유를 알려주세요"
    label.font = EATSSUFontFamily.Pretendard.bold.font(size: 18)
    label.textColor = .black
    return label
  }()
  
  /// "하나의 리뷰에 대해 24시간 내 한 번만 신고 가능합니다." 레이블
  private let singleReportPerDayLabel: UILabel = {
    let label = UILabel()
    label.text = "하나의 리뷰에 대해 24시간 내 한 번만 신고 가능합니다."
    label.font = EATSSUFontFamily.Pretendard.regular.font(size: 12)
    label.textColor = EATSSUAsset.Color.GrayScale.gray600.color
    return label
  }()
  
  /// "메뉴와 관련없는 내용" 버튼
  internal let unrelatedToMenuButton = ESReportButton(title: "메뉴와 관련없는 내용")
  
  /// "음란성, 욕설 등 부적절한 내용" 버튼
  internal let inappropriateContentButton = ESReportButton(title: "음란성, 욕설 등 부적절한 내용")
  
  /// " 부적절한 홍보 또는 광고" 버튼
  internal let inappropriatePromotionButton = ESReportButton(title: "부적절한 홍보 또는 광고")
  
  /// "리뷰 작성 취지에 맞지 않는 내용 (복사글 등)" 버튼
  internal let offTopicContentButton = ESReportButton(title: "리뷰 작성 취지에 맞지 않는 내용 (복사글 등)")
  
  /// "저작권 도용 의심 (사진 등)" 버튼
  internal let copyrightInfringementButton = ESReportButton(title: "저작권 도용 의심 (사진 등)")
  
  /// "기타 (하단 내용 작성)" 버튼
  internal let otherReasonButton = ESReportButton(title: "기타 (하단 내용 작성)")
  
  /// "리뷰 신고 사유를 작성해 주세요" 텍스트필드
  internal var reviewReportReasonTextView: UITextView = {
    let textView = UITextView()
    textView.font = EATSSUFontFamily.Pretendard.medium.font(size: 16)
    textView.layer.cornerRadius = 10
    textView.backgroundColor = EATSSUAsset.Color.GrayScale.gray100.color
    textView.layer.borderWidth = 1
    textView.layer.borderColor =  EATSSUAsset.Color.GrayScale.gray200.color.cgColor
    textView.textContainerInset = UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
    textView.isEditable = false
    return textView
  }()
  
  /// 0 / 300 와 같이 현재 작성된 글자 수 상태 레이블
  internal var characterCountLabel: UILabel = {
    let label = UILabel()
    label.text = "0 / 300"
    label.font = EATSSUFontFamily.Pretendard.regular.font(size: 12)
    label.textColor = EATSSUAsset.Color.GrayScale.gray400.color
    return label
  }()
  
  /// "EAT SSU 팀에게 보내기" 버튼
  internal let sendToEATSSUButton = ESButton(size: .big, title: "EAT SSU 팀에게 보내기")
  
  // MARK: - Initializer

  init() {
    super.init(frame: .zero)
    
    self.setLayout()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  internal override func setLayout() {
    self.addSubviews(
      reviewReportReasonLabel,
      singleReportPerDayLabel,
      unrelatedToMenuButton,
      inappropriateContentButton,
      inappropriatePromotionButton,
      offTopicContentButton,
      copyrightInfringementButton,
      otherReasonButton,
      reviewReportReasonTextView,
      characterCountLabel,
      sendToEATSSUButton
    )
    
    reviewReportReasonLabel.snp.makeConstraints { make in
      make.leading.equalTo(self).inset(24)
      make.trailing.equalTo(self).inset(166)
      make.top.equalTo(safeAreaLayoutGuide.snp.top)
    }
    
    singleReportPerDayLabel.snp.makeConstraints { make in
      make.leading.equalTo(self).inset(24)
      make.top.equalTo(reviewReportReasonLabel.snp.bottom).offset(4)
    }
    
    unrelatedToMenuButton.snp.makeConstraints { make in
      make.leading.trailing.equalTo(self).inset(24)
      make.height.equalTo(52)
      make.top.equalTo(singleReportPerDayLabel.snp.bottom).offset(16)
    }
    
    inappropriateContentButton.snp.makeConstraints { make in
      make.leading.trailing.equalTo(self).inset(24)
      make.height.equalTo(52)
      make.top.equalTo(unrelatedToMenuButton.snp.bottom).offset(12)
    }
    
    inappropriatePromotionButton.snp.makeConstraints { make in
      make.leading.trailing.equalTo(self).inset(24)
      make.height.equalTo(52)
      make.top.equalTo(inappropriateContentButton.snp.bottom).offset(12)
    }

    offTopicContentButton.snp.makeConstraints { make in
      make.leading.trailing.equalTo(self).inset(24)
      make.height.equalTo(52)
      make.top.equalTo(inappropriatePromotionButton.snp.bottom).offset(12)
    }

    copyrightInfringementButton.snp.makeConstraints { make in
      make.leading.trailing.equalTo(self).inset(24)
      make.height.equalTo(52)
      make.top.equalTo(offTopicContentButton.snp.bottom).offset(12)
    }

    otherReasonButton.snp.makeConstraints { make in
      make.leading.trailing.equalTo(self).inset(24)
      make.height.equalTo(52)
      make.top.equalTo(copyrightInfringementButton.snp.bottom).offset(12)
    }
    
    reviewReportReasonTextView.snp.makeConstraints { make in
      make.leading.trailing.equalTo(self).inset(24)
      make.height.equalTo(180)
      make.top.equalTo(otherReasonButton.snp.bottom).offset(16)
    }
    
    characterCountLabel.snp.makeConstraints { make in
      make.trailing.equalTo(reviewReportReasonTextView)
      make.top.equalTo(reviewReportReasonTextView.snp.bottom).offset(6)
    }
    
    sendToEATSSUButton.snp.makeConstraints { make in
      make.leading.trailing.equalTo(self).inset(24)
      make.height.equalTo(52)
      make.top.equalTo(reviewReportReasonTextView.snp.bottom).offset(56)
    }
  }

}
