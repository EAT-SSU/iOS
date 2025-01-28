// swift-tools-version: 6.0
import PackageDescription

#if TUIST
    import ProjectDescription

    // Tuist가 #if TUIST 영역을 해석할 때,
    // 각 SPM 라이브러리를 동적 프레임워크(.framework)로 빌드하도록 설정
    let packageSettings = PackageSettings(
        productTypes: [
            "Alamofire": .framework,
            "Moya": .framework,
            "RxMoya": .framework,
            "SnapKit": .framework,
            "Tabman": .framework,
            "Then": .framework,
            "FSCalendar": .framework,
            "Kingfisher": .framework,

            // Kakao iOS SDK
            // 실제 사용 모듈(예: KakaoSDKAuth, KakaoSDKUser 등)을 정확히 써야 함
            "KakaoSDKCommon": .framework,
            "KakaoSDKAuth": .framework,
            "KakaoSDKUser": .framework,

            // Firebase 계열 (예: FirebaseAnalytics, FirebaseCore, FirebaseAuth 등)
            "Firebase": .framework,
            "GoogleAppMeasurement": .framework,

            // Google Ad Mobs
            "GoogleMobileAds": .framework,

            // realm-swift
            "Realm": .framework,
            "RealmSwift": .framework,

            // RxSwift
            "RxSwift": .framework,

            // Naver Maps
            "NMapsMap": .framework,
        ]
    )
#endif

let package = Package(
    name: "EATSSU_WORKSPACE",
    dependencies: [
        .package(url: "https://github.com/SnapKit/SnapKit", from: "5.7.1"),
        .package(url: "https://github.com/uias/Tabman", from: "3.2.0"),
        .package(url: "https://github.com/Moya/Moya", from: "15.0.0"),
        .package(url: "https://github.com/devxoul/Then", from: "3.0.0"),
        .package(url: "https://github.com/WenchaoD/FSCalendar", from: "2.8.3"),
        .package(url: "https://github.com/kakao/kakao-ios-sdk", from: "2.22.5"),
        .package(url: "https://github.com/onevcat/Kingfisher", from: "7.12.0"),
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.1.0"),
        .package(url: "https://github.com/google/GoogleAppMeasurement", from: "11.1.0"),
        .package(url: "https://github.com/realm/realm-swift", from: "20.0.0"),
        .package(url: "https://github.com/ReactiveX/RxSwift", from: "6.7.1"),
        .package(url: "https://github.com/googleads/swift-package-manager-google-mobile-ads.git", from: "11.0.0"),
        .package(url: "https://github.com/navermaps/SPM-NMapsMap", from: "3.20.0"),
    ]
)
