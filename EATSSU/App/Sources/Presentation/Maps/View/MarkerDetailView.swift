//
//  MarkerDetailView.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 2/11/25.
//

import UIKit

import EATSSUDesign

import SnapKit

/// `MarkerDetailView`
///
/// 지도 마커 선택 시 상세 정보를 표시하는 뷰입니다.
///
/// - Components:
///     - `titleLabel`: 마커의 제목을 표시하는 라벨
///     - `categoryLabel`: 마커의 카테고리를 표시하는 라벨
///     - `partnershipPeriodLabel`: 제휴 기간을 표시하는 라벨
///     - `explanationLabel`: 마커의 설명을 표시하는 라벨
///     - `businessStatusLabel`: 영업 상태를 표시하는 라벨
class MarkerDetailView: BaseView {
    /// 마커의 제목을 표시하는 라벨
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 16)
        return label
    }()

    /// 마커의 카테고리를 표시하는 라벨
    var categoryLabel: UILabel = {
        let label = UILabel()
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 10)
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray600.color
        return label
    }()

    /// 마커의 제휴 기간을 표시하는 라벨
    var partnershipPeriodLabel: UILabel = {
        let label = UILabel()
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 10)
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray600.color
        return label
    }()

    /// 마커의 설명을 표시하는 라벨
    var explanatonLabel: UILabel = {
        let label = UILabel()
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 10)
        label.textColor = EATSSUDesignAsset.Color.GrayScale.gray600.color
        return label
    }()

    /// 마커의 영업 상태를 표시하는 라벨
    var businessStatusLabel: UILabel = {
        let label = UILabel()
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 10)
        return label
    }()

    /// UI를 구성하는 메서드
    override func configureUI() {
        addSubviews(
            titleLabel,
            categoryLabel,
            partnershipPeriodLabel,
            explanatonLabel,
            businessStatusLabel
        )
    }

    /// AutoLayout을 설정하는 메서드
    override func setLayout() {
        titleLabel.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(24)
        }

        categoryLabel.snp.makeConstraints { make in
            make.leading.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
        }

        partnershipPeriodLabel.snp.makeConstraints { make in
            make.leading.equalTo(categoryLabel)
            make.top.equalTo(categoryLabel.snp.bottom).offset(16)
        }

        explanatonLabel.snp.makeConstraints { make in
            make.leading.equalTo(partnershipPeriodLabel)
            make.top.equalTo(partnershipPeriodLabel.snp.bottom).offset(4)
        }

        businessStatusLabel.snp.makeConstraints { make in
            make.leading.equalTo(explanatonLabel)
            make.top.equalTo(explanatonLabel.snp.bottom).offset(16)
        }
    }
}
