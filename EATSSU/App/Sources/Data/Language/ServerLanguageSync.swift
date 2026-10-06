//
//  ServerLanguageSync.swift
//  EATSSU
//
//  Created by 황상환 on 10/6/26.
//

import Foundation

/// 서버의 유저 언어 설정을 앱 언어와 맞춘다
///
/// 메뉴 찜 검색·목록의 메뉴명은 요청 파라미터가 아니라 서버에 저장된 유저 언어(기본 KO) 기준으로 번역된다.
/// 앱 언어는 로컬에만 저장되므로, 로그인 상태로 진입할 때마다 현재 값을 보내 어긋나지 않게 한다.
enum ServerLanguageSync {
    static func sync(_ language: AppLanguage = AppLanguageManager.shared.currentLanguage) {
        guard TokenStore.hasAccessToken else { return }
        NetworkService.shared.request(
            MyRouter.updateLanguage(language: language.serverCode),
            responseType: Bool.self,
            useAuth: true
        ) { result in
            // 실패해도 다음 진입 때 다시 맞추므로 사용자에게 알리지 않는다
            if case .failure(let error) = result {
                print("서버 언어 동기화 실패: \(error.localizedDescription)")
            }
        }
    }
}
