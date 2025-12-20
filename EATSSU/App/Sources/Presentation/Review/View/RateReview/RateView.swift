//
//  RateView.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/03/24.
//

import UIKit
import SnapKit

import EATSSUDesign

final class RateView: BaseUIView { 
    
    // MARK: - Properties
    
    /// 별 버튼 배열
    var buttons: [UIButton] = []
    
    /// 현재 선택된 별점 (1~5)
    var currentStar: Int = 0
    
    /// 별의 개수 (기본값: 5)
    private var starNumber: Int = 5 // 내부 프로퍼티로 변경
    
    /// 채워진 별 이미지
    private lazy var starFillImage: UIImage? = EATSSUDesignAsset.Images.icStarYellow.image
    
    /// 빈 별 이미지
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
    
    /// UI 컴포넌트 설정
    internal override func configureUI() {
        addSubview(starStackView)
    }
    
    /// 레이아웃 제약조건 설정
    internal override func setLayout() {
        starStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Private Methods
    
    /// 별 버튼들 생성 및 설정
    private func setupStars() {
        // 기존 버튼 제거
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        
        // 5개의 별 버튼 생성 및 스택뷰에 추가
        for i in 0..<starNumber {
            let button = UIButton()
            button.setImage(starEmptyImage, for: .normal)
            button.tag = i // 0부터 시작하는 인덱스
            button.addTarget(self, action: #selector(didTappedStar(sender:)), for: .touchUpInside)
            
            // SetRateViewController에서 설정된 크기 제약을 위해 여기에 추가 (Controller에서 처리하는 것이 좋으나, View에서 크기 관련 제약은 자주 발생함)
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
        
        // 현재 별점 업데이트 (인덱스 + 1)
        currentStar = selectedIndex + 1
        
        // UI 업데이트
        updateStars()
    }
    
    /// 현재 currentStar 값에 따라 별 UI를 업데이트
    private func updateStars() {
        // 선택된 별까지 채우기
        for i in 0..<currentStar {
            buttons[i].setImage(starFillImage, for: .normal)
        }
        
        // 나머지 별 비우기
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
