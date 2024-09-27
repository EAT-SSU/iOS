//
//  RateView.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/03/24.
//

import UIKit

import SnapKit

final class RateView: BaseUIView {
    
    // MARK: - Properties
    
    var buttons: [UIButton] = []
    var currentStar: Int = 0
    var starNumber: Int = 5 {
        didSet { bind() } /// 초기화할 별의 개수 (button의 개수)
    }
    
    // MARK: - UI Component
    
    lazy var starStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 12
        view.backgroundColor = .white
        return view
    }()
    
    lazy var starFillImage: UIImage? = {
        return EATSSUAsset.Images.Version2.icStarYellow.image
    }()
    
    lazy var starEmptyImage: UIImage? = {
        return EATSSUAsset.Images.Version2.icStarGray.image
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Functions
    
    override func configureUI() {
        self.addSubview(starStackView)
    }
    
    override func setLayout() {
        starStackView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
    }
    
    /// 별점 버튼 초기화. tag 생성이 핵심
    func bind() {
        for i in 0..<5 {
            let button = UIButton()
            button.setImage(starEmptyImage, for: .normal)
            button.tag = i
            buttons += [button]
            starStackView.addArrangedSubview(button)
            button.addTarget(self, action: #selector(didTappedTag(sender:)), for: .touchUpInside)
        }
    }
    
    /// tag를 이용한 선택처리
    @objc
    private func didTappedTag(sender: UIButton) {
        let end = sender.tag
        for i in 0...end {
            buttons[i].setImage(starFillImage, for: .normal)
        }
        for i in end + 1..<starNumber {
            buttons[i].setImage(starEmptyImage, for: .normal)
        }
        currentStar = end + 1
    }
    
    func settingStarForFix(currentStar: Int) {
        for i in 0...currentStar - 1 {
            buttons[i].setImage(starFillImage, for: .normal)
        }
        for i in currentStar..<starNumber {
            buttons[i].setImage(starEmptyImage, for: .normal)
        }
    }
}
