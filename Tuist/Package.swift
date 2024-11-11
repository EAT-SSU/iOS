// swift-tools-version: 6.0
@preconcurrency import PackageDescription

#if TUIST
import ProjectDescription

let packageSettings = PackageSettings(
	// Customize the product types for specific package product
	// Default is .staticFramework
	// productTypes: ["Alamofire": .framework,]
	productTypes: ["SnapKit": .framework, "Kingfisher": .framework]
)
#endif

let package = Package(
	name: "EATSSU_WORKSPACE",
	dependencies: [
		// Add your own dependencies here:
		// .package(url: "https://github.com/Alamofire/Alamofire", from: "5.0.0"),
		// You can read more about dependencies here: https://docs.tuist.io/documentation/tuist/dependencies
		// Auto Layout 코드를 간편하게 작성할 수 있도록 도와주는 선언형 Swift API.
		.package(url: "https://github.com/SnapKit/SnapKit", from: "5.7.1"),

		// 강력하고 커스터마이징 가능한 탭 바 인터페이스를 만들 수 있는 라이브러리.
		.package(url: "https://github.com/uias/Tabman", from: "3.2.0"),

		// HTTP API 요청을 간단하게 처리할 수 있는 네트워크 추상화 계층.
		.package(url: "https://github.com/Moya/Moya", branch: "master"),

		// Swift 초기화를 더 간결하고 읽기 쉽게 만드는 문법적 설탕을 제공.
		.package(url: "https://github.com/devxoul/Then", from: "3.0.0"),

		// 날짜와 이벤트를 표시할 수 있는 커스터마이징 가능한 캘린더 컴포넌트.
		.package(url: "https://github.com/WenchaoD/FSCalendar", from: "2.8.3"),

		// 카카오 로그인, 공유 등 카카오 서비스에 연결할 수 있는 SDK.
		.package(url: "https://github.com/kakao/kakao-ios-sdk", exact: "2.22.5"),

		// 이미지 다운로드와 캐싱을 효율적으로 처리하는 이미지 라이브러리.
		.package(url: "https://github.com/onevcat/Kingfisher", from: "7.12.0"),

		// 분석, 데이터베이스, 메시징 등 다양한 Firebase 기능을 통합할 수 있는 SDK.
		.package(url: "https://github.com/firebase/firebase-ios-sdk", from: "11.1.0"),

		// 앱 분석과 트래킹을 위한 Google 라이브러리.
		.package(url: "https://github.com/google/GoogleAppMeasurement", from: "11.1.0"),

		// 빠른 성능과 쉬운 동기화를 제공하는 Swift용 로컬 데이터베이스 솔루션.
		.package(url: "https://github.com/realm/realm-swift", from: "20.0.0"),

		// Swift에서 반응형 프로그래밍을 가능하게 하는 프레임워크.
		.package(url: "https://github.com/ReactiveX/RxSwift", from: "6.7.1"),

		// 더 나은 디커플링과 모듈화를 위한 의존성 주입 프레임워크.
		.package(url: "https://github.com/Swinject/Swinject", from: "2.9.1"),
	]
)
