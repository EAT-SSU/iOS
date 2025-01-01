import ProjectDescription

let appInfoPlist: InfoPlist = .extendingDefault(with: [
    "UILaunchStoryboardName": "LaunchScreen",
    "BASE_URL": "https://$(BASE_URL)",
    "KAKAO API KEY": "$(KAKAO_API_KEY)",
    "CFBundleURLTypes": [
        [
            "CFBundleTypeRole": "Editor",
            "CFBundleURLSchemes": ["kakao$(KAKAO_API_KEY)"],
        ],
    ],
    "LSApplicationQueriesSchemes": [
        "kakaokompassauth",
        "kakaolink",
        "kakaoplus",
        "kakaotalk",
    ],
    "NSAppTransportSecurity": [
        "NSAllowsArbitraryLoads": true,
    ],
    "UIApplicationSceneManifest": [
        "UIApplicationSupportsMultipleScenes": false,
        "UISceneConfigurations": [
            "UIWindowSceneSessionRoleApplication": [
                [
                    "UISceneConfigurationName": "Default Configuration",
                    "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate",
                ],
            ],
        ],
    ],
    // 배포용 앱 이름
    "CFBundleDisplayName": "EAT-SSU",
    // 다크모드 제한
    "UIUserInterfaceStyle": "Light",
    // iPhone Orientation 지정
    "UISupportedInterfaceOrientations": [
        "UIInterfaceOrientationPortrait",
    ],
    // 사용 국가 지정
    "CFBundleDevelopmentRegion": "ko",
])

let widgetInfoPlist: InfoPlist = .extendingDefault(with: [
    "NSExtension": [
        "NSExtensionPointIdentifier": "com.apple.widgetkit-extension",
    ],
    "BASE_URL": "https://$(BASE_URL)",
    "CFBundleDevelopmentRegion": "ko",
])

let projectSettings: Settings = .settings(
    base: [
        "OTHER_LDFLAGS": ["-all_load -Objc"],
        "DEVELOPMENT_LANGUAGE": "ko",
        "DEVELOPMENT_TEAM": "HZ8WU7PA4J",
    ],
    configurations: [
        .debug(name: "Debug", xcconfig: "App/Resources/Secrets/Debug.xcconfig"),
        .release(name: "Release", xcconfig: "App/Resources/Secrets/Release.xcconfig"),
    ],
    defaultSettings: .recommended
)

let project = Project(
    name: "EATSSU_MVC",
    options: .options(
        defaultKnownRegions: ["ko"],
        developmentRegion: "ko"
    ),
    targets: [
        .target(
            name: "EATSSU",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.jiwoo.EatSSU",
            deploymentTargets: .iOS("17.0"),
            infoPlist: appInfoPlist,
            sources: ["App/Sources/**"],
            resources: ["App/Resources/**"],
            entitlements: "App/Resources/EatSSU-iOS.entitlements",
            dependencies: [
                .target(name: "Widget", status: .none, condition: .none),

                // 외부 라이브러리
                .external(name: "SnapKit", condition: .none),
                .external(name: "Tabman", condition: .none),
                .external(name: "Moya", condition: .none),
                .external(name: "Then", condition: .none),
                .external(name: "FSCalendar", condition: .none),
                .external(name: "Kingfisher", condition: .none),
                .external(name: "GoogleAppMeasurement", condition: .none),
                .external(name: "Realm", condition: .none),
                .external(name: "RealmSwift", condition: .none),
                .external(name: "FirebaseCrashlytics", condition: .none),
                .external(name: "FirebaseAnalytics", condition: .none),
                .external(name: "FirebaseRemoteConfig", condition: .none),
                .external(name: "KakaoSDKAuth", condition: .none),
                .external(name: "KakaoSDKUser", condition: .none),
                .external(name: "KakaoSDKCommon", condition: .none),
                .external(name: "KakaoSDKTalk", condition: .none),

                // EATSSU 내장 라이브러리
                .project(target: "EATSSUDesign", path: .relativeToRoot("../EATSSUDesign"), condition: .none),
            ],
            settings: projectSettings
        ),
        .target(
            name: "Widget",
            destinations: [.iPhone],
            product: .appExtension,
            bundleId: "com.jiwoo.EatSSU.Widget",
            deploymentTargets: .iOS("17.0"),
            infoPlist: widgetInfoPlist,
            sources: ["Widget/Sources/**"],
            resources: ["Widget/Resources/**"],
            dependencies: [],
            settings: projectSettings
        ),
        .target(
            name: "UITests",
            destinations: [.iPhone],
            product: .uiTests,
            bundleId: "com.jiwoo.EatSSU.UITests",
            sources: ["Tests/UITests/**"],
            dependencies: [
                .target(name: "EATSSU", status: .none, condition: .none),
            ],
            settings: projectSettings
        ),
        .target(
            name: "UnitTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.jiwoo.EatSSU.UnitTests",
            sources: ["Tests/UnitTests/**"],
            dependencies: [
                .target(name: "EATSSU", status: .none, condition: .none),
            ],
            settings: projectSettings
        ),
    ]
)
