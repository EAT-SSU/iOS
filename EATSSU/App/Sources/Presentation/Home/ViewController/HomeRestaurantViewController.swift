//
//  HomeRestaurantViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/08.

import UIKit

import Moya
import SnapKit

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

    // 현재 보고 있는 식당 (섹션 reload 시 사용)
    var currentRestaurant = ""

    // 현재 요일이 주말인지 여부 판단
    var isWeekend = false

    // 셀 선택 가능 여부 (가격 유무에 따라 다름)
    var isSelectable = false

    // 변경 메뉴 데이터 (식당명: 메뉴 배열)
    var changeMenuTableViewData: [String: [ChangeMenuTableResponse]] = [:] {
        didSet {
            // 메뉴 이름이 빈 값이 아닌 데이터만 필터링
            changeMenuTableViewData = changeMenuTableViewData.mapValues { menuTableResponses in
                menuTableResponses.filter { response in
                    !(response.briefMenus.first?.name.isEmpty ?? true)
                }
            }

            // 현재 섹션만 reload
            if let sectionIndex = getSectionIndex(for: currentRestaurant) {
                restaurantView.restaurantTableView.reloadSections([sectionIndex], with: .automatic)
            }
        }
    }

    // 고정 메뉴 데이터 (간식코너)
    var fixMenuTableViewData: [String: [Menus]] = [:] {
        didSet {
            if let sectionIndex = getSectionIndex(for: currentRestaurant) {
                restaurantView.restaurantTableView.reloadSections([sectionIndex], with: .automatic)
            }
        }
    }

    // 메뉴 API 요청을 위한 Moya Provider
    let menuProvider = MoyaProvider<HomeRouter>(plugins: [ESMoyaLoggingPlugin()])

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
        let formatDate = changeDateFormat(date: date)

        // 변경 메뉴 일괄 요청(스낵 제외, UI 순서대로)
        changeRestaurantIDs.forEach { id in
            getChageMenuData(date: formatDate, restaurant: id, time: time) {}
        }

        let weekday = Weekday.from(date: date)
        isWeekend = weekday.isWeekend

        if time == TextLiteral.lunchRawValue {
            // 학기 중 평일 점심에만 스낵 고정 메뉴 요청
            if !FirebaseRemoteConfig.shared.isVacationPeriod, !weekday.isWeekend {
                isSelectable = true
                getFixMenuData(restaurant: Restaurant.snackCorner.identifier) {}
            } else {
                // 방학/주말 더미
                currentRestaurant = Restaurant.snackCorner.identifier
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
        let isSnackCorner = (restaurant == Restaurant.snackCorner.identifier)

        var reviewMenuTypeInfo = ReviewMenuTypeInfo(menuType: "", menuID: 0)

        if !isSnackCorner {
            reviewMenuTypeInfo.menuType = "VARIABLE"
            reviewMenuTypeInfo.menuID = changeMenuTableViewData[restaurant]?[menuIndex].mealId ?? 100
            if let list = changeMenuTableViewData[restaurant]?[menuIndex].briefMenus {
                reviewMenuTypeInfo.changeMenuIDList = list.compactMap(\.menuId)
            }
        } else {
            if !isSelectable { return }
            reviewMenuTypeInfo.menuType = "FIXED"
            reviewMenuTypeInfo.menuID = fixMenuTableViewData[restaurant]?[menuIndex].menuId ?? 100
        }

        let reviewViewController = ReviewViewController()
        delegate = reviewViewController
        navigationController?.pushViewController(reviewViewController, animated: true)
        delegate?.didDelegateReviewMenuTypeInfo(for: reviewMenuTypeInfo)
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

    // 셀 선택 시 리뷰 작성 화면으로 이동
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // 타이틀 셀 선택 시 무시
        if indexPath.row == 0 {
            return
        }

        let restaurant = getSectionKey(for: indexPath.section)
        var reviewMenuTypeInfo = ReviewMenuTypeInfo(menuType: "", menuID: 0)

        // 변경 메뉴인 경우 데이터 구성
        if [0, 1, 2].contains(indexPath.section) {
            reviewMenuTypeInfo.menuType = "VARIABLE"
            reviewMenuTypeInfo.menuID = changeMenuTableViewData[restaurant]?[indexPath.row - restaurantTableViewMenuTitleCellCount].mealId ?? 100
            if let list = changeMenuTableViewData[restaurant]?[indexPath.row - restaurantTableViewMenuTitleCellCount].briefMenus {
                reviewMenuTypeInfo.changeMenuIDList = list.compactMap(\ .menuId)
            }
        }
        // 고정 메뉴인 경우
        else if [3, 4, 5].contains(indexPath.section) {
            if !isSelectable {
                return
            }
            reviewMenuTypeInfo.menuType = "FIXED"
            reviewMenuTypeInfo.menuID = fixMenuTableViewData[restaurant]?[indexPath.row - restaurantTableViewMenuTitleCellCount].menuId ?? 100
        }

        // 리뷰 작성 화면으로 Push
        let reviewViewController = ReviewViewController()
        delegate = reviewViewController
        navigationController?.pushViewController(reviewViewController, animated: true)
        delegate?.didDelegateReviewMenuTypeInfo(for: reviewMenuTypeInfo)
    }
}

// MARK: - Network

extension HomeRestaurantViewController {
    // 변경 메뉴 요청 API 호출
    func getChageMenuData(date: String, restaurant: String, time: String, completion: @escaping () -> Void) {
        menuProvider.request(.getChangeMenuTableResponse(date: date, restaurant: restaurant, time: time)) { response in
            switch response {
            case let .success(responseData):
                do {
                    self.currentRestaurant = restaurant
                    let responseDetailDto = try responseData.map(BaseResponse<[ChangeMenuTableResponse]>.self)
                    self.changeMenuTableViewData[restaurant] = responseDetailDto.result
                } catch let err {
                    print(err.localizedDescription)
                }
            case let .failure(err):
                print(err.localizedDescription)
            }
            completion()
        }
    }

    // 고정 메뉴 요청 API 호출
    func getFixMenuData(restaurant: String, completion: @escaping () -> Void) {
        menuProvider.request(.getFixedMenuTableResponse(restaurant: restaurant)) { response in
            switch response {
            case let .success(responseData):
                do {
                    self.currentRestaurant = restaurant
                    let responseDetailDto = try responseData.map(BaseResponse<FixedMenuTableResponse>.self)
                    guard let responseResult = responseDetailDto.result else { return }

                    var allMenuInformations = [Menus]()
                    for categoryMenu in responseResult.categoryMenuListCollection {
                        allMenuInformations += categoryMenu.menus
                    }
                    self.fixMenuTableViewData[restaurant] = allMenuInformations
                } catch let err {
                    print(err.localizedDescription)
                }
            case let .failure(err):
                print(err.localizedDescription)
            }
            completion()
        }
    }
}
