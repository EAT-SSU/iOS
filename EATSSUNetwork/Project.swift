import ProjectDescription

let project = Project(
    name: "EATSSUNetwork",
    targets: [
        .target(
            name: "EATSSUNetwork",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.EATSSU.EATSSUNetwork",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["EATSSUNetwork/Sources/**"],
            dependencies: [
                .external(name: "RxMoya"),
                .external(name: "Moya"),
            ]
        ),
        .target(
            name: "EATSSUNetworkTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.EATSSU.EATSSUNetworkTests",
            infoPlist: .default,
            sources: ["EATSSUNetwork/Tests/**"],
            resources: [],
            dependencies: [.target(name: "EATSSUNetwork")]
        ),
    ]
)
