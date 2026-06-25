import ProjectDescription

let appInfoPlist: InfoPlist = .extendingDefault(with: [
    "CFBundleShortVersionString": "$(MARKETING_VERSION)",
    "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
    "UILaunchStoryboardName": "LaunchScreen",
    "BASE_URL": "https://$(BASE_URL)",
    "KAKAO API KEY": "$(KAKAO_API_KEY)",
    "AppGroupID": "$(APP_GROUP_ID)",
    "FirebaseAutomaticScreenReportingEnabled": false,
    "UIBackgroundModes": [
        "remote-notification"
    ],
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
    "NSLocationWhenInUseUsageDescription": "지도에서 내 위치를 바로 확인하고, 현재 위치 주변의 제휴점들을 손쉽게 찾아볼 수 있도록 위치 권한을 허용해 주세요.",
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
    "NAVER_CLIENT_ID": "$(NAVER_CLIENT_ID)",
    "POSTHOG_API_KEY": "$(POSTHOG_API_KEY)",
    "HOLIDAY_API_KEY": "$(HOLIDAY_API_KEY)",
])

let widgetInfoPlist: InfoPlist = .extendingDefault(with: [
    "CFBundleShortVersionString": "$(MARKETING_VERSION)",
    "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
    "CFBundleDisplayName": "$(PRODUCT_NAME)",
    "NSExtension": [
        "NSExtensionPointIdentifier": "com.apple.widgetkit-extension",
    ],
    "BASE_URL": "https://$(BASE_URL)",
    "AppGroupID": "$(APP_GROUP_ID)",
])

let projectSettings: Settings = .settings(
    base: [
        "OTHER_LDFLAGS": ["-all_load", "-ObjC"],
        "DEVELOPMENT_LANGUAGE": "ko",
        "DEVELOPMENT_TEAM": "BBVZV8T99P",
        "SWIFT_CONCURRENCY": "complete",
        "CODE_SIGN_STYLE": "Manual",
        "MARKETING_VERSION": "3.5.0",
        "CURRENT_PROJECT_VERSION": "1",
        "ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS": "YES"
    ],
    configurations: [
        .debug(
            name: "Debug",
            settings: [
                "DEBUG_INFORMATION_FORMAT": "dwarf",
                "APS_ENVIRONMENT": "development",
            ],
            xcconfig: "App/Resources/Secrets/Debug.xcconfig"
        ),
        .release(
            name: "Release",
            settings: [
                "DEBUG_INFORMATION_FORMAT": "dwarf-with-dsym",
                "APS_ENVIRONMENT": "production",
            ],
            xcconfig: "App/Resources/Secrets/Release.xcconfig"
        ),
    ],
    defaultSettings: .recommended
)

let appDeploymentTarget: DeploymentTargets = .iOS("15.0")
let widgetDeploymentTarget: DeploymentTargets = .iOS("17.0")

let project = Project(
    name: "EATSSU",
    options: .options(
        defaultKnownRegions: ["ko", "en"],
        developmentRegion: "ko"
    ),
    settings: projectSettings,
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
            entitlements: "App/Entitlements/EatSSU-iOS-Dev.entitlements",
            scripts: [],
            dependencies: [
                .target(name: "EATSSUWidget-DEV"),

                // 외부 라이브러리
                .external(name: "SnapKit"),
                .external(name: "Tabman"),
                .external(name: "Moya"),
                .external(name: "FSCalendar"),
                .external(name: "Kingfisher"),
                .external(name: "Realm"),
                .external(name: "RealmSwift"),
                .external(name: "FirebaseCrashlytics"),
                .external(name: "FirebaseAnalytics"),
                .external(name: "FirebaseRemoteConfig"),
                .external(name: "FirebaseMessaging"),
                .external(name: "KakaoSDKAuth"),
                .external(name: "KakaoSDKUser"),
                .external(name: "KakaoSDKCommon"),
                .external(name: "KakaoSDKTalk"),
                .external(name: "NMapsMap"),
                .external(name: "PostHog"),

                // EATSSU 내장 라이브러리
                .project(target: "EATSSUDesign", path: .relativeToRoot("../EATSSUDesign"), condition: .none),
            ],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug",
                           settings: [
                               "PROVISIONING_PROFILE_SPECIFIER": "match Development com.jiwoo.EatSSU",
                               "CODE_SIGN_IDENTITY": "Apple Development",
                               "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEV"
                           ],
                           xcconfig: "App/Resources/Secrets/Debug.xcconfig"
                    ),
                    .release(name: "Release",
                             settings: [
                               "PROVISIONING_PROFILE_SPECIFIER": "match AppStore com.jiwoo.EatSSU",
                               "CODE_SIGN_IDENTITY": "Apple Distribution",
                               "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEV"
                             ],
                             xcconfig: "App/Resources/Secrets/Release.xcconfig"
                    )
                ]
            )
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
            entitlements: "App/Entitlements/EatSSU-iOS-Prod.entitlements",
            scripts: [],
            dependencies: [
                .target(name: "EATSSUWidget-PROD"),

                // 외부 라이브러리
                .external(name: "SnapKit"),
                .external(name: "Tabman"),
                .external(name: "Moya"),
                .external(name: "FSCalendar"),
                .external(name: "Kingfisher"),
                .external(name: "Realm"),
                .external(name: "RealmSwift"),
                .external(name: "FirebaseCrashlytics"),
                .external(name: "FirebaseAnalytics"),
                .external(name: "FirebaseRemoteConfig"),
                .external(name: "FirebaseMessaging"),
                .external(name: "KakaoSDKAuth"),
                .external(name: "KakaoSDKUser"),
                .external(name: "KakaoSDKCommon"),
                .external(name: "KakaoSDKTalk"),
                .external(name: "NMapsMap"),
                .external(name: "PostHog"),

                // EATSSU 내장 라이브러리
                .project(target: "EATSSUDesign", path: .relativeToRoot("../EATSSUDesign"), condition: .none),
            ],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug",
                           settings: [
                               "PROVISIONING_PROFILE_SPECIFIER": "match Development com.jiwoo.EatSSU",
                               "CODE_SIGN_IDENTITY": "Apple Development"
                           ],
                           xcconfig: "App/Resources/Secrets/Debug.xcconfig"
                    ),
                    .release(name: "Release",
                             settings: [
                               "PROVISIONING_PROFILE_SPECIFIER": "match AppStore com.jiwoo.EatSSU",
                               "CODE_SIGN_IDENTITY": "Apple Distribution"
                             ],
                             xcconfig: "App/Resources/Secrets/Release.xcconfig"
                    )
                ]
            )
        ),
        .target(
            name: "EATSSUWidget-DEV",
            destinations: [.iPhone],
            product: .appExtension,
            bundleId: "com.jiwoo.EatSSU.EatSSUwidget2025",
            deploymentTargets: widgetDeploymentTarget,
            infoPlist: widgetInfoPlist,
            sources: ["Widget/Sources/**",
                      "App/Sources/Data/Firebase/WidgetAnalyticsManager.swift"
                     ],
            entitlements: "App/Entitlements/EatSSU-iOS-Dev.entitlements",
            dependencies: [
                .external(name: "Moya"),
                .external(name: "CombineMoya"),

                // EATSSU 내장 라이브러리
                .project(target: "EATSSUDesign", path: .relativeToRoot("../EATSSUDesign"), condition: .none),

            ],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug",
                           settings: [
                                "PROVISIONING_PROFILE_SPECIFIER": "match Development com.jiwoo.EatSSU.EatSSUwidget2025",
                                "CODE_SIGN_IDENTITY": "Apple Development",
                                "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEV"
                           ],
                           xcconfig: "App/Resources/Secrets/Debug.xcconfig"
                    ),
                    .release(name: "Release",
                             settings: [
                                "PROVISIONING_PROFILE_SPECIFIER": "match AppStore com.jiwoo.EatSSU.EatSSUwidget2025",
                                "CODE_SIGN_IDENTITY": "Apple Distribution",
                                "SWIFT_ACTIVE_COMPILATION_CONDITIONS": "$(inherited) DEV"
                             ],
                             xcconfig: "App/Resources/Secrets/Release.xcconfig"
                    )
                ]
            )
        ),
        .target(
            name: "EATSSUWidget-PROD",
            destinations: [.iPhone],
            product: .appExtension,
            bundleId: "com.jiwoo.EatSSU.EatSSUwidget2025",
            deploymentTargets: widgetDeploymentTarget,
            infoPlist: widgetInfoPlist,
            sources: ["Widget/Sources/**",
                      "App/Sources/Data/Firebase/WidgetAnalyticsManager.swift"
                     ],
            entitlements: "App/Entitlements/EatSSU-iOS-Prod.entitlements",
            dependencies: [
                .external(name: "Moya"),
                .external(name: "CombineMoya"),

                // EATSSU 내장 라이브러리
                .project(target: "EATSSUDesign", path: .relativeToRoot("../EATSSUDesign"), condition: .none),

            ],
            settings: .settings(
                configurations: [
                    .debug(name: "Debug",
                           settings: [
                                "PROVISIONING_PROFILE_SPECIFIER": "match Development com.jiwoo.EatSSU.EatSSUwidget2025",
                                "CODE_SIGN_IDENTITY": "Apple Development"
                           ],
                           xcconfig: "App/Resources/Secrets/Debug.xcconfig"
                    ),
                    .release(name: "Release",
                             settings: [
                                "PROVISIONING_PROFILE_SPECIFIER": "match AppStore com.jiwoo.EatSSU.EatSSUwidget2025",
                                "CODE_SIGN_IDENTITY": "Apple Distribution"
                             ],
                             xcconfig: "App/Resources/Secrets/Release.xcconfig"
                    )
                ]
            )
        ),

        .target(
            name: "EATSSUUITests",
            destinations: [.iPhone],
            product: .uiTests,
            bundleId: "com.jiwoo.EatSSU.UITests",
            sources: ["Tests/UITests/**"],
            dependencies: [
                .target(name: "EATSSU-DEV"),
            ]
        ),
        .target(
            name: "EATSSUUnitTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "com.jiwoo.EatSSU.UnitTests",
            sources: ["Tests/UnitTests/**"],
            dependencies: [
                .target(name: "EATSSU-DEV"),
            ]
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
            profileAction: .profileAction(configuration: "Release"),
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
            profileAction: .profileAction(configuration: "Release"),
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
