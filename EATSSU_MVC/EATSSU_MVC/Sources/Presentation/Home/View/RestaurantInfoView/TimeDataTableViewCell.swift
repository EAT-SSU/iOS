//
//  TimeDataTableViewCell.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/07/23.
//

import UIKit

final class TimeDataTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let identifier = "TimeDataCell"
    
    // MARK: - UI Components
    
    private var timepartLabel = UILabel().then {
        $0.font = .medium(size: 16)
        $0.textColor = .primary
        $0.textAlignment = .left
    }
    private var timeLabel = UILabel().then {
        $0.font = .medium(size: 16)
        $0.numberOfLines = 0
        $0.textAlignment = .right
    }
    
    // MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    
    func configureUI() {
        self.addSubviews(timepartLabel,
                            timeLabel)
    }
    
    func setLayout() {
        timepartLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalTo(timeLabel.snp.leading)
            $0.bottom.equalToSuperview().inset(8)
            $0.width.equalTo(40)
        }
        timeLabel.snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().inset(8) 
        }
        timeLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        timepartLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    
    func bind(timeData: TimeData) {
        self.timepartLabel.text = timeData.timepart
        let checkedLineTime = timeData.time
        self.timeLabel.text = checkedLineTime.replacingOccurrences(of: ",", with: "\n")
    }
}
