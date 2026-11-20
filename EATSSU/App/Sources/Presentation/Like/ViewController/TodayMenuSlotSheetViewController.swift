//
//  TodayMenuSlotSheetViewController.swift
//  EATSSU
//
//  Created by 황상환 on 11/8/26.
//

import UIKit

import SnapKit

import EATSSUDesign

/// "오늘 식단에서 찜하기"의 식당·시간대를 바꾸는 바텀시트
///
/// 디자인(390 기준): 높이 360, 손잡이 30×2(위 14), 제목 Bold 16(위 33), 구역 제목 SemiBold 16
/// 칩 높이 36 · 간격 5 · 폭 균등, 적용하기 52(좌우 24, 모서리 12, 안전 영역 바닥)
/// 식당 버튼은 디자인의 1×4 대신 2×2로 두고(다국어 긴 이름 대응, QA 요청) 늘어난 줄만큼 높이를 더한다 (`preferredHeight`)
/// 식당마다 운영하지 않는 시간대는 비활성(gray100 배경, gray300 글자). 식당과 시간대를 모두 고르고
/// 현재 값과 다를 때만 적용하기가 켜진다
final class TodayMenuSlotSheetViewController: UIViewController {

    // MARK: - Constants

    /// 디자인 높이 360(식당 버튼 한 줄 기준)에, 2열 배치로 늘어난 줄 수만큼 (버튼 36 + 간격 5)를 더한 값
    static var preferredHeight: CGFloat {
        Layout.designHeight + CGFloat(max(restaurantRowCount - 1, 0)) * (Layout.chipHeight + Layout.chipSpacing)
    }

    /// 식당 버튼 줄 수 (4곳 ÷ 2열 = 2줄)
    private static var restaurantRowCount: Int {
        (TodayMenuSlot.selectableRestaurants.count + Layout.restaurantColumns - 1) / Layout.restaurantColumns
    }

    private enum Layout {
        static let designHeight: CGFloat = 360
        static let horizontalInset: CGFloat = 24
        static let grabberTop: CGFloat = 14
        static let grabberSize = CGSize(width: 30, height: 2)
        static let titleTop: CGFloat = 33
        static let restaurantLabelTop: CGFloat = 77
        static let chipsTop: CGFloat = 15
        static let chipHeight: CGFloat = 36
        static let chipSpacing: CGFloat = 5
        /// 식당 버튼은 다국어에서 이름이 길어져 2열 2행으로 둔다
        static let restaurantColumns = 2
        static let mealTimeLabelTop: CGFloat = 15
        static let applyHeight: CGFloat = 52
        static let applyCornerRadius: CGFloat = 12
        static let disabledAlpha: CGFloat = 0.5
    }

    // MARK: - Properties

    var onApply: ((TodayMenuSlot) -> Void)?

    private let currentSlot: TodayMenuSlot
    private var selectedRestaurant: Restaurant?
    private var selectedMealTime: MealTimePart?

    // MARK: - UI Components

    private let grabberView = UIView()
    private let titleLabel = UILabel()
    private let restaurantLabel = UILabel()
    private let restaurantStackView = UIStackView()
    private let mealTimeLabel = UILabel()
    private let mealTimeStackView = UIStackView()
    private let applyButton = UIButton(type: .custom)

    private var restaurantChips: [UIButton] = []
    private var mealTimeChips: [UIButton] = []

    // MARK: - Init

    init(currentSlot: TodayMenuSlot) {
        self.currentSlot = currentSlot
        self.selectedRestaurant = currentSlot.restaurant
        self.selectedMealTime = currentSlot.mealTime
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            if #available(iOS 16.0, *) {
                // 디자인 높이 360은 홈 인디케이터 영역을 포함한 값이고, 커스텀 detent는 안전 영역을 뺀 높이라서 보정한다
                sheet.detents = [.custom { _ in
                    let bottomInset = UIApplication.shared.connectedScenes
                        .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                        .first?.safeAreaInsets.bottom ?? 0
                    return Self.preferredHeight - bottomInset
                }]
            } else {
                // iOS 15는 높이를 지정할 수 없다. medium(화면 절반)은 작은 기기에서 내용(401)보다 낮아 적용 버튼이 겹치므로 large를 쓴다
                sheet.detents = [.large()]
            }
            sheet.prefersGrabberVisible = false
        }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setLayout()
        applySelection()
    }

    // MARK: - View Setup

    private func configureUI() {
        view.backgroundColor = .white

        grabberView.backgroundColor = .gray400
        grabberView.layer.cornerRadius = Layout.grabberSize.height / 2

        titleLabel.text = TextLiteral.Like.slotSheetTitle
        titleLabel.font = .subtitle1
        titleLabel.textColor = .gray700
        titleLabel.textAlignment = .center

        restaurantLabel.text = TextLiteral.Like.restaurantSection
        restaurantLabel.font = .subtitle2
        restaurantLabel.textColor = .gray700

        mealTimeLabel.text = TextLiteral.Like.mealTimeSection
        mealTimeLabel.font = .subtitle2
        mealTimeLabel.textColor = .gray700

        restaurantChips = TodayMenuSlot.selectableRestaurants.enumerated().map { index, restaurant in
            let chip = makeChip(title: restaurant.shortTitle, tag: index)
            chip.addTarget(self, action: #selector(didTapRestaurant(_:)), for: .touchUpInside)
            return chip
        }
        mealTimeChips = MealTimePart.allCases.enumerated().map { index, mealTime in
            let chip = makeChip(title: mealTime.title, tag: index)
            chip.addTarget(self, action: #selector(didTapMealTime(_:)), for: .touchUpInside)
            return chip
        }

        // 식당 버튼: 세로 스택 안에 2개씩 묶은 가로 줄을 넣어 2×2로 배치한다
        restaurantStackView.axis = .vertical
        restaurantStackView.spacing = Layout.chipSpacing
        restaurantStackView.distribution = .fillEqually
        stride(from: 0, to: restaurantChips.count, by: Layout.restaurantColumns).forEach { start in
            let end = min(start + Layout.restaurantColumns, restaurantChips.count)
            restaurantStackView.addArrangedSubview(Self.makeChipRow(Array(restaurantChips[start..<end])))
        }
        // 시간대 버튼: 가로 한 줄
        Self.configureChipRow(mealTimeStackView)
        mealTimeChips.forEach(mealTimeStackView.addArrangedSubview)

        applyButton.setTitle(TextLiteral.Like.apply, for: .normal)
        applyButton.titleLabel?.font = .subtitle1
        applyButton.setTitleColor(.white, for: .normal)
        applyButton.backgroundColor = .primary
        applyButton.layer.cornerRadius = Layout.applyCornerRadius
        applyButton.addTarget(self, action: #selector(didTapApply), for: .touchUpInside)

        view.addSubviews(grabberView, titleLabel, restaurantLabel, restaurantStackView, mealTimeLabel, mealTimeStackView, applyButton)
    }

    private func setLayout() {
        grabberView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.grabberTop)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(Layout.grabberSize)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.titleTop)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }
        restaurantLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.restaurantLabelTop)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }
        restaurantStackView.snp.makeConstraints {
            $0.top.equalTo(restaurantLabel.snp.bottom).offset(Layout.chipsTop)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            let rows = CGFloat(Self.restaurantRowCount)
            $0.height.equalTo(Layout.chipHeight * rows + Layout.chipSpacing * max(rows - 1, 0))
        }
        mealTimeLabel.snp.makeConstraints {
            $0.top.equalTo(restaurantStackView.snp.bottom).offset(Layout.mealTimeLabelTop)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
        }
        mealTimeStackView.snp.makeConstraints {
            $0.top.equalTo(mealTimeLabel.snp.bottom).offset(Layout.chipsTop)
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.height.equalTo(Layout.chipHeight)
        }
        applyButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.height.equalTo(Layout.applyHeight)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    private static func makeChipRow(_ chips: [UIButton]) -> UIStackView {
        let row = UIStackView(arrangedSubviews: chips)
        configureChipRow(row)
        return row
    }

    private static func configureChipRow(_ row: UIStackView) {
        row.axis = .horizontal
        row.spacing = Layout.chipSpacing
        row.distribution = .fillEqually
    }

    private func makeChip(title: String, tag: Int) -> UIButton {
        let chip = UIButton(type: .custom)
        chip.setTitle(title, for: .normal)
        chip.titleLabel?.font = .body2
        chip.titleLabel?.adjustsFontSizeToFitWidth = true
        chip.titleLabel?.minimumScaleFactor = 0.7
        chip.layer.cornerRadius = Layout.chipHeight / 2
        chip.layer.borderWidth = 1
        chip.tag = tag
        return chip
    }

    // MARK: - Selection

    @objc private func didTapRestaurant(_ sender: UIButton) {
        let restaurant = TodayMenuSlot.selectableRestaurants[sender.tag]
        selectedRestaurant = restaurant
        // 새 식당이 운영하지 않는 시간대가 골라져 있으면 시간대를 다시 고르게 한다
        if let mealTime = selectedMealTime, !TodayMenuSlot.isAvailable(restaurant: restaurant, mealTime: mealTime) {
            selectedMealTime = nil
        }
        applySelection()
    }

    @objc private func didTapMealTime(_ sender: UIButton) {
        let mealTime = MealTimePart.allCases[sender.tag]
        if let restaurant = selectedRestaurant, !TodayMenuSlot.isAvailable(restaurant: restaurant, mealTime: mealTime) {
            return
        }
        selectedMealTime = mealTime
        applySelection()
    }

    @objc private func didTapApply() {
        guard let restaurant = selectedRestaurant, let mealTime = selectedMealTime else { return }
        let slot = TodayMenuSlot(restaurant: restaurant, mealTime: mealTime)
        dismiss(animated: true) { [onApply] in
            onApply?(slot)
        }
    }

    private func applySelection() {
        for (chip, restaurant) in zip(restaurantChips, TodayMenuSlot.selectableRestaurants) {
            style(chip, state: restaurant == selectedRestaurant ? .selected : .normal)
        }
        for (chip, mealTime) in zip(mealTimeChips, MealTimePart.allCases) {
            let isAvailable = selectedRestaurant.map { TodayMenuSlot.isAvailable(restaurant: $0, mealTime: mealTime) } ?? true
            let state: ChipState = !isAvailable ? .unavailable : (mealTime == selectedMealTime ? .selected : .normal)
            style(chip, state: state)
        }
        let selected = zip(selectedRestaurant, selectedMealTime).map { TodayMenuSlot(restaurant: $0, mealTime: $1) }
        let canApply = selected != nil && selected != currentSlot
        applyButton.isEnabled = canApply
        applyButton.alpha = canApply ? 1 : Layout.disabledAlpha
    }

    private enum ChipState {
        case normal, selected, unavailable
    }

    private func style(_ chip: UIButton, state: ChipState) {
        switch state {
        case .normal:
            chip.backgroundColor = .white
            chip.layer.borderColor = UIColor.gray300.cgColor
            chip.setTitleColor(.gray500, for: .normal)
            chip.isEnabled = true
        case .selected:
            chip.backgroundColor = .primary
            chip.layer.borderColor = UIColor.primary.cgColor
            chip.setTitleColor(.white, for: .normal)
            chip.isEnabled = true
        case .unavailable:
            chip.backgroundColor = .gray100
            chip.layer.borderColor = UIColor.gray100.cgColor
            chip.setTitleColor(.gray300, for: .disabled)
            chip.isEnabled = false
        }
    }
}

private func zip<A, B>(_ a: A?, _ b: B?) -> (A, B)? {
    guard let a, let b else { return nil }
    return (a, b)
}
