//
//  MapAppLauncher.swift
//  EATSSU
//
//  Created by 황상환 on 8/29/26.
//

import UIKit

/// 매장 정보를 카카오맵/네이버지도 앱으로 연결하는 헬퍼
///
/// 서버 제공 URL 우선 → 카카오 로컬 검색 매칭 → 좌표/검색어 폴백 순서로 시도한다.
/// 서버 URL이 없는 매장(착한가격업소 등)은 `Destination`의 URL을 nil로 넘기면
/// 자연스럽게 검색 → 폴백 경로를 탄다.
/// 카카오 로컬 검색 결과는 인스턴스 단위로 캐시해 두 버튼이 공유한다.
final class MapAppLauncher {

    // MARK: - Model

    struct Destination {
        let name: String
        let latitude: Double
        let longitude: Double
        var kakaoMapUrl: String? = nil
        var naverMapUrl: String? = nil
    }

    // MARK: - Properties

    private let destination: Destination

    /// 카카오 로컬 검색 결과 캐시. 실패(nil)는 일시적 네트워크 오류일 수 있어 캐시하지 않는다
    private var cachedPlace: KakaoLocalService.Place?

    // MARK: - Init

    init(destination: Destination) {
        self.destination = destination
    }

    // MARK: - Kakao Map

    /// 카카오맵 장소 상세 페이지로 이동
    /// 서버 제공 URL 우선 → 없으면 로컬 API 매칭 → 실패 시 좌표 핀 폴백
    func openKakaoMap() {
        // 서버가 준 place URL(place.map.kakao.com/{id})에서 id를 추출해 앱 스킴으로 연결
        if let urlString = destination.kakaoMapUrl,
           let webURL = URL(string: urlString),
           Int(webURL.lastPathComponent) != nil {
            let appURL = URL(string: "kakaomap://place?id=\(webURL.lastPathComponent)")
            open(appURL: appURL, fallbackURL: webURL)
            return
        }

        searchPlace { [weak self] place in
            guard let self else { return }

            if let place {
                let appURL = URL(string: "kakaomap://place?id=\(place.id)")
                self.open(appURL: appURL, fallbackURL: URL(string: place.placeURL))
            } else {
                self.openKakaoMapByCoordinate()
            }
        }
    }

    /// 카카오맵 좌표 핀으로 이동 (미설치 시 카카오맵 웹)
    private func openKakaoMapByCoordinate() {
        let appURL = URL(string: "kakaomap://look?p=\(destination.latitude),\(destination.longitude)")
        let encodedName = Self.percentEncodedForMapURL(destination.name)
        let webURL = URL(
            string: "https://map.kakao.com/link/map/\(encodedName),\(destination.latitude),\(destination.longitude)"
        )
        open(appURL: appURL, fallbackURL: webURL)
    }

    // MARK: - Naver Map

    /// 네이버지도 플레이스로 이동
    /// 서버 제공 URL 우선(유니버설 링크로 앱/웹 자동 분기) → 없으면 정제된 상호명 검색 폴백
    func openNaverMap() {
        if let urlString = destination.naverMapUrl,
           let url = URL(string: urlString) {
            UIApplication.shared.open(url)
            return
        }

        searchPlace { [weak self] place in
            guard let self else { return }
            self.openNaverMapSearch(query: place?.placeName ?? self.destination.name)
        }
    }

    private func openNaverMapSearch(query: String) {
        var components = URLComponents(string: "nmap://search")
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "appname", value: Bundle.main.bundleIdentifier ?? "")
        ]
        let encodedQuery = Self.percentEncodedForMapURL(query)
        let webURL = URL(string: "https://map.naver.com/p/search/\(encodedQuery)")
        open(appURL: components?.url, fallbackURL: webURL)
    }

    // MARK: - Search

    /// 카카오 로컬 검색. 성공 결과는 캐시해 이후 호출에서 네트워크 없이 즉시 반환
    private func searchPlace(completion: @escaping (KakaoLocalService.Place?) -> Void) {
        if let cachedPlace {
            completion(cachedPlace)
            return
        }

        KakaoLocalService.shared.searchNearestPlace(
            keyword: destination.name,
            latitude: destination.latitude,
            longitude: destination.longitude
        ) { [weak self] place in
            self?.cachedPlace = place
            completion(place)
        }
    }

    // MARK: - Open

    private func open(appURL: URL?, fallbackURL: URL?) {
        if let appURL, UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL)
        } else if let fallbackURL {
            UIApplication.shared.open(fallbackURL)
        }
    }

    /// 지도 웹 URL 경로에 안전하게 넣을 수 있도록 경로/구분자 문자까지 인코딩
    private static func percentEncodedForMapURL(_ text: String) -> String {
        var allowed = CharacterSet.urlPathAllowed
        allowed.remove(charactersIn: "/?&,")
        return text.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
    }
}
