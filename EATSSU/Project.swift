import ProjectDescription

let appInfoPlist: InfoPlist = .extendingDefault(with: [
    // API Keys Settings
    "BASE_URL": "https://$(BASE_URL)",
    "KAKAO API KEY": "$(KAKAO_API_KEY)",
    "NMFClientId": "$(NMAP_CLIENT_ID)",
    "GADApplicationIdentifier": "$(GADApplicationIdentifier)",
    "NSLocationAlwaysUsageDescription": "사용자의 위치를 받습니다.",
    "UILaunchStoryboardName": "LaunchScreen",
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
    "CFBundleDisplayName": "$(PRODUCT_NAME)",
    "NSExtension": [
        "NSExtensionPointIdentifier": "com.apple.widgetkit-extension",
    ],
    "BASE_URL": "https://$(BASE_URL)",
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
            name: "EATSSU-DEV",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.jiwoo.EatSSU",
            deploymentTargets: appDeploymentTarget,
            infoPlist: appInfoPlist,
            sources: ["App/Sources/**"],
            resources: ["App/Resources/**"],
            entitlements: "App/Entitlements/EatSSU-iOS.entitlements",
            dependencies: [
                .target(name: "EATSSUWidget-DEV"),

                // 외부 라이브러리
                .external(name: "SnapKit"),
                .external(name: "Tabman"),
                .external(name: "Moya"),
                .external(name: "Then"),
                .external(name: "FSCalendar"),
                .external(name: "Kingfisher"),
                .external(name: "GoogleAppMeasurement"),
                .external(name: "Realm"),
                .external(name: "RealmSwift"),
                .external(name: "FirebaseCrashlytics"),
                .external(name: "FirebaseAnalytics"),
                .external(name: "FirebaseRemoteConfig"),
                .external(name: "KakaoSDKAuth"),
                .external(name: "KakaoSDKUser"),
                .external(name: "KakaoSDKCommon"),
                .external(name: "KakaoSDKTalk"),
                .external(name: "GoogleMobileAds"),
                .external(name: "NMapsMap"),
                .external(name: "FloatingPanel"),

                // EATSSU 내장 라이브러리
                .project(target: "EATSSUDesign", path: .relativeToRoot("../EATSSUDesign"), condition: .none),
                .project(target: "EATSSUKit", path: .relativeToRoot("../EATSSUKit"), condition: .none),
            ],
            settings: projectSettings
        ),
        .target(
            name: "EATSSU-PROD",
            destinations: [.iPhone],
            product: .app,
            bundleId: "com.jiwoo.EatSSU",
            deploymentTargets: appDeploymentTarget,
            infoPlist: appInfoPlist,
            sources: ["App/Sources/**"],
            resources: ["App/Resources/**"],
            entitlements: "App/Entitlements/EatSSU-iOS.entitlements",
            dependencies: [
                .target(name: "EATSSUWidget-PROD"),

                // 외부 라이브러리
                .external(name: "SnapKit"),
                .external(name: "Tabman"),
                .external(name: "Moya"),
                .external(name: "Then"),
                .external(name: "FSCalendar"),
                .external(name: "Kingfisher"),
                .external(name: "GoogleAppMeasurement"),
                .external(name: "Realm"),
                .external(name: "RealmSwift"),
                .external(name: "FirebaseCrashlytics"),
                .external(name: "FirebaseAnalytics"),
                .external(name: "FirebaseRemoteConfig"),
                .external(name: "KakaoSDKAuth"),
                .external(name: "KakaoSDKUser"),
                .external(name: "KakaoSDKCommon"),
                .external(name: "KakaoSDKTalk"),
                .external(name: "GoogleMobileAds"),
                .external(name: "NMapsMap"),

                // EATSSU 내장 라이브러리
                .project(target: "EATSSUDesign", path: .relativeToRoot("../EATSSUDesign"), condition: .none),
                .project(target: "EATSSUKit", path: .relativeToRoot("../EATSSUKit"), condition: .none),
            ],
            settings: projectSettings
        ),
        .target(
            name: "EATSSUWidget-DEV",
            destinations: [.iPhone],
            product: .appExtension,
            bundleId: "com.jiwoo.EatSSU.WidgetExtension",
            deploymentTargets: widgetDeploymentTarget,
            infoPlist: widgetInfoPlist,
            sources: ["Widget/Sources/**"],
            dependencies: [
                .external(name: "Moya"),
                .external(name: "RxSwift"),
                .external(name: "RxMoya"),

                // EATSSU 내장 라이브러리
                .project(target: "EATSSUDesign", path: .relativeToRoot("../EATSSUDesign"), condition: .none),

            ],
            settings: projectSettings
        ),
        .target(
            name: "EATSSUWidget-PROD",
            destinations: [.iPhone],
            product: .appExtension,
            bundleId: "com.jiwoo.EatSSU.WidgetExtension",
            deploymentTargets: widgetDeploymentTarget,
            infoPlist: widgetInfoPlist,
            sources: ["Widget/Sources/**"],
            dependencies: [
                .external(name: "Moya"),
                .external(name: "RxSwift"),
                .external(name: "RxMoya"),

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
                .target(name: "EATSSU-DEV"),
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
                .target(name: "EATSSU-DEV"),
            ],
            settings: projectSettings
        ),
    ],
    schemes: [
        .scheme(
            name: "EATSSU-DEV",
            shared: true,
            buildAction: .buildAction(targets: [.target("EATSSU-DEV")]),
            testAction: .targets(["EATSSU-DEV"]),
            runAction: .runAction(configuration: "Debug"),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Debug"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        ),
        .scheme(name: "EATSSU-PROD",
                shared: true,
                buildAction: .buildAction(targets: [.target("EATSSU-PROD")]),
                testAction: .targets(["EATSSU-PROD"]),
                runAction: .runAction(configuration: "Release"),
                archiveAction: .archiveAction(configuration: "Release"),
                profileAction: .profileAction(configuration: "Release"),
                analyzeAction: .analyzeAction(configuration: "Release")),
        .scheme(
            name: "EATSSUWidget-DEV",
            shared: true,
            buildAction: .buildAction(targets: [.target("EATSSUWidget-DEV")]),
            testAction: .targets(["EATSSUWidget-DEV"]),
            runAction: .runAction(configuration: "Debug"),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Debug"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        ),
        .scheme(name: "EATSSUWidget-PROD",
                shared: true,
                buildAction: .buildAction(targets: [.target("EATSSUWidget-PROD")]),
                testAction: .targets(["EATSSUWidget-PROD"]),
                runAction: .runAction(configuration: "Release"),
                archiveAction: .archiveAction(configuration: "Release"),
                profileAction: .profileAction(configuration: "Release"),
                analyzeAction: .analyzeAction(configuration: "Release")),
    ]
)
