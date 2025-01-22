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
    "NSAppTransportSecurity": [
        "NSAllowsArbitraryLoads": true,
    ],
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

let appDeploymentTarget: DeploymentTargets = .iOS("15.0")
let widgetDeploymentTarget: DeploymentTargets = .iOS("17.0")

let project = Project(
    name: "EATSSU",
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
            deploymentTargets: appDeploymentTarget,
            infoPlist: appInfoPlist,
            sources: ["App/Sources/**"],
            resources: ["App/Resources/**"],
            entitlements: "App/Entitlements/EatSSU-iOS.entitlements",
            dependencies: [
                .target(name: "EATSSUWidget", status: .none, condition: .none),

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
            name: "EATSSUWidget",
            destinations: [.iPhone],
            product: .appExtension,
            bundleId: "com.jiwoo.EatSSU.Widget",
            deploymentTargets: widgetDeploymentTarget,
            infoPlist: widgetInfoPlist,
            sources: ["Widget/Sources/**"],
            dependencies: [
                .external(name: "Moya", condition: .none),
                .external(name: "RxSwift", condition: .none),
                .external(name: "RxMoya", condition: .none),
                .external(name: "CombineMoya", condition: .none),

                // EATSSU 내장 라이브러리
                .project(target: "EATSSUDesign", path: .relativeToRoot("../EATSSUDesign"), condition: .none),

            ],
            settings: projectSettings
        ),
        .target(
            name: "EATSSUUITests",
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
            name: "EATSSUUnitTests",
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
