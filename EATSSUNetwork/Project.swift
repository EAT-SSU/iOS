import ProjectDescription

let networkFrameworkInfoPlist: InfoPlist = .extendingDefault(with: [
    "CFBundleDisplayName": "$(PRODUCT_NAME)",
    "BASE_URL": "https://$(BASE_URL)",
])

let networkFrameworkSettings: Settings = .settings(
    configurations: [
        .debug(name: "Debug", xcconfig: "EATSSUNetwork/Resources/Secrets/Debug.xcconfig"),
        .release(name: "Release", xcconfig: "EATSSUNetwork/Resources/Secrets/Release.xcconfig"),
    ],
    defaultSettings: .recommended
)

let project = Project(
    name: "EATSSUNetwork",
    targets: [
        .target(
            name: "EATSSUNetwork",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.EATSSU.EATSSUNetwork",
            deploymentTargets: .iOS("15.0"),
            infoPlist: networkFrameworkInfoPlist,
            sources: ["EATSSUNetwork/Sources/**"],
            dependencies: [
                .external(name: "RxMoya"),
                .external(name: "Moya"),
            ],
            settings: networkFrameworkSettings
        ),
        .target(
            name: "EATSSUNetworkTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.EATSSU.EATSSUNetworkTests",
            infoPlist: networkFrameworkInfoPlist,
            sources: ["EATSSUNetwork/Tests/**"],
            resources: [],
            dependencies: [.target(name: "EATSSUNetwork")],
            settings: networkFrameworkSettings
        ),
    ]
)
