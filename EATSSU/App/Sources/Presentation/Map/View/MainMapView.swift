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

enum MapMode {
    case festival
    case myOnly
    case all
}

final class MainMapView: BaseUIView {

    // MARK: - UI Components

    let mapView = NMFNaverMapView()
    let toggleBackgroundView = UIView()
    let festivalButton = UIButton(type: .system)
    let myOnlyButton = UIButton(type: .system)
    let wholeButton = UIButton(type: .system)

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
        toggleBackgroundView.layer.borderColor = UIColor.gray300.cgColor
        toggleBackgroundView.backgroundColor = .white
        addSubview(toggleBackgroundView)

        let titleFont = UIFont.button2

        configureToggleButton(festivalButton, title: TextLiteral.Map.festival, font: titleFont)
        configureToggleButton(myOnlyButton, title: TextLiteral.Map.myPartner, font: titleFont)
        configureToggleButton(wholeButton, title: TextLiteral.Map.all, font: titleFont)

        toggleBackgroundView.addSubview(festivalButton)
        toggleBackgroundView.addSubview(myOnlyButton)
        toggleBackgroundView.addSubview(wholeButton)

        // 초기 선택 상태: 축제
        select(.festival)
    }

    private func configureToggleButton(_ button: UIButton, title: String, font: UIFont) {
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = font
        button.titleLabel?.numberOfLines = 1
        button.titleLabel?.lineBreakMode = .byClipping
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.layer.cornerRadius = 14
        button.clipsToBounds = true
        button.backgroundColor = .clear
        button.setTitleColor(.label, for: .normal)
        if #available(iOS 15.0, *) {
            var cfg = button.configuration ?? .plain()
            cfg.title = title
            cfg.baseForegroundColor = .label
            cfg.baseBackgroundColor = .clear
            cfg.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
            cfg.titleLineBreakMode = .byClipping
            cfg.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { inAttrs in
                var out = inAttrs
                out.font = font
                return out
            }
            button.configuration = cfg
        } else {
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        }
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

        festivalButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.equalToSuperview().inset(4)
            $0.width.greaterThanOrEqualTo(60)
        }

        myOnlyButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.equalTo(festivalButton.snp.trailing)
            $0.width.greaterThanOrEqualTo(60)
        }

        wholeButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.equalTo(myOnlyButton.snp.trailing)
            $0.trailing.equalToSuperview().inset(4)
            $0.width.greaterThanOrEqualTo(60)
        }
    }

    // MARK: - Button Selection Handling

    func select(_ mode: MapMode) {
        let highlightColor: UIColor = (mode == .festival) ? .festivalPrimary : .primary
        applySelection(festivalButton, isSelected: mode == .festival, highlightColor: highlightColor)
        applySelection(myOnlyButton, isSelected: mode == .myOnly, highlightColor: highlightColor)
        applySelection(wholeButton, isSelected: mode == .all, highlightColor: highlightColor)
    }

    /// 축제 탭 노출 여부 토글. 숨길 때는 width를 0으로 만들어 레이아웃에서 사라지게 함
    func setFestivalVisible(_ visible: Bool) {
        festivalButton.isHidden = !visible
        festivalButton.snp.remakeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.equalToSuperview().inset(4)
            if visible {
                $0.width.greaterThanOrEqualTo(60)
            } else {
                $0.width.equalTo(0)
            }
        }
    }

    private func applySelection(_ button: UIButton, isSelected: Bool, highlightColor: UIColor) {
        if isSelected {
            button.backgroundColor = highlightColor
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = .clear
            button.setTitleColor(.label, for: .normal)
        }
    }
}
