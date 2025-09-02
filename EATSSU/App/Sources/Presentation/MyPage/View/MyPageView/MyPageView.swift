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

    // 닉네임이 들어간 닉네임 변경 버튼
    var userNicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "다시 시도해주세요"
        label.textColor = .black
        label.font = EATSSUDesignFontFamily.Pretendard.semiBold.font(size: 20)
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
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray400.color
        return label
    }()

    // 현재 배포된 앱의 버전
    private let appVersionLabel: UILabel = {
        let label = UILabel()
        label.text = MyPageRightItemData.version
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray400.color
        return label
    }()

    /// "탈퇴하기" 레이블과 탈퇴하기 아이콘
    let userWithdrawButton: UIButton = {
        let button = UIButton()
        button.setTitle(TextLiteral.MyPage.withdraw, for: .normal)
        button.setImage(EATSSUDesignAsset.Images.withdrawIcon.image, for: .normal)
        button.setTitleColor(EATSSUDesignAsset.Color.GrayScale.gray400.color, for: .normal)
        button.titleLabel?.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)
        button.tintColor = .red
        return button
    }()

    /// "탈퇴하기" 레이블 underline
    private let underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray400.color
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
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.height.width.equalTo(100)
        }

        userNicknameLabel.snp.makeConstraints {
            $0.top.equalTo(userImage.snp.bottom).offset(6)
            $0.centerX.equalTo(userImage)
            $0.height.equalTo(40)
        }

        myPageTableView.snp.makeConstraints {
            $0.top.equalTo(userNicknameLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview()
            let cellHeight = 60
            let totalHeight = MyPageLocalData.myPageTableLabelList.count * cellHeight
            $0.height.equalTo(totalHeight)
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

    public func setUserInfo(nickname: String) {
        userNicknameLabel.text = nickname
    }
}
