//
//  RestaurantMenuGroupCell.swift
//  EATSSU
//
//  Created by 황상환 on 4/6/25.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 식당의 "오늘의 메뉴" + 메뉴 리스트를 하나의 셀에서 표현하는 커스텀 테이블뷰 셀
final class RestaurantMenuGroupCell: BaseTableViewCell {
    static let identifier = "RestaurantMenuGroupCell"

    private let wrapperView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.gray200.cgColor
        view.backgroundColor = .white
        return view
    }()

    private let titleView = RestaurantMenuTitleView()

    private let menuStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        return stack
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "영업 시간이 아니에요."
        label.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 10)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // 메뉴 뷰(View) 재사용을 위한 풀
    // scroll 등으로 셀이 재사용될 때 menuStackView 내부의 뷰들을 재활용하기 위함
    private var itemViewPool: [RestaurantMenuItemView] = []

    // UI 구성
    override func configureUI() {
        self.selectionStyle = .none
        self.selectedBackgroundView = UIView()
        contentView.addSubview(wrapperView)
        wrapperView.addSubviews(titleView, emptyLabel, menuStackView)

        menuStackView.axis = .vertical
    }

    // 오토레이아웃 설정
    override func setLayout() {
        wrapperView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview().priority(UILayoutPriority.defaultHigh) 
        }

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
                itemViewPool.append(itemView)
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
                itemView.removeFromSuperview()
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
