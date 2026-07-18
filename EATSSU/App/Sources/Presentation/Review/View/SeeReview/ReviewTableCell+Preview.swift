//
//  ReviewTableCell+Preview.swift
//  EATSSU
//
//  Created by 황상환 on 7/18/26.
//

#if DEBUG
import SwiftUI
import UIKit

// MARK: - Mock Data

private extension ReviewListItem {
    /// 번역 UI 프리뷰용 mock 리뷰 (ReviewListItem은 커스텀 Decodable이라 JSON으로 생성)
    static let mock: ReviewListItem = {
        let json = Data("""
        {
          "reviewId": 1,
          "menu": { "id": 1, "name": "김치찌개", "isLike": true },
          "writerId": 1,
          "isWriter": false,
          "writerNickname": "Jane",
          "rating": 5,
          "writtenAt": "2026-07-18",
          "content": "김치찌개 맛있었고 양도 괜찮았어요.",
          "imageUrls": []
        }
        """.utf8)
        // swiftlint:disable:next force_try
        return try! JSONDecoder().decode(ReviewListItem.self, from: json)
    }()
}

// MARK: - UIKit Cell Wrapper

/// ReviewTableCell을 SwiftUI 캔버스에서 렌더링하기 위한 래퍼
private struct ReviewTableCellPreview: UIViewRepresentable {
    let state: ReviewTranslationState

    /// contentView만 반환하면 셀이 해제되어 태그 컬렉션의 weak dataSource가 끊기므로 셀을 보유
    final class Coordinator {
        let cell = ReviewTableCell(style: .default, reuseIdentifier: nil)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> UIView {
        let cell = context.coordinator.cell
        cell.dataBind(response: .mock)
        cell.configureTranslation(state: state, isAvailable: true)
        return cell.contentView
    }

    func updateUIView(_: UIView, context _: Context) {}

    @available(iOS 16.0, *)
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIView, context _: Context) -> CGSize? {
        let width = proposal.width ?? 375
        let height = uiView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height
        return CGSize(width: width, height: height)
    }
}

// MARK: - Preview

/// 리뷰 AI 번역 UI 5개 상태 (네트워크 없이 상태 주입만으로 렌더링)
#Preview("리뷰 번역 5개 상태") {
    let translated = "The kimchi stew was delicious and the portion size was decent."

    let states: [(title: String, state: ReviewTranslationState)] = [
        ("① 기본 상태 (번역 전)", .idle),
        ("② 번역 후 상태", .translated(text: translated, showingOriginal: false)),
        ("③ 원문 보기 후", .translated(text: translated, showingOriginal: true)),
        ("④ 로딩 상태", .loading),
        ("⑤ 실패 상태", .failed),
    ]

    return ScrollView {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(states, id: \.title) { item in
                Text(item.title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                ReviewTableCellPreview(state: item.state)
                    .background(Color(uiColor: .systemBackground))

                Divider()
            }
        }
    }
    .background(Color(uiColor: .secondarySystemBackground))
}
#endif
