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

final class MainMapView: UIView {

    let mapView = NMFNaverMapView()
    let toggleBackgroundView = UIView()
    let wholeButton = UIButton(type: .system)
    let myOnlyButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {
        backgroundColor = .white

        mapView.showZoomControls = false
        mapView.showLocationButton = true
        mapView.mapView.positionMode = .direction
        addSubview(mapView)

        toggleBackgroundView.layer.cornerRadius = 20
        toggleBackgroundView.layer.borderWidth = 1
        toggleBackgroundView.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray300.color.cgColor
        toggleBackgroundView.backgroundColor = .white
        addSubview(toggleBackgroundView)

        wholeButton.setTitle("전체", for: .normal)
        wholeButton.titleLabel?.font = EATSSUDesignFontFamily.Pretendard.semiBold.font(size: 14)
        wholeButton.layer.cornerRadius = 14
        wholeButton.clipsToBounds = true
        wholeButton.backgroundColor = .clear
        wholeButton.setTitleColor(.label, for: .normal)

        myOnlyButton.setTitle("내 제휴", for: .normal)
        myOnlyButton.titleLabel?.font = EATSSUDesignFontFamily.Pretendard.semiBold.font(size: 14)
        myOnlyButton.setTitleColor(.label, for: .normal)
        myOnlyButton.backgroundColor = .clear
        myOnlyButton.layer.cornerRadius = 14
        myOnlyButton.clipsToBounds = true
        myOnlyButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

        selectWhole(true)
        toggleBackgroundView.addSubview(wholeButton)
        toggleBackgroundView.addSubview(myOnlyButton)
    }

    private func setLayout() {
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

        wholeButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.equalToSuperview().inset(4)
            $0.width.equalTo(60)
        }

        myOnlyButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.equalTo(wholeButton.snp.trailing)
            $0.trailing.equalToSuperview().inset(4)
        }
    }

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
