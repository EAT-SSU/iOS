//
//  ChartComponentView.swift
//  EATSSU
//
//  Created by 최지우 on 2/18/25.
//

import UIKit

import EATSSUDesign
import SnapKit

final class ChartComponentView: BaseUIView {
    
    private lazy var chartBarView = UIView()
    
    private let pointLabel: UILabel = {
        let label = UILabel()
        label.text = "5점"
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 12)
        return label
    }()
    
    public var chartBarBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = EATSSUDesignAsset.Color.GrayScale.gray200.color
        view.layer.cornerRadius = 5
        return view
    }()
    
    public var chartBarforegroundView: UIView = {
        let view = UIView()
        view.backgroundColor = EATSSUDesignAsset.Color.Main.primary.color
        view.layer.cornerRadius = 5
        return view
    }()
    
    private lazy var chartComponentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [pointLabel, chartBarView])
        stackView.axis = .horizontal
        stackView.spacing = 9
        return stackView
    }()
    
    override func configureUI() {
        chartBarView.addSubviews(chartBarBackgroundView,
                                 chartBarforegroundView)
        addSubviews(chartComponentStackView)
    }
    
    override func setLayout() {
        chartBarView.snp.makeConstraints { make in
            make.width.equalTo(115.adjusted)
            make.height.equalTo(10.adjusted)
            
        }
        chartBarforegroundView.snp.makeConstraints { make in
            make.width.equalTo(80.adjusted)
            make.height.equalTo(10.adjusted)
            make.top.leading.equalToSuperview()
        }
        chartBarBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        chartComponentStackView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
        }
    }
}
