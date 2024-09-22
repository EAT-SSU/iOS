// swift-tools-version: 5.9
import PackageDescription

#if TUIST
    import ProjectDescription

    let packageSettings = PackageSettings(
        // Customize the product types for specific package product
        // Default is .staticFramework
        // productTypes: ["Alamofire": .framework,] 
        productTypes: [:]
    )
#endif

let package = Package(
    name: "EATSSU_WORKSPACE",
    dependencies: [
        // Add your own dependencies here:
        // .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
        // You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
      .package(url: "https://github.com/SnapKit/SnapKit", from: "5.7.1"),
      .package(url: "https://github.com/uias/Tabman", from: "3.2.0"),
      .package(url: "https://github.com/Moya/Moya", branch: "master"),
      .package(url: "https://github.com/devxoul/Then", from: "3.0.0"),
      .package(url: "https://github.com/WenchaoD/FSCalendar", from: "2.8.3"),
      .package(url: "https://github.com/kakao/kakao-ios-sdk", exact: "2.22.5"),
      .package(url: "https://github.com/onevcat/Kingfisher", from: "7.12.0"),
      .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.1.0"),
      .package(url: "https://github.com/google/GoogleAppMeasurement", from: "11.1.0"),
      .package(url: "https://github.com/realm/realm-swift", from: "10.54.0"),
      .package(url: "https://github.com/ReactiveX/RxSwift", from: "6.7.1"),
    ]
)
