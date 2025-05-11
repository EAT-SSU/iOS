//
//  RestaurantMenuItemView.swift
//  EATSSU
//
//  Created by 황상환 on 4/6/25.
//

import UIKit
import SnapKit

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
    private let nameLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .body3 // 커스텀 폰트 스타일
    }

    // 가격 라벨
    private let priceLabel = UILabel().then {
        $0.font = .body3
        $0.textAlignment = .center
    }

    // 평점 라벨
    private let ratingLabel = UILabel().then {
        $0.font = .body3
        $0.textAlignment = .center
    }

    // 콘텐츠 수평 스택 뷰 (이름, 가격, 평점 수평 정렬)
    private let contentStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 24
    }

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
            $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)).priority(.high)
        }

        // 라벨별 고정 너비 설정 (우선순위 높음)
        nameLabel.snp.makeConstraints { $0.width.equalTo(210).priority(.high) }
        priceLabel.snp.makeConstraints { $0.width.equalTo(47).priority(.high) }
        ratingLabel.snp.makeConstraints { $0.width.equalTo(25).priority(.high) }
    }

    /// 모델을 기반으로 뷰에 데이터를 바인딩하는 함수
    func bind(_ model: MenuTypeInfo) {
        switch model {
        case let .change(data):
            // 여러 메뉴가 조합된 경우 이름들을 '+'로 연결
            nameLabel.text = data.briefMenus.map(\.name).joined(separator: "+")
            priceLabel.text = data.price?.formattedWithCommas ?? ""
            ratingLabel.text = data.rating != nil ? String(format: "%.1f", data.rating!) : "-"
        case let .fix(data):
            // 단일 메뉴 정보
            nameLabel.text = data.name
            priceLabel.text = data.price?.formattedWithCommas ?? ""
            ratingLabel.text = data.rating != nil ? String(format: "%.1f", data.rating!) : "-"
        }
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
        backgroundWrapper.backgroundColor = .clear

        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // 터치가 View 내부에 있을 때만 실행
        if bounds.contains(location), let indexPath = indexPath {
            onTap?(indexPath, menuIndex)
        }
    }
}
