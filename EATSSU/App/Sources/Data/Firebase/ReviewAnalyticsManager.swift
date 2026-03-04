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
        static let writeReview = "write_review_v1"
        static let completeReview = "complete_review_v1"
    }

    private enum Parameter {
        static let photoAttached = "photo_attached"
        static let rating = "rating"
        static let selection = "selection"
    }

    // MARK: - Logging Methods

    /**
     #1 '리뷰 작성하기' 버튼을 클릭했을 때 호출
     */
    func logWriteReviewV1() {
        AnalyticsService.logEvent(Event.writeReview)
    }

    /**
     #2 리뷰 작성을 마치고 '완료하기' 버튼을 클릭했을 때 호출
     - Parameter photoAttached: 사진 첨부 여부 (0: 없음, 1: 있음)
     - Parameter rating: 사용자가 부여한 메인 별점 (1~5)
     - Parameter selection: 사용자가 한 번에 리뷰를 작성하는 메뉴의 총 개수
     */
    func logCompleteReviewV1(photoAttached: Int, rating: Int, selection: Int) {
        AnalyticsService.logEvent(Event.completeReview, parameters: [
            Parameter.photoAttached: photoAttached,
            Parameter.rating: rating,
            Parameter.selection: selection
        ])
    }
}
