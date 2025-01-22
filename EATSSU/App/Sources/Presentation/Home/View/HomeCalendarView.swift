//
//  HomeCalendarView.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/08.
//

import UIKit

import FSCalendar
import SnapKit
import Then

protocol CalendarSeletionDelegate: AnyObject {
    func didSelectCalendar(date: Date)
}

final class HomeCalendarView: BaseUIView {
    // MARK: - Properties

    weak var delegate: CalendarSeletionDelegate?

    // MARK: - UI Components

    var calendar = FSCalendar()

    // MARK: Initializer

    override init(frame: CGRect) {
        super.init(frame: frame)

        setDelegate()
        setUpCalendar()
    }

    // MARK: - Functions

    override func configureUI() {
        addSubview(calendar)
    }

    override func setLayout() {
        calendar.snp.makeConstraints {
            $0.height.equalTo(300)
            $0.left.right.equalToSuperview()
        }
    }

    private func setDelegate() {
        calendar.dataSource = self
        calendar.delegate = self
    }
}

extension HomeCalendarView: FSCalendarDataSource, FSCalendarDelegate {
    private func setUpCalendar() {
        // Base
        calendar.scope = .week
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.scrollEnabled = true
        calendar.scrollDirection = .horizontal

        // Header Title
        calendar.headerHeight = 30
        calendar.weekdayHeight = 10

        // 달력의 맨 위의 년도, 월의 색깔
        calendar.appearance.headerTitleColor = .gray500
        calendar.appearance.headerTitleFont = .bold(size: 18)
        // 달력의 년월 글자 바꾸기
        calendar.appearance.headerDateFormat = "YYYY. MM"
        // 년월에 흐릿하게 보이는 애들 없애기
        calendar.appearance.headerMinimumDissolvedAlpha = 0

        // Day
        calendar.appearance.weekdayFont = .medium(size: 10)
        calendar.appearance.weekdayTextColor = .gray500

        // Date
        calendar.appearance.titleFont = .bold(size: 16)
        calendar.appearance.todayColor = .white
        calendar.appearance.titleTodayColor = EATSSUAsset.Color.Main.primary.color

        // Selection
        calendar.allowsSelection = true
        calendar.allowsMultipleSelection = false
        calendar.appearance.borderRadius = 20
        calendar.appearance.selectionColor = EATSSUAsset.Color.Main.primary.color

        // 오늘 날짜 Select
        calendar.select(Date())
    }

    // 날짜를 선택했을 때 할일을 지정
    func calendar(_: FSCalendar, didSelect date: Date, at _: FSCalendarMonthPosition) {
        print("HomeCalendarView 날짜 변경: \(date)")

        delegate?.didSelectCalendar(date: date)
    }
}
