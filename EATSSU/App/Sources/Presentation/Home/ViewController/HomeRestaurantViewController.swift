//
//  HomeRestaurantViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/08.

import UIKit

import Moya
import SnapKit
import Combine

import EATSSUDesign

// 메뉴 리뷰 정보를 전달하는 델리게이트 프로토콜
protocol ReviewMenuTypeInfoDelegate: AnyObject {
    func didDelegateReviewMenuTypeInfo(for menuTypeData: ReviewMenuTypeInfo)
}

// 식당 정보 버튼 탭 이벤트를 처리하는 델리게이트 프로토콜
protocol RestaurantInfoDelegate: AnyObject {
    func didTappedRestaurantInfo(restaurantName: String)
}

final class HomeRestaurantViewController: BaseViewController {
    // MARK: - Properties
    
    // Combine 요청을 관리하기 위한 Set
    private var cancellables = Set<AnyCancellable>()

    // 메뉴 타이틀 셀의 개수 (섹션마다 1개 고정)
    private let restaurantTableViewMenuTitleCellCount = 1

    // 테이블뷰 섹션 헤더의 높이
    private let headerHeight: CGFloat = 48

    // 식당 정보 탭 시 델리게이트
    weak var infoDelegate: RestaurantInfoDelegate?

    // 리뷰 작성 뷰로 데이터 전달할 델리게이트
    var delegate: ReviewMenuTypeInfoDelegate?

    // 고정 메뉴 더미 데이터 (주말/방학 대비용)
    private let fixedDummy = FixedMenuInfoData.Dummy()

    // 섹션 헤더에 들어갈 식당명 문자열 배열
    private let sectionHeaderRestaurant = [TextLiteral.studentRestaurant,
                                           TextLiteral.dodamRestaurant,
                                           TextLiteral.dormitoryRestaurant,
                                           TextLiteral.facultyRestaurant,
                                           TextLiteral.snackCorner]

    // 버튼에 표시되는 타이틀을 백엔드 식당 이름으로 매핑
    let restaurantButtonTitleToName = [TextLiteral.studentRestaurant: "HAKSIK",
                                       TextLiteral.dodamRestaurant: "DODAM",
                                       TextLiteral.dormitoryRestaurant: "DORMITORY",
                                       TextLiteral.facultyRestaurant: "FACULTY",
                                       TextLiteral.snackCorner: "SNACK_CORNER"]
    
    // 변경 메뉴를 가져올 식당 식별자 목록(스낵 제외)
    private var changeRestaurantIDs: [String] {
        sectionHeaderRestaurant
            .compactMap { restaurantButtonTitleToName[$0] }
            .filter { $0 != Restaurant.snackCorner.identifier }
    }
    
    // info 버튼 UIAction 고정 식별자
    private static let infoActionID = UIAction.Identifier("com.eatssu.header.infoTap")

    // 현재 요일이 주말인지 여부 판단
    var isWeekend = false

    // 셀 선택 가능 여부 (가격 유무에 따라 다름)
    var isSelectable = false

    // 변경 메뉴 데이터 (식당명: 메뉴 배열)
    var changeMenuTableViewData: [String: [ChangeMenuTableResponse]] = [:]

    // 고정 메뉴 데이터 (간식코너)
    var fixMenuTableViewData: [String: [Menus]] = [:]
    
    // MARK: - UI Components

    // 뷰 전반을 구성하는 restaurantView
    let restaurantView = HomeRestaurantView()

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setDelegate() // 테이블뷰 델리게이트 연결
        setTableView() // 테이블뷰 셀 등록
    }

    // MARK: - Functions

    // 전체 UI 구성
    override func configureUI() {
        view.addSubviews(restaurantView)
    }

    // SnapKit을 이용한 레이아웃 설정
    override func setLayout() {
        restaurantView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // 테이블뷰 delegate/dataSource 연결
    func setDelegate() {
        restaurantView.restaurantTableView.dataSource = self
        restaurantView.restaurantTableView.delegate = self
    }

    // 테이블뷰 셀 및 헤더 등록
    func setTableView() {
        restaurantView.restaurantTableView.register(RestaurantTableViewHeader.self,
            forHeaderFooterViewReuseIdentifier: RestaurantTableViewHeader.identifier)
        restaurantView.restaurantTableView.register(RestaurantMenuGroupCell.self,
                                                    forCellReuseIdentifier: RestaurantMenuGroupCell.identifier)
        restaurantView.restaurantTableView.rowHeight = UITableView.automaticDimension
        restaurantView.restaurantTableView.estimatedRowHeight = 100
    }

    // 식당 identifier로 섹션 인덱스 반환
    func getSectionIndex(for restaurant: String) -> Int? {
        for (idx, title) in sectionHeaderRestaurant.enumerated() {
            if restaurantButtonTitleToName[title] == restaurant {
                return idx
            }
        }
        return nil
    }

    // 섹션 인덱스로 식당 identifier 반환 (표시 타이틀 → identifier 매핑 기반)
    func getSectionKey(for section: Int) -> String {
        let title = sectionHeaderRestaurant[section]
        return restaurantButtonTitleToName[title] ?? ""
    }

    // 날짜와 시간에 따라 메뉴 데이터 fetch
    func fetchData(date: Date, time: String) {
        // 새로운 데이터 요청 전, 이전 요청들을 모두 취소
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
        
        let formatDate = changeDateFormat(date: date)

        // 변경 메뉴 일괄 요청(스낵 제외, UI 순서대로)
        let task = _Concurrency.Task {
            // 변경 메뉴들을 병렬로 요청
            await withTaskGroup(of: Void.self) { group in
                for id in changeRestaurantIDs {
                    group.addTask {
                        await self.fetchChangeMenuData(date: formatDate, restaurant: id, time: time)
                    }
                }
            }
        }

        // Task를 AnyCancellable로 변환해서 저장 (취소 가능하도록)
        cancellables.insert(AnyCancellable { task.cancel() })
        
        let weekday = Weekday.from(date: date)
        isWeekend = weekday.isWeekend

        if time == TextLiteral.lunchRawValue {
            // 학기 중 평일 점심에만 스낵 고정 메뉴 요청
            if !FirebaseRemoteConfig.shared.isVacationPeriod, !weekday.isWeekend {
                isSelectable = true
                let fixTask = _Concurrency.Task {
                    await self.fetchFixedMenuData(restaurant: Restaurant.snackCorner.identifier)
                }
                cancellables.insert(AnyCancellable { fixTask.cancel() })
            } else {
                // 방학/주말 더미
                fixMenuTableViewData[Restaurant.snackCorner.identifier] = []
            }
        }
    }

    // 날짜를 yyyyMMdd 포맷 문자열로 변환
    func changeDateFormat(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: date)
    }
}

// MARK: - UITableViewDataSource

extension HomeRestaurantViewController: UITableViewDataSource {
    // 섹션 개수 설정 (기숙사, 도담, 학생, 간식)
    func numberOfSections(in _: UITableView) -> Int {
        sectionHeaderRestaurant.count
    }

    // 각 섹션마다 보여줄 셀 개수 계산
    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    // 셀 구성
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: RestaurantMenuGroupCell.identifier,
            for: indexPath
        ) as! RestaurantMenuGroupCell

        let sectionKey = getSectionKey(for: indexPath.section)
        let isSnackCorner = (sectionKey == Restaurant.snackCorner.identifier)

        let menuList: [MenuTypeInfo] = isSnackCorner
            ? (fixMenuTableViewData[sectionKey]?.map { .fix($0) } ?? [])
            : (changeMenuTableViewData[sectionKey]?.map { .change($0) } ?? [])

        cell.configure(with: menuList, at: indexPath) { [weak self] indexPath, menuIndex in
            self?.handleMenuTap(section: indexPath.section, menuIndex: menuIndex)
        }
        return cell
    }

    private func handleMenuTap(section: Int, menuIndex: Int) {
        if RealmService.shared.isAccessTokenPresent() == false {
            presentLoginAlert()
            return
        }

        let restaurant = getSectionKey(for: section)
        
        // firebase - click_menu 이벤트 호출
        if section < sectionHeaderRestaurant.count {
            let restaurantName = sectionHeaderRestaurant[section]
            HomeAnalyticsManager.shared.logClickMenu(restaurantName: restaurantName)
        }
        
        let isSnackCorner = (restaurant == Restaurant.snackCorner.identifier)

        var reviewMenuTypeInfo = ReviewMenuTypeInfo(menuType: "", menuID: 0)

        if !isSnackCorner {
            guard let menus = changeMenuTableViewData[restaurant],
                  menuIndex < menus.count else {
                print("메뉴 인덱스 범위 초과: \(menuIndex)")
                return
            }
            
            let menu = menus[menuIndex]
            reviewMenuTypeInfo.menuType = "VARIABLE"
            reviewMenuTypeInfo.menuID = menu.mealId ?? 0
            reviewMenuTypeInfo.changeMenuIDList = menu.briefMenus.compactMap(\.menuId)
            
        } else {
            if !isSelectable { return }
            
            guard let menus = fixMenuTableViewData[restaurant],
                  menuIndex < menus.count else {
                print("간식 메뉴 인덱스 범위 초과: \(menuIndex)")
                return
            }
            
            reviewMenuTypeInfo.menuType = "FIXED"
            reviewMenuTypeInfo.menuID = menus[menuIndex].menuId
            reviewMenuTypeInfo.changeMenuIDList = nil
        }

//        let reviewViewController = ReviewViewController()
//        delegate = reviewViewController
//        navigationController?.pushViewController(reviewViewController, animated: true)
//        delegate?.didDelegateReviewMenuTypeInfo(for: reviewMenuTypeInfo)
        
        let reviewViewController = ReviewViewController()

        // 상위 부모에서 CustomTabBarContainerController 찾기
        var parentVC = self.parent
        while parentVC != nil {
            if let customTabBar = parentVC as? CustomTabBarContainerController {
                customTabBar.setTabBarHidden(true, animated: false)
                break
            }
            parentVC = parentVC?.parent
        }

        // delegate 연결
        delegate = reviewViewController
        delegate?.didDelegateReviewMenuTypeInfo(for: reviewMenuTypeInfo)

        // push로 띄우기
        navigationController?.pushViewController(reviewViewController, animated: true)
    }
    
    private func presentLoginAlert() {
        let alert = UIAlertController(title: "로그인이 필요한 서비스입니다",
                                      message: "로그인 하시겠습니까?",
                                      preferredStyle: .alert)
        let confirm = UIAlertAction(title: "확인", style: .default) { _ in
            let loginVC = LoginViewController()
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
                window.replaceRootViewController(loginVC)
            }
        }
        alert.addAction(confirm)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        present(alert, animated: true)
    }

    // 섹션 헤더 뷰 설정
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(
            withIdentifier: RestaurantTableViewHeader.identifier
        ) as? RestaurantTableViewHeader else {
            return nil
        }

        let restaurantName = sectionHeaderRestaurant[section]
        header.titleLabel.text = restaurantName

        if let info = RestaurantInfoData.restaurantInfoData.first(where: { $0.name == restaurantName }) {
            var container = AttributeContainer()
            container.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 10)
            header.infoButton.configuration?.attributedTitle = AttributedString(info.location, attributes: container)
        }

        // 재사용 헤더의 이전 액션 제거
        header.infoButton.removeAction(identifiedBy: Self.infoActionID, for: .touchUpInside)

        // 다시 액션 등록
        header.infoButton.addAction(
            UIAction(title: "", image: nil, identifier: Self.infoActionID, handler: { [weak self] _ in
                guard let self else { return }
                // firebase - click_restaurant_info 이벤트 호출
                HomeAnalyticsManager.shared.logClickRestaurantInfo(restaurantName: restaurantName)
                let vc = RestaurantInfoViewController()
                vc.modalPresentationStyle = .pageSheet
                vc.sheetPresentationController?.prefersGrabberVisible = true

                self.infoDelegate = vc
                self.infoDelegate?.didTappedRestaurantInfo(restaurantName: restaurantName)
                self.present(vc, animated: true)
            }),
            for: .touchUpInside
        )

        return header
    }
}

// MARK: - UITableViewDelegate

extension HomeRestaurantViewController: UITableViewDelegate {
    // 헤더 높이 설정
    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        headerHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // didSelectRowAt은 사용하지 않으므로, 기존 로직은 handleMenuTap으로 이동.
    }
}

// MARK: - Network

extension HomeRestaurantViewController {
    // 변경 메뉴 요청 API 호출
    func fetchChangeMenuData(date: String, restaurant: String, time: String) async {
        
        // UI 업데이트에 사용할 메뉴 목록과 애니메이션 타입을 저장할 변수
        let menusToUpdate: [ChangeMenuTableResponse]
        let animation: UITableView.RowAnimation
        
        do {
            // 비동기 네트워크 요청을 통해 메뉴 데이터 가져오기
            let menus: [ChangeMenuTableResponse] = try await withCheckedThrowingContinuation { continuation in
                NetworkService.shared.request(
                    HomeRouter.getChangeMenuTableResponse(date: date, restaurant: restaurant, time: time),
                    responseType: [ChangeMenuTableResponse].self
                ) { result in
                    continuation.resume(with: result)
                }
            }
            
            menusToUpdate = menus.filter { !($0.briefMenus.first?.name.isEmpty ?? true) }
            animation = .fade
            
        } catch {
            print("\(restaurant) 변경 메뉴 조회 실패: \(error.localizedDescription)")
            menusToUpdate = []
            animation = .none
        }
        
        // 메인 스레드에서 UI 업데이트
        await MainActor.run {
            self.changeMenuTableViewData[restaurant] = menusToUpdate
            
            if let sectionIndex = self.getSectionIndex(for: restaurant) {
                self.restaurantView.restaurantTableView.reloadSections(IndexSet(integer: sectionIndex), with: animation)
            }
        }
    }

    // 고정 메뉴 요청 API 호출
    func fetchFixedMenuData(restaurant: String) async {
        var menuData: [Menus] = []
        var animation: UITableView.RowAnimation = .none

        do {
            let response: FixedMenuTableResponse = try await withCheckedThrowingContinuation { continuation in
                NetworkService.shared.request(
                    HomeRouter.getFixedMenuTableResponse(restaurant: restaurant),
                    responseType: FixedMenuTableResponse.self
                ) { result in
                    continuation.resume(with: result)
                }
            }
            
            menuData = response.categoryMenuListCollection.flatMap { $0.menus }
            animation = .fade
        } catch {
            print("\(restaurant) 고정 메뉴 조회 실패: \(error.localizedDescription)")
        }
        
        // 메인 스레드에서 UI 업데이트
        await MainActor.run {
            self.fixMenuTableViewData[restaurant] = menuData
            if let sectionIndex = self.getSectionIndex(for: restaurant) {
                self.restaurantView.restaurantTableView.reloadSections(IndexSet(integer: sectionIndex), with: animation)
            }
        }
    }
}
