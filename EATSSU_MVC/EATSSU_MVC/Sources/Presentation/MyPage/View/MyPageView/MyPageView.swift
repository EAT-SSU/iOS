//
//  MyPageView.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/25.
//

import UIKit

import SnapKit
import Then

final class MyPageView: BaseUIView {
	// MARK: - Properties
    
	// MARK: - UI Components
    
    /// MyPageView 전체 스크롤뷰
    private let scrollView = UIScrollView()
    
    /// 스크롤뷰 안에 들어갈 콘텐츠 뷰
    private let contentView = UIView()
    
	// 사용자 이미지
	var userImage = UIImageView().then {
		$0.image = ImageLiteral.profileIcon
	}
  
	// 닉네임이 들어간 닉네임 변경 버튼
	var userNicknameButton = UIButton().then {
		$0.addTitleAttribute(
			title: "다시 시도해주세요",
			titleColor: .black,
			fontName: EATSSUFontFamily.Pretendard.regular.font(size: 16))
	}
	
	// "연결된 계정" 레이블
	let accountTitleLabel = UILabel().then {
		$0.text = TextLiteral.MyPage.linkedAccount
		$0.font = EATSSUFontFamily.Pretendard.regular.font(size: 14)
	}
    
	// 서버에서 계정 정보를 가져오기 전 기본값
	var accountTypeLabel = UILabel().then {
		$0.text = "없음"
		$0.font = EATSSUFontFamily.Pretendard.regular.font(size: 14)
		$0.font = .bold(size: 14)
	}
    
	// 소셜 로그인 공급업체 아이콘
	var accountTypeImage = UIImageView()
    
	lazy var totalAccountStackView = UIStackView(
		arrangedSubviews: [accountTitleLabel, accountStackView]).then {
		$0.alignment = .bottom
		$0.axis = .horizontal
		$0.spacing = 20
	}
    
	lazy var accountStackView = UIStackView(
		arrangedSubviews: [accountTypeLabel, accountTypeImage]).then {
		$0.alignment = .bottom
		$0.axis = .horizontal
		$0.spacing = 5
	}
    
	let myPageTableView = UITableView().then {
		$0.separatorStyle = .none
		$0.isScrollEnabled = false
	}
	
	// "앱 버전" 레이블
	private let appVersionStringLabel = UILabel().then { label in
		label.text = TextLiteral.MyPage.appVersion
		label.font = EATSSUFontFamily.Pretendard.regular.font(size: 12)
		label.textColor = EATSSUAsset.Color.GrayScale.gray400.color
	}
	
	// 현재 배포된 앱의 버전
	private let appVersionLabel = UILabel().then { label in
		label.text = MyPageRightItemData.version
		label.font = EATSSUFontFamily.Pretendard.regular.font(size: 12)
		label.textColor = EATSSUAsset.Color.GrayScale.gray400.color
	}
	
	/// "탈퇴하기" 레이블과 탈퇴하기 아이콘
	let userWithdrawButton: UIButton = {
		let button = UIButton()
		button.setTitle(TextLiteral.MyPage.withdraw, for: .normal)
		button.setImage(EATSSUAsset.Images.Version2.withdrawIcon.image, for: .normal)
		button.setTitleColor(EATSSUAsset.Color.GrayScale.gray400.color, for: .normal)
		button.titleLabel?.font = EATSSUFontFamily.Pretendard.regular.font(size: 12)
		return button
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
        
        // 콘텐츠 뷰에 기존 UI 요소 추가
        contentView.addSubviews(
            userImage,
            userNicknameButton,
            totalAccountStackView,
            myPageTableView,
            appVersionStringLabel,
            appVersionLabel,
            userWithdrawButton
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
		
		userNicknameButton.snp.makeConstraints {
			$0.top.equalTo(userImage.snp.bottom).offset(6)
			$0.centerX.equalTo(userImage)
			$0.height.equalTo(40)
		}

		totalAccountStackView.snp.makeConstraints {
			$0.centerX.equalToSuperview()
			$0.top.equalTo(userNicknameButton.snp.bottom).offset(10)
		}
		
		myPageTableView.snp.makeConstraints {
			$0.top.equalTo(accountTitleLabel.snp.bottom).offset(24)
			$0.leading.trailing.equalToSuperview()
			$0.height.equalTo(420)
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
	}
    
	private func registerTableViewCells() {
		myPageTableView.register(
			MyPageTableDefaultCell.self,
			forCellReuseIdentifier: MyPageTableDefaultCell.identifier)
		myPageTableView.register(
			NotificationSettingTableViewCell.self,
			forCellReuseIdentifier: NotificationSettingTableViewCell.identifier)
	}
    
	public func setUserInfo(nickname: String) {
		userNicknameButton.addTitleAttribute(
			title: "\(nickname)  >",
			titleColor: .black,
			fontName: .semiBold(size: 20))
		if let accountType = UserInfoManager.shared.getCurrentUserInfo()?.accountType {
			switch accountType {
			case .apple:
				accountTypeLabel.text = "APPLE"
				accountTypeImage.image = ImageLiteral.signInWithApple
			case .kakao:
				accountTypeLabel.text = "카카오"
				accountTypeImage.image = ImageLiteral.signInWithKakao
			}
		}
	}
}
