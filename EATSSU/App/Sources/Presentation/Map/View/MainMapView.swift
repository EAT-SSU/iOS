//
//  MainMapView.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/24/25.
//

import UIKit

import NMapsMap
import SnapKit

import EATSSUDesign

final class MainMapView: BaseUIView {

    // MARK: - UI Components

    let mapView = NMFNaverMapView()
    let toggleBackgroundView = UIView()
    let wholeButton = UIButton(type: .system)
    let myOnlyButton = UIButton(type: .system)

    // MARK: - UI Setup
    
    override func configureUI() {
        backgroundColor = .white

        // 네이버 지도 뷰 설정
        mapView.showZoomControls = false
        mapView.showLocationButton = true
        mapView.mapView.positionMode = .disabled
        addSubview(mapView)

        // 상단 버튼 배경 뷰 설정
        toggleBackgroundView.layer.cornerRadius = 20
        toggleBackgroundView.layer.borderWidth = 1
        toggleBackgroundView.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray300.color.cgColor
        toggleBackgroundView.backgroundColor = .white
        addSubview(toggleBackgroundView)

        let titleFont = EATSSUDesignFontFamily.Pretendard.semiBold.font(size: 14)

        // 전체 버튼
        wholeButton.setTitle("전체", for: .normal)
        wholeButton.titleLabel?.font = titleFont
        wholeButton.layer.cornerRadius = 14
        wholeButton.clipsToBounds = true
        wholeButton.backgroundColor = .clear
        wholeButton.setTitleColor(.label, for: .normal)
        if #available(iOS 15.0, *) {
            var cfg = wholeButton.configuration ?? .plain()
            cfg.title = "전체"
            cfg.baseForegroundColor = .label
            cfg.baseBackgroundColor = .clear
            cfg.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { inAttrs in
                var out = inAttrs
                out.font = titleFont
                return out
            }
            wholeButton.configuration = cfg
        } else {
            wholeButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        }

        // 내 제휴 버튼
        myOnlyButton.setTitle("내 제휴", for: .normal)
        myOnlyButton.titleLabel?.font = titleFont
        myOnlyButton.layer.cornerRadius = 14
        myOnlyButton.clipsToBounds = true
        myOnlyButton.backgroundColor = .clear
        myOnlyButton.setTitleColor(.label, for: .normal)
        if #available(iOS 15.0, *) {
            var cfg = myOnlyButton.configuration ?? .plain()
            cfg.title = "내 제휴"
            cfg.baseForegroundColor = .label
            cfg.baseBackgroundColor = .clear
            cfg.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { inAttrs in
                var out = inAttrs
                out.font = titleFont
                return out
            }
            myOnlyButton.configuration = cfg
        } else {
            myOnlyButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        }

        // 초기 선택 상태
        selectWhole(true)
        toggleBackgroundView.addSubview(myOnlyButton)
        toggleBackgroundView.addSubview(wholeButton)
    }

    // MARK: - Layout Setup
    
    override func setLayout() {
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        toggleBackgroundView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(12)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(40)
            $0.leading.greaterThanOrEqualToSuperview().offset(15)
            $0.trailing.lessThanOrEqualToSuperview().inset(15)
        }

        myOnlyButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.equalToSuperview().inset(4)
            $0.width.greaterThanOrEqualTo(60)
        }

        wholeButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.equalTo(myOnlyButton.snp.trailing)
            $0.trailing.equalToSuperview().inset(4)   
            $0.width.equalTo(60)
        }
    }

    // MARK: - Button Selection Handling
    
    func selectWhole(_ isSelected: Bool) {
        if isSelected {
            wholeButton.backgroundColor = EATSSUDesignAsset.Color.Main.primary.color
            wholeButton.setTitleColor(.white, for: .normal)

            myOnlyButton.backgroundColor = .clear
            myOnlyButton.setTitleColor(.label, for: .normal)
        } else {
            wholeButton.backgroundColor = .clear
            wholeButton.setTitleColor(.label, for: .normal)

            myOnlyButton.backgroundColor = EATSSUDesignAsset.Color.Main.primary.color
            myOnlyButton.setTitleColor(.white, for: .normal)
        }
    }
}
