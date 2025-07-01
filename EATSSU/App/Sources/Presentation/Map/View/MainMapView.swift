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
    let heartButton = UIButton(type: .system)

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
        addSubview(mapView)

        toggleBackgroundView.layer.cornerRadius = 20
        toggleBackgroundView.layer.borderWidth = 1
        toggleBackgroundView.layer.borderColor = EATSSUDesignAsset.Color.GrayScale.gray300.color.cgColor
        toggleBackgroundView.backgroundColor = .white
        addSubview(toggleBackgroundView)

        [wholeButton, myOnlyButton].forEach {
            $0.titleLabel?.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
            $0.layer.cornerRadius = 14
            $0.clipsToBounds = true
            $0.backgroundColor = .clear
            $0.setTitleColor(.label, for: .normal)
        }

        wholeButton.setTitle("전체", for: .normal)
        myOnlyButton.setTitle("내 제휴", for: .normal)
        selectWhole(true)
        toggleBackgroundView.addSubview(wholeButton)
        toggleBackgroundView.addSubview(myOnlyButton)

        let heartImage = UIImage(systemName: "heart")?
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 13, weight: .regular))
        heartButton.setImage(heartImage, for: .normal)
        heartButton.tintColor = EATSSUDesignAsset.Color.Red.error.color
        heartButton.backgroundColor = .white
        heartButton.layer.cornerRadius = 20
        heartButton.layer.shadowColor = UIColor.black.cgColor
        heartButton.layer.shadowOpacity = 0.1
        heartButton.layer.shadowRadius = 4
        heartButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        addSubview(heartButton)
    }

    private func setLayout() {
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        toggleBackgroundView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(180)
            $0.height.equalTo(40)
        }

        wholeButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.leading.equalToSuperview().inset(4)
            $0.width.equalTo(80)
        }

        myOnlyButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.trailing.equalToSuperview().inset(4)
            $0.width.equalTo(80)
        }

        heartButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.top.equalTo(safeAreaLayoutGuide).offset(12)
            $0.size.equalTo(40)
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
