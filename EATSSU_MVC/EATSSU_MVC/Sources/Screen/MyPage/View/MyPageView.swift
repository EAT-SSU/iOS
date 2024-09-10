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
    
    let myPageServiceLabelList = MyPageLocalData.myPageServiceLabelList
    let myPageRightItemListDate = MyPageRightItemData.myPageRightItemList
    private var dataModel: MyInfoResponse? {
        didSet {
            if let nickname = dataModel?.nickname {
                userNicknameButton.addTitleAttribute(
                  title: "\(nickname)  >",
                  titleColor: .black,
                  fontName: .semiBold(size: 20)
                )
            }
            
            switch dataModel?.provider {
            case "KAKAO":
                accountLabel.text = "카카오"
                accountImage.image = ImageLiteral.signInWithKakao
            case "APPLE":
                accountLabel.text = "APPLE"
                accountImage.image = ImageLiteral.signInWithApple
            default:
                return
            }
        }
    }
    
    // MARK: - UI Components
    
  // 사용자 이미지
    public var userImage = UIImageView().then {
        $0.image = ImageLiteral.profileIcon
    }
  
  // 닉네임이 들어간 닉네임 변경 버튼
    public var userNicknameButton = UIButton().then {
      $0.addTitleAttribute(
        title: "다시 시도해주세요",
        titleColor: .black,
        fontName: EATSSUFontFamily.Pretendard.regular.font(size: 16))
    }
    
  //
    public let accountTitleLabel = UILabel().then {
        $0.text = TextLiteral.linkedAccount
      $0.font = EATSSUFontFamily.Pretendard.regular.font(size: 14)
    }
    
    public var accountLabel = UILabel().then {
        $0.text = "없음"
      $0.font = EATSSUFontFamily.Pretendard.regular.font(size: 14)
        $0.font = .bold(size: 14)
    }
    
    public var accountImage = UIImageView()
    
    public lazy var totalAccountStackView = UIStackView(
      arrangedSubviews: [accountTitleLabel,accountStackView]).then {
        $0.alignment = .bottom
        $0.axis = .horizontal
        $0.spacing = 20
    }
    
    public lazy var accountStackView = UIStackView(
      arrangedSubviews: [accountLabel,accountImage]).then {
        $0.alignment = .bottom
        $0.axis = .horizontal
        $0.spacing = 5
    }
    
    public let myPageTableView = UITableView().then {
        $0.separatorStyle = .none
        $0.rowHeight = 55
    }
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        register()
    }
    
    // MARK: - Functions
    
    override func configureUI() {
        self.addSubviews(userImage,
                         userNicknameButton,
                         totalAccountStackView,
                         myPageTableView)
    }
    override func setLayout() {
        userImage.snp.makeConstraints {
            $0.top.equalToSuperview().offset(127)
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
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    func register() {
        myPageTableView.register(MyPageServiceCell.self, forCellReuseIdentifier: MyPageServiceCell.identifier)
    }
    
    func dataBind(model: MyInfoResponse) {
        dataModel = model
    }
}

