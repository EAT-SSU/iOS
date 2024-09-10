import ProjectDescription

let eatSSUInfoPlist: InfoPlist = .extendingDefault(with: [
  "UILaunchStoryboardName": "LaunchScreen",
  "BASE_URL": "https://$(BASE_URL)",
  "KAKAO API KEY" : "$(KAKAO_API_KEY)",
  "CFBundleURLTypes": [
      [
          "CFBundleTypeRole": "Editor",
          "CFBundleURLSchemes": ["$(KAKAO_API_KEY)"]
      ]
  ],
  "LSApplicationQueriesSchemes": ["kakaokompassauth", "kakaolink"],
  "NSAppTransportSecurity": [
      "NSAllowsArbitraryLoads": true
  ],
  "UIApplicationSceneManifest": [
      "UIApplicationSupportsMultipleScenes": false,
      "UISceneConfigurations": [
          "UIWindowSceneSessionRoleApplication": [
              [
                  "UISceneConfigurationName": "Default Configuration",
                  "UISceneDelegateClassName": "$(PRODUCT_MODULE_NAME).SceneDelegate"
              ]
          ]
      ]
  ],
  // 배포용 앱 이름
  "CFBundleDisplayName": "EAT-SSU",
  // 다크모드 제한
  "UIUserInterfaceStyle": "Light",
  // iPhone Orientation 지정
  "UISupportedInterfaceOrientations": [
    "UIInterfaceOrientationPortrait"
  ],
  // 사용 국가 지정
  "CFBundleDevelopmentRegion": "ko",
])

let eatSSUSettings: Settings = .settings(
  base: [
    "OTHER_LDFLAGS":["-all_load -Objc"],
    "DEVELOPMENT_LANGUAGE": "ko"
  ],
  configurations: [
  .debug(name: "Debug", xcconfig: "EATSSU_MVC/Resources/Debug.xcconfig"),
  .release(name: "Release", xcconfig: "EATSSU_MVC/Resources/Release.xcconfig"),
  ]
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
            infoPlist: eatSSUInfoPlist,
            sources: ["EATSSU_MVC/Sources/**"],
            resources: ["EATSSU_MVC/Resources/**"],
            entitlements: "EATSSU_MVC/Resources/EatSSU-iOS.entitlements",
            dependencies: [
              .external(name: "SnapKit", condition: .none),
              .external(name: "Tabman", condition: .none),
              .external(name: "Moya", condition: .none),
              .external(name: "Then", condition: .none),
              .external(name: "FSCalendar", condition: .none),
              .external(name: "KakaoSDKAuth", condition: .none),
              .external(name: "KakaoSDKUser", condition: .none),
              .external(name: "KakaoSDKCommon", condition: .none),
              .external(name: "Kingfisher", condition: .none),
              .external(name: "FirebaseCrashlytics", condition: .none),
              .external(name: "FirebaseAnalytics", condition: .none),
              .external(name: "FirebaseRemoteConfig", condition: .none),
              .external(name: "GoogleAppMeasurement", condition: .none),
              .external(name: "Realm", condition: .none),
              .external(name: "RealmSwift", condition: .none),
              .project(target: "EATSSUComponents", path:.relativeToRoot("../EATSSUComponents"), condition: .none)
            ],
            settings: eatSSUSettings
        ),
    ]
)
