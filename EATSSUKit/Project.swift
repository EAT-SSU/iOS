import ProjectDescription

let project = Project(
    name: "EATSSUKit",
    targets: [
        .target(
            name: "EATSSUKit",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.EATSSU.EATSSUKit",
            deploymentTargets: .iOS("15.0"),
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
    ]
)
