import ProjectDescription

let project = Project(
    name: "EATSSUDesign",
    targets: [
        .target(
            name: "EATSSUDesign",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.EATSSU.Design",
            deploymentTargets: .iOS("15.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            sources: ["EATSSUDesign/Sources/**"],
            resources: ["EATSSUDesign/Resources/**"],
            dependencies: [
                .external(name: "SnapKit"),
                .external(name: "Kingfisher"),

                .project(target: "EATSSUKit", path: .relativeToRoot("../EATSSUKit"), condition: .none),
            ]
        ),
    ]
)
