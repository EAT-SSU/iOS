//
//  KakaoLocalService.swift
//  EATSSU
//
//  Created by 황상환 on 7/18/26.
//

import Foundation

/// 카카오 로컬 API - 키워드 장소 검색 (카카오맵 place id 조회용)
final class KakaoLocalService {

    // MARK: - Singleton

    static let shared = KakaoLocalService()

    private init() {}

    // MARK: - Model

    struct Place: Decodable {
        let id: String
        let placeName: String
        let placeURL: String

        enum CodingKeys: String, CodingKey {
            case id
            case placeName = "place_name"
            case placeURL = "place_url"
        }
    }

    private struct SearchResponse: Decodable {
        let documents: [Place]
    }

    // MARK: - Properties

    private var restAPIKey: String? {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "KAKAO REST API KEY") as? String,
              !key.isEmpty else { return nil }
        return key
    }

    // MARK: - Request

    /// 가게명 + 좌표 기준으로 가장 가까운 장소 1건 검색 (키 미설정/실패 시 nil 반환)
    func searchNearestPlace(
        keyword: String,
        latitude: Double,
        longitude: Double,
        completion: @escaping (Place?) -> Void
    ) {
        guard let key = restAPIKey else {
            completion(nil)
            return
        }

        var components = URLComponents(string: "https://dapi.kakao.com/v2/local/search/keyword.json")
        components?.queryItems = [
            URLQueryItem(name: "query", value: keyword),
            URLQueryItem(name: "x", value: "\(longitude)"),
            URLQueryItem(name: "y", value: "\(latitude)"),
            URLQueryItem(name: "radius", value: "300"),
            URLQueryItem(name: "sort", value: "distance"),
            URLQueryItem(name: "size", value: "1")
        ]

        guard let url = components?.url else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.setValue("KakaoAK \(key)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, _, _ in
            let place = data.flatMap {
                try? JSONDecoder().decode(SearchResponse.self, from: $0).documents.first
            }
            DispatchQueue.main.async {
                completion(place)
            }
        }.resume()
    }
}
