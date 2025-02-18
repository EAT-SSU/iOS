//
//  DepartmentInfoModalView.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 2/18/25.
//

import UIKit

import EATSSUDesign

import SnapKit

/// 학과 정보 모달의 UI를 구성하는 커스텀 뷰
public class DepartmentInfoModalView: UIView {
    /// 상단 제목 레이블
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "학과를 입력하고\n나만의 제휴를 확인해보세요!"
        label.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 18)
        label.numberOfLines = 2
        return label
    }()

    /// 중간 이미지 뷰 (이미지 리소스는 추후 설정)
    public let contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = EATSSUDesignAsset.Images.mapModalLogo.image
        return imageView
    }()

    /// 하단 버튼
    public let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("학과 입력하기", for: .normal)
        button.titleLabel?.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 18)
        button.backgroundColor = EATSSUDesignAsset.Color.Main.primary.color
        button.tintColor = .white
        button.layer.cornerRadius = 12
        return button
    }()

    override public init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:)는 구현되지 않음")
    }

    /// UI 컴포넌트 추가 및 SnapKit을 이용한 오토레이아웃 설정
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(contentImageView)
        addSubview(actionButton)

        // 상단 제목 레이블 제약조건
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(40)
            make.leading.equalToSuperview().inset(20)
        }

        // 중간 이미지 뷰 제약조건
        contentImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }

        // 하단 버튼 제약조건
        actionButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(52)
            make.bottom.equalToSuperview().inset(40)
        }
    }
}
