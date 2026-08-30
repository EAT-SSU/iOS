//
//  RestaurantMenuItemView.swift
//  EATSSU
//
//  Created by 황상환 on 4/6/25.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 식당 메뉴 아이템 하나를 나타내는 커스텀 뷰
/// 구성: 메뉴명(name), 가격(price), 평점(rating)
final class RestaurantMenuItemView: BaseUIView {

    // 이 뷰가 속한 TableView의 위치를 저장 (터치 시 indexPath 전달용)
    var indexPath: IndexPath?

    // 터치 시 실행할 클로저
    var onTap: ((IndexPath, Int) -> Void)?
    var menuIndex: Int = 0

    // 배경 래퍼 뷰: 터치 배경 효과용
    private let backgroundWrapper = UIView()

    // 메뉴명 라벨
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    // 가격 라벨
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    // 평점 라벨
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        return label
    }()

    // 콘텐츠 수평 스택 뷰 (이름, 가격, 평점 수평 정렬)
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .top
        stackView.spacing = 24
        stackView.distribution = .fill
        return stackView
    }()

    // UI 구성 요소를 계층 구조에 추가
    override func configureUI() {
        addSubview(backgroundWrapper)
        backgroundWrapper.addSubview(contentStackView)

        // 스택 뷰에 라벨들 추가
        contentStackView.addArrangedSubviews([nameLabel, priceLabel, ratingLabel])
    }

    // SnapKit을 이용한 오토레이아웃 설정
    override func setLayout() {
        backgroundWrapper.snp.makeConstraints { $0.edges.equalToSuperview() }

        contentStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12))
        }

        priceLabel.snp.makeConstraints { $0.width.equalTo(47) }
        ratingLabel.snp.makeConstraints { $0.width.equalTo(25) }
    }

    /// 모델을 기반으로 뷰에 데이터를 바인딩하는 함수
    func bind(_ model: MenuTypeInfo) {
        switch model {
        case let .change(data):
            // 영어 모드에서는 번역된 대표메뉴만 노출 (규칙은 ChangeMenuTableResponse.displayMenus 참고)
            nameLabel.text = data.displayMenus.map(\.name).joined(separator: ", ")
            priceLabel.text = data.price?.formattedWithCommas ?? ""
            ratingLabel.text = data.rating != nil ? String(format: "%.1f", data.rating!) : "-"
        case let .fix(data):
            nameLabel.text = data.name
            priceLabel.text = data.price?.formattedWithCommas ?? ""
            ratingLabel.text = data.rating != nil ? String(format: "%.1f", data.rating!) : "-"
        }
    }

    // 리셋 함수
    func reset() {
        nameLabel.text = nil
        priceLabel.text = nil
        ratingLabel.text = nil

        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .left
        priceLabel.textAlignment = .center
        ratingLabel.textAlignment = .center
        backgroundWrapper.backgroundColor = .clear
    }

    // 터치 시작: 배경 강조 효과
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        backgroundWrapper.backgroundColor = UIColor.gray300
    }

    // 터치 취소: 배경 색상 복원
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        backgroundWrapper.backgroundColor = .clear
    }

    // 터치 종료 시 실행: 영역 안에 있으면 onTap 클로저 실행
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        if bounds.contains(location), let indexPath = indexPath {
            onTap?(indexPath, menuIndex)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.backgroundWrapper.backgroundColor = .clear
        }
    }
}
