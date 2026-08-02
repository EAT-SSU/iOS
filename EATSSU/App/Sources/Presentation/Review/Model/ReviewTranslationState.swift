//
//  ReviewTranslationState.swift
//  EATSSU
//
//  Created by 황상환 on 7/18/26.
//

import Foundation

/// 리뷰 셀의 번역 UI 상태
enum ReviewTranslationState: Equatable {
    /// 번역 전 (Translate 버튼 노출)
    case idle
    /// 번역 요청 중
    case loading
    /// 번역 완료 (showingOriginal이 true면 원문 표시 중)
    case translated(text: String, showingOriginal: Bool)
    /// 번역 실패
    case failed
}
