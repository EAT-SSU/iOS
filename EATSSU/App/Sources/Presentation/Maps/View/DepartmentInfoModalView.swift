//
//  DepartmentInfoModalView.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 2/18/25.
//


import UIKit

/// 학과 정보 모달의 UI를 구성하는 커스텀 뷰
public class DepartmentInfoModalView: UIView {
    
    /// 메시지 레이블 (상단)
    public let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "학과 정보가 입력되지 않았습니다."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    /// 이동 버튼 (하단)
    public let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("학과 정보 입력하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        button.backgroundColor = UIColor.systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been 구현되지 않음")
    }
    
    /// UI 컴포넌트 추가 및 오토레이아웃 설정
    private func setupUI() {
        addSubview(messageLabel)
        addSubview(actionButton)
        
        NSLayoutConstraint.activate([
            // 메시지 레이블: 상단 20pt, 좌우 20pt 여백
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // 버튼: 메시지 레이블 아래 20pt, 좌우 40pt 여백, 높이 44pt
            actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
            actionButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40),
            actionButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}