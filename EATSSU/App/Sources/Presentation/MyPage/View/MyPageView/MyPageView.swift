//
//  MyPageView.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/25.
//

import UIKit

import SnapKit

import EATSSUDesign

final class MyPageView: BaseUIView {
    // MARK: - Properties
    private static var appVersion: String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return "-"
        }

        return version
    }
    
    private var myPageTableViewHeight: CGFloat {
        let rowTotalHeight = MyPageSectionData.sections.reduce(CGFloat(0)) { result, section in
            let sectionRowHeight = section.items.reduce(CGFloat(0)) { rowResult, item in
                return rowResult + MyPageTableMetric.rowHeight(for: item)
            }

            return result + sectionRowHeight
        }

        let sectionCount = MyPageSectionData.sections.count
        let headerTotalHeight = CGFloat(sectionCount) * MyPageTableMetric.headerHeight

        let footerCount = max(sectionCount - 1, 0)
        let footerTotalHeight = CGFloat(footerCount) * MyPageTableMetric.footerHeight

        return rowTotalHeight + headerTotalHeight + footerTotalHeight
    }
    
    // MARK: - UI Components
    
    /// MyPageView 전체 스크롤뷰
    private let scrollView = UIScrollView()
    
    /// 스크롤뷰 안에 들어갈 콘텐츠 뷰
    private let contentView = UIView()
    
    // 사용자 이미지
    var userImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.profile.image
        return imageView
    }()
    
    // 유저 닉네임
    var userNicknameLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.MyPage.retry
        label.textColor = .gray700Basic
        label.font = .subtitle2
        return label
    }()
    
    // 유저 소속
    var userAffiliationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray600
        label.font = .body3
        label.numberOfLines = 1
        return label
    }()
    
    let myPageTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    // "앱 버전" 레이블
    private let appVersionStringLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.MyPage.appVersion
        label.font = .caption2
        label.textColor = .gray400
        return label
    }()
    
    // 현재 배포된 앱의 버전
    private let appVersionLabel: UILabel = {
        let label = UILabel()
        label.text = appVersion
        label.font = .caption2
        label.textColor = .gray400
        return label
    }()
    
    /// "탈퇴하기" 레이블과 탈퇴하기 아이콘
    let userWithdrawButton: UIButton = {
        let button = UIButton()
        button.setTitle(TextLiteral.MyPage.withdrawButton, for: .normal)
        button.setImage(EATSSUDesignAsset.Images.withdrawIcon.image, for: .normal)
        button.setTitleColor(.gray400, for: .normal)
        button.titleLabel?.font = .caption2
        button.tintColor = .red
        button.semanticContentAttribute = .forceRightToLeft
        return button
    }()
    
    /// "탈퇴하기" 레이블 underline
    private let underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray400
        return view
    }()
    
    // MARK: - Intializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        registerTableViewCells()
    }
    
    // MARK: - Functions
    
    override func configureUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubviews(
            userImage,
            userNicknameLabel,
            userAffiliationLabel,
            myPageTableView,
            appVersionStringLabel,
            appVersionLabel,
            userWithdrawButton,
            underLineView
        )
    }
    
    override func setLayout() {
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView)
        }
        
        userImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().inset(24)
            $0.height.width.equalTo(48)
        }
        
        userNicknameLabel.snp.makeConstraints {
            $0.leading.equalTo(userImage.snp.trailing).offset(12)
            $0.bottom.equalTo(userImage.snp.centerY)
        }
        
        userAffiliationLabel.snp.makeConstraints {
            $0.top.equalTo(userNicknameLabel.snp.bottom)
            $0.leading.equalTo(userNicknameLabel.snp.leading)
        }
        
        myPageTableView.snp.makeConstraints {
            $0.top.equalTo(userImage.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(myPageTableViewHeight)
            $0.width.equalToSuperview()
        }
        
        appVersionStringLabel.snp.makeConstraints { make in
            make.top.equalTo(myPageTableView.snp.bottom).offset(6)
            make.leading.equalToSuperview().inset(24)
        }
        
        appVersionLabel.snp.makeConstraints { make in
            make.top.equalTo(myPageTableView.snp.bottom).offset(6)
            make.trailing.equalToSuperview().inset(24)
        }
        
        // TODO: withdrawStackView를 프로퍼티로 선언할 때, lazy를 사용하면 레이아웃이 한 타임 늦게 잡히는 문제로 인해서 여기에서 스택 안에 들어갈 뷰를 추가함. 개선 방법이 없는지 확인.
        userWithdrawButton.snp.makeConstraints { make in
            make.top.equalTo(appVersionLabel.snp.bottom).offset(16)
            make.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(70)
        }
        
        underLineView.snp.makeConstraints {
            $0.top.equalTo(userWithdrawButton.snp.bottom)
            $0.leading.trailing.equalTo(userWithdrawButton)
            $0.height.equalTo(0.5)
        }
    }
    
    private func registerTableViewCells() {
        myPageTableView.register(
            MyPageTableDefaultCell.self,
            forCellReuseIdentifier: MyPageTableDefaultCell.identifier
        )
        myPageTableView.register(
            NotificationSettingTableViewCell.self,
            forCellReuseIdentifier: NotificationSettingTableViewCell.identifier
        )
    }
    
    public func setUserInfo(
        nickname: String,
        collegeName: String?,
        departmentName: String?
    ) {
        userNicknameLabel.text = nickname

        let affiliationText = [collegeName, departmentName]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        userAffiliationLabel.text = affiliationText
        userAffiliationLabel.isHidden = affiliationText.isEmpty
    }
}
