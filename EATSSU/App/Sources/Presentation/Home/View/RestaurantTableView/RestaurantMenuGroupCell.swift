//
//  RestaurantMenuGroupCell.swift
//  EATSSU
//
//  Created by 황상환 on 4/6/25.
//

import UIKit

import EATSSUDesign

import SnapKit

/// 식당의 "오늘의 메뉴" + 메뉴 리스트를 하나의 셀에서 표현하는 커스텀 테이블뷰 셀
final class RestaurantMenuGroupCell: BaseTableViewCell {
    static let identifier = "RestaurantMenuGroupCell"

    // 외곽 테두리와 그림자를 가지는 래퍼 뷰
    private let wrapperView = UIView()
    
    // "오늘의 메뉴 | 가격 | 평점" 등 타이틀 라벨이 포함된 뷰
    private let titleView = RestaurantMenuTitleView()
    
    // 개별 메뉴 뷰들이 들어갈 스택뷰 (수직 방향)
    private let menuStackView = UIStackView()

    // 메뉴가 없을 때 표시할 안내 텍스트
    private let emptyLabel = UILabel().then {
        $0.text = "영업 시간이 아니에요."
        $0.font = .semiBold(size: 10)
        $0.textColor = .black
        $0.textAlignment = .center
        $0.numberOfLines = 0
        $0.isHidden = true // 기본적으로 숨겨둠
    }
    
    // 메뉴 뷰(View) 재사용을 위한 풀
    // scroll 등으로 셀이 재사용될 때 menuStackView 내부의 뷰들을 재활용하기 위함
    private var itemViewPool: [RestaurantMenuItemView] = []

    // UI 구성
    override func configureUI() {
        contentView.addSubview(wrapperView)
        wrapperView.addSubviews(titleView, emptyLabel, menuStackView)

        wrapperView.layer.cornerRadius = 12
        wrapperView.layer.borderWidth = 1
        wrapperView.layer.borderColor = UIColor.gray200.cgColor
        wrapperView.backgroundColor = .white

        menuStackView.axis = .vertical
    }

    // 오토레이아웃 설정
    override func setLayout() {
        wrapperView.snp.makeConstraints { $0.edges.equalToSuperview() }

        titleView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
        }

        emptyLabel.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.bottom.equalToSuperview().inset(16)
        }

        menuStackView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    /// 셀이 재사용되기 전에 호출됨
    /// menuStackView에 남아있는 메뉴 뷰들을 제거하고, 재사용 풀에 저장
    override func prepareForReuse() {
        super.prepareForReuse()
        for view in menuStackView.arrangedSubviews {
            view.removeFromSuperview()
            if let itemView = view as? RestaurantMenuItemView {
                itemViewPool.append(itemView) // 뷰 재사용 풀에 넣기
            }
        }
    }

    /// 재사용 가능한 뷰가 있다면 꺼내고, 없으면 새로 생성
    private func dequeueReusableItemView() -> RestaurantMenuItemView {
        if let reused = itemViewPool.popLast() {
            return reused
        } else {
            return RestaurantMenuItemView()
        }
    }

    /// 메뉴 데이터를 이용해 스택뷰를 구성
    /// - Parameter menus: 메뉴 리스트 (MenuTypeInfo 배열)
    /// - Parameter indexPath: 현재 테이블뷰 indexPath (섹션, row)
    /// - Parameter onMenuTap: 터치 시 실행할 클로저 (section, index 전달)
    func configure(with menus: [MenuTypeInfo], at indexPath: IndexPath, onMenuTap: @escaping (IndexPath, Int) -> Void) {
        // 이전 뷰들 제거 (주의: prepareForReuse와 중복 제거됨 → 안정성 보장용)
        menuStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 메뉴가 없을 경우 → 안내 텍스트 표시
        if menus.isEmpty {
            emptyLabel.isHidden = false
            menuStackView.isHidden = true
        } else {
            emptyLabel.isHidden = true
            menuStackView.isHidden = false

            // 메뉴 개수만큼 뷰 생성 or 재사용하여 추가
            for (idx, menu) in menus.enumerated() {
                let itemView = dequeueReusableItemView()
                itemView.reset() // label 초기화
                itemView.indexPath = indexPath // 어떤 셀인지 기억
                itemView.menuIndex = idx       // 어떤 메뉴인지 기억
                itemView.onTap = onMenuTap     // 탭 콜백 연결
                itemView.bind(menu)            // 데이터 바인딩
                menuStackView.addArrangedSubview(itemView)
            }
        }
    }
}
