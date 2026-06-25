//
//  HomeCalendarView.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/08.
//

import UIKit

import FSCalendar
import SnapKit

import EATSSUDesign

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

    private var calendarLocale: Locale {
        return Locale(identifier: AppLanguageManager.shared.currentLanguage.rawValue)
    }
    
    
    /// 특정 날짜로 선택하고 해당 월로 스크롤합니다.
    func setSelected(date: Date) {
        // 날짜를 선택
        calendar.select(date)
        // 달력을 해당 날짜가 포함된 페이지로 이동
        calendar.setCurrentPage(date, animated: true)
    }
}

extension HomeCalendarView: FSCalendarDataSource, FSCalendarDelegate {
    private func setUpCalendar() {
        // Base
        calendar.scope = .week
        calendar.locale = calendarLocale
        calendar.scrollEnabled = true
        calendar.scrollDirection = .horizontal

        // Header Title
        calendar.headerHeight = 30
        calendar.weekdayHeight = 10

        // 달력의 맨 위의 년도, 월의 색깔
        calendar.appearance.headerTitleColor = .gray500
        calendar.appearance.headerTitleFont = .header2
        // 달력의 년월 글자 바꾸기
        calendar.appearance.headerDateFormat = "YYYY. MM"
        // 년월에 흐릿하게 보이는 애들 없애기
        calendar.appearance.headerMinimumDissolvedAlpha = 0

        // Day
        calendar.appearance.weekdayFont = .caption3
        calendar.appearance.weekdayTextColor = .gray500

        // Date
        calendar.appearance.titleFont = .subtitle1
        calendar.appearance.todayColor = .white
        calendar.appearance.titleTodayColor = .primary

        // Selection
        calendar.allowsSelection = true
        calendar.allowsMultipleSelection = false
        calendar.appearance.borderRadius = 20
        calendar.appearance.selectionColor = .primary

        // 오늘 날짜 Select
        calendar.select(Date())
    }

    // 날짜를 선택했을 때 할일을 지정
    func calendar(_: FSCalendar, didSelect date: Date, at _: FSCalendarMonthPosition) {
        print("HomeCalendarView 날짜 변경: \(date)")

        delegate?.didSelectCalendar(date: date)
    }
}
