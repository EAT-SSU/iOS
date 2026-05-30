//
//  ReviewAnalyticsManager.swift
//  EATSSU
//
//  Created by 황상환 on 9/6/25.
//

/// 리뷰 화면에서 발생하는 주요 이벤트를 Firebase Analytics에 로깅하는 담당자
final class ReviewAnalyticsManager {

    // MARK: - Singleton

    static let shared = ReviewAnalyticsManager()
    private init() {}

    // MARK: - Event & Parameter Keys

    private enum Event {
        static let writeReview = "write_review_v2"
        static let completeReview = "complete_review_v2"
    }

    private enum Parameter {
        static let restaurants = "restaurants"
        static let photoAttached = "photo_attached"
        static let rating = "rating"
        static let likes = "likes"
    }

    // 식당 이름(한글) -> 영문 소문자 파라미터로 변환
    private let restaurantNameMap: [String: String] = [
        TextLiteral.Restaurant.studentRestaurant: "haksik",
        TextLiteral.Restaurant.dodamRestaurant: "dodam",
        TextLiteral.Restaurant.dormitoryRestaurant: "dormitory",
        TextLiteral.Restaurant.facultyRestaurant: "faculty",
        TextLiteral.Restaurant.snackCorner: "snack_corner"
    ]

    // MARK: - Logging Methods

    /**
     #1 '리뷰 작성하기' 버튼을 클릭했을 때 호출
     - Parameter restaurantName: 리뷰를 작성할 메뉴가 속한 식당 이름 (예: "학생 식당")
     */
    func logWriteReviewV2(restaurantName: String?) {
        AnalyticsService.logEvent(Event.writeReview, parameters: makeRestaurantsParameter(restaurantName))
    }

    /**
     #2 리뷰 작성을 마치고 '완료하기' 버튼을 클릭했을 때 호출
     - Parameter restaurantName: 리뷰를 작성한 메뉴가 속한 식당 이름 (예: "학생 식당")
     - Parameter photoAttached: 사진 첨부 여부 (0: 없음, 1: 있음)
     - Parameter rating: 사용자가 부여한 메인 별점 (1~5)
     - Parameter likes: 사용자가 한 번에 리뷰를 작성하는 메뉴의 총 개수
     */
    func logCompleteReviewV2(restaurantName: String?, photoAttached: Int, rating: Int, likes: Int) {
        var parameters: [String: Any] = makeRestaurantsParameter(restaurantName) ?? [:]
        parameters[Parameter.photoAttached] = photoAttached
        parameters[Parameter.rating] = rating
        parameters[Parameter.likes] = likes
        AnalyticsService.logEvent(Event.completeReview, parameters: parameters)
    }

    // MARK: - Helpers

    private func makeRestaurantsParameter(_ restaurantName: String?) -> [String: Any]? {
        guard let restaurantName,
              let value = restaurantNameMap[restaurantName] else {
            return nil
        }
        return [Parameter.restaurants: value]
    }
}
