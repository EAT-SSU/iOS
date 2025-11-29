//
//  ESEntry.swift
//  EATSSU_MVC
//
//  Created by JIWOONG CHOI on 12/31/24.
//

import WidgetKit

/// `ESEntry` 구조체는 위젯 타임라인 항목을 나타내며, 특정 날짜의 식당 메뉴 정보를 포함합니다.
struct ESEntry: TimelineEntry {
    /// 이 항목의 타임라인 날짜.
    let date: Date

    /// 식당의 이름.
    let restaurantName: String

    /// 제공되는 메뉴 목록.
    ///
    /// 기본값은 `["메뉴가 없습니다."]`로 설정됩니다.
    let menus: [[String]]
    
    /// 시간대 정보.
    let timeSlot: String

    /// 오류 발생 여부를 나타내는 불리언 값.
    ///
    /// 기본값은 `false`입니다.
    let isError: Bool

    /// `ESEntry`의 초기화 함수.
    ///
    /// - Parameters:
    ///   - date: 타임라인 항목의 날짜.
    ///   - restaurantName: 식당의 이름.
    ///   - menus: 제공되는 메뉴 목록. 기본값은 `["메뉴가 없습니다."]`입니다.
    ///   - timeSlot: 해당 시간대.
    ///   - isError: 오류 여부. 기본값은 `false`입니다.
    init(date: Date, restaurantName: String, menus: [[String]] = [["메뉴가 없습니다."]], timeSlot: String, isError: Bool = false) {
        self.date = date
        self.restaurantName = restaurantName
        self.menus = menus
        self.timeSlot = timeSlot
        self.isError = isError
    }
}
