//
//  AppConfiguration.swift
//  EATSSU
//
//  Edited by Jiwoong CHOI on 02/17/2025.
//

import Foundation

/**
 # AppConfiguration

 앱의 설정 정보를 Info.plist에서 읽어오는 역할을 수행합니다.

 - 주요 기능:
    - Info.plist 파일 내의 앱 설정 정보를 딕셔너리 형태로 불러옵니다.
    - "BASE_URL" 키를 사용하여 앱의 Base URL 값을 반환합니다.
    - 설정 정보가 없을 경우 `fatalError`를 발생시켜 문제를 즉시 확인할 수 있도록 합니다.
 */
public enum AppConfiguration {
    /**
      Info.plist에 사용되는 키들을 정의하는 네임스페이스입니다.

      - Plist:
         - `baseURL`: Info.plist 내에 설정된 Base URL 키값입니다.
     */
    private enum Keys {
        enum Plist {
            /// Info.plist에 설정된 Base URL 키값.
            static let baseURL = "BASE_URL"
        }
    }

    /// 앱 번들 내의 Info.plist 파일 내용을 딕셔너리 형태로 저장합니다.
    private static let infoDictionary: [String: Any] = {
        guard let dict = Bundle.main.infoDictionary else {
            fatalError("plist cannot found.")
        }
        return dict
    }()
}

public extension AppConfiguration {
    /**
     Info.plist에서 읽어온 Base URL 값을 반환합니다.

     앱 실행 중 Info.plist에 "BASE_URL"이 없으면 `fatalError`를 발생시킵니다.

     # 사용 예시
     ```swift
     let url = AppConfiguration.baseURL
     print("Base URL: \(url)")
     ```
     */
    static let baseURL: String = {
        guard let key = AppConfiguration.infoDictionary[Keys.Plist.baseURL] as? String else {
            fatalError("Base URL is not set in plist for this configuration.")
        }
        return key
    }()
}
