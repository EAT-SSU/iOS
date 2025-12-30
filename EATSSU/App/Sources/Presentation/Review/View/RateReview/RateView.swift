//
//  RateView.swift
//  EatSSU-iOS
//
//  Created by 한금준 on 2025/09/28.
//

import UIKit
import SnapKit

import EATSSUDesign

final class RateView: BaseUIView { 
    
    // MARK: - Properties

    var buttons: [UIButton] = []
    var currentStar: Int = 0
    private var starNumber: Int = 5 // 내부 프로퍼티로 변경

    private lazy var starFillImage: UIImage? = EATSSUDesignAsset.Images.icStarYellow.image
    private lazy var starEmptyImage: UIImage? = EATSSUDesignAsset.Images.icStarGray.image
    
    // MARK: - UI Components
    
    /// 별들을 가로로 배치하는 스택뷰
    lazy var starStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 12
        view.backgroundColor = .white
        return view
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStars()
        configureUI()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Configuration

    internal override func configureUI() {
        addSubview(starStackView)
    }

    internal override func setLayout() {
        starStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Private Methods

    private func setupStars() {
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()

        for i in 0..<starNumber {
            let button = UIButton()
            button.setImage(starEmptyImage, for: .normal)
            button.tag = i
            button.addTarget(self, action: #selector(didTappedStar(sender:)), for: .touchUpInside)
            button.snp.makeConstraints { make in
                make.width.equalTo(29.3)
            }
            
            buttons.append(button)
            starStackView.addArrangedSubview(button)
        }
    }
    
    // MARK: - Actions
    
    /// 별 버튼 탭 처리
    /// - Parameter sender: 탭된 버튼
    @objc
    private func didTappedStar(sender: UIButton) {
        let selectedIndex = sender.tag
        currentStar = selectedIndex + 1

        updateStars()
    }
    
    /// 현재 currentStar 값에 따라 별 UI를 업데이트
    private func updateStars() {
        for i in 0..<currentStar {
            buttons[i].setImage(starFillImage, for: .normal)
        }

        for i in currentStar..<starNumber {
            buttons[i].setImage(starEmptyImage, for: .normal)
        }
    }
    
    // MARK: - Public Methods
    
    /// 리뷰 수정 시 기존 별점 설정 및 UI 업데이트
    /// - Parameter currentStar: 설정할 별점 (1~5)
    func settingStarForFix(currentStar: Int) {
        self.currentStar = currentStar
        updateStars()
    }
}
