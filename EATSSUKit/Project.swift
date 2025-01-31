import ProjectDescription

let project = Project(
    name: "EATSSUKit",
    targets: [
        .target(
            name: "EATSSUKit",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.EATSSU.EATSSUKit",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["EATSSUKit/Sources/**"],
            dependencies: []
        ),
        .target(
            name: "EATSSUKitTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.EATSSU.EATSSUKitTests",
            infoPlist: .default,
            sources: ["EATSSUKit/Tests/**"],
            resources: [],
            dependencies: [.target(name: "EATSSUKit")]
        ),
    ]
)
