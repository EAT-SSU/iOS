//
//  MyPageView.swift
//  EATSSU
//
//  Edited by Jiwoong CHOI on 1/31/25.
//

import UIKit

import EATSSUDesign

import SnapKit
import Then

/// `MyPageView`
///
/// 사용자 마이페이지 화면의 UI를 담당하는 뷰입니다.
/// - 사용자 프로필 이미지, 닉네임, 계정 정보 등을 표시합니다.
/// - 앱 버전 정보 및 회원 탈퇴 기능을 제공합니다.
///
final class MyPageView: BaseUIView {
    // MARK: - UI Components

    /// **마이페이지 전체를 감싸는 스크롤 뷰**
    let scrollView = UIScrollView()

    /// **스크롤 뷰 내부 콘텐츠 뷰**
    let contentView = UIView()

    /// **사용자 프로필 이미지**
    let userImage = UIImageView().then {
        $0.image = UIImage(systemName: "person.crop.circle")
        $0.tintColor = EATSSUDesignAsset.Color.GrayScale.gray300.color
    }

    /// **사용자 닉네임 라벨**
    let userNicknameLabel = UILabel().then {
        $0.text = "다시 시도해주세요"
        $0.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 16)
    }

    /// **"연결된 계정" 라벨**
    let accountTitleLabel = UILabel().then {
        $0.text = ESTextLiteral.MyPage.linkedAccount
        $0.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
    }

    /// **소셜 로그인 계정 유형 라벨 (초기값: "없음")**
    let accountTypeLabel = UILabel().then {
        $0.text = "없음"
        $0.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
    }

    /// **소셜 로그인 공급업체 아이콘**
    let accountTypeImage = UIImageView()

    /// **"연결된 계정" 라벨과 계정 정보를 포함하는 수직 스택 뷰**
    lazy var accountStackView = UIStackView(arrangedSubviews: [accountTypeLabel, accountTypeImage]).then {
        $0.alignment = .bottom
        $0.axis = .horizontal
        $0.spacing = 5
    }

    /// **"연결된 계정" 제목과 계정 정보를 포함하는 수평 스택 뷰**
    lazy var totalAccountStackView = UIStackView(arrangedSubviews: [accountTitleLabel, accountStackView]).then {
        $0.alignment = .bottom
        $0.axis = .horizontal
        $0.spacing = 20
    }

    /// **마이페이지 목록 테이블 뷰**
    let myPageTableView = UITableView().then {
        $0.separatorStyle = .none
        $0.isScrollEnabled = false
    }

    /// **앱 버전 정보 라벨**
    let appVersionStringLabel = UILabel().then {
        $0.text = ESTextLiteral.MyPage.appVersion
        $0.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)
        $0.textColor = EATSSUDesignAsset.Color.GrayScale.gray400.color
    }

    /// **현재 앱 버전 표시 라벨**
    let appVersionLabel = UILabel().then {
        $0.text = MyPageRightItemData.version
        $0.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)
        $0.textColor = EATSSUDesignAsset.Color.GrayScale.gray400.color
    }

    /// **회원 탈퇴 버튼 (아이콘 포함)**
    let userWithdrawButton: UIButton = {
        let button = UIButton()
        button.setTitle(ESTextLiteral.MyPage.withdraw, for: .normal)
        button.setImage(EATSSUDesignAsset.Images.withdrawIcon.image, for: .normal)
        button.setTitleColor(EATSSUDesignAsset.Color.GrayScale.gray400.color, for: .normal)
        button.titleLabel?.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 12)
        button.tintColor = .red
        return button
    }()

    /// **회원 탈퇴 버튼 아래에 표시되는 언더라인 뷰**
    let underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray400.color
        return view
    }()

    // MARK: - Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)
        registerTableViewCells()
    }

    // MARK: - UI 설정

    /// UI 구성 요소를 화면에 추가합니다.
    override func configureUI() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubviews(
            userImage,
            userNicknameLabel,
            totalAccountStackView,
            myPageTableView,
            appVersionStringLabel,
            appVersionLabel,
            userWithdrawButton,
            underLineView
        )
    }

    /// UI 레이아웃을 설정합니다.
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

        totalAccountStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(userNicknameLabel.snp.bottom).offset(10)
        }

        myPageTableView.snp.makeConstraints {
            $0.top.equalTo(accountTitleLabel.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(480)
            $0.width.equalToSuperview()
        }

        appVersionStringLabel.snp.makeConstraints {
            $0.top.equalTo(myPageTableView.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(24)
        }

        appVersionLabel.snp.makeConstraints {
            $0.top.equalTo(myPageTableView.snp.bottom).offset(6)
            $0.trailing.equalToSuperview().inset(24)
        }

        userWithdrawButton.snp.makeConstraints {
            $0.top.equalTo(appVersionLabel.snp.bottom).offset(16)
            $0.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(70)
        }

        underLineView.snp.makeConstraints {
            $0.top.equalTo(userWithdrawButton.snp.bottom)
            $0.leading.trailing.equalTo(userWithdrawButton)
            $0.height.equalTo(0.5)
        }
    }

    // MARK: - 기능

    /// 마이페이지 테이블 뷰의 셀을 등록합니다.
    func registerTableViewCells() {
        myPageTableView.register(MyPageTableDefaultCell.self, forCellReuseIdentifier: MyPageTableDefaultCell.identifier)
        myPageTableView.register(NotificationSettingTableViewCell.self, forCellReuseIdentifier: NotificationSettingTableViewCell.identifier)
    }

    /// 사용자 정보를 설정합니다.
    ///
    /// - Parameter nickname: 사용자 닉네임
    func setUserInfo(nickname: String) {
        userNicknameLabel.text = nickname
        userNicknameLabel.font = EATSSUDesignFontFamily.Pretendard.semiBold.font(size: 20)

        if let accountType = UserInfoManager.shared.getCurrentUserInfo()?.accountType {
            switch accountType {
            case .apple:
                accountTypeLabel.text = "APPLE"
                accountTypeImage.image = EATSSUDesignAsset.Images.signWithApple.image
            case .kakao:
                accountTypeLabel.text = "카카오"
                accountTypeImage.image = EATSSUDesignAsset.Images.signWithKakao.image
            }
        }
    }
}
