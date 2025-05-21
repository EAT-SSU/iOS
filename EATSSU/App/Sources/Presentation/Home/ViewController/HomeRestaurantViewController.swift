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
    private let sectionHeaderRestaurant = [TextLiteral.dormitoryRestaurant,
                                           TextLiteral.dodamRestaurant,
                                           TextLiteral.studentRestaurant,
                                           TextLiteral.snackCorner]

    // 버튼에 표시되는 타이틀을 백엔드 식당 이름으로 매핑
    let restaurantButtonTitleToName = [TextLiteral.dormitoryRestaurant: "DORMITORY",
                                       TextLiteral.dodamRestaurant: "DODAM",
                                       TextLiteral.studentRestaurant: "HAKSIK",
                                       TextLiteral.snackCorner: "SNACK_CORNER"]

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

    // 식당 이름을 통해 섹션 index 반환
    func getSectionIndex(for restaurant: String) -> Int? {
        let restaurantRawValue = [Restaurant.dormitoryRestaurant.identifier,
                                  Restaurant.dodamRestaurant.identifier,
                                  Restaurant.studentRestaurant.identifier,
                                  Restaurant.snackCorner.identifier]
        return restaurantRawValue.firstIndex(of: restaurant)
    }

    // 섹션 인덱스로 식당 이름 반환
    func getSectionKey(for section: Int) -> String {
        let restaurantRawValue = [Restaurant.dormitoryRestaurant.identifier,
                                  Restaurant.dodamRestaurant.identifier,
                                  Restaurant.studentRestaurant.identifier,
                                  Restaurant.snackCorner.identifier]
        return restaurantRawValue[section]
    }

    // 날짜와 시간에 따라 메뉴 데이터 fetch
    func fetchData(date: Date, time: String) {
        let formatDate = changeDateFormat(date: date)

        // 변경 메뉴 요청 (기숙사/도담/학생식당)
        getChageMenuData(date: formatDate, restaurant: Restaurant.dormitoryRestaurant.identifier, time: time) {}
        getChageMenuData(date: formatDate, restaurant: Restaurant.dodamRestaurant.identifier, time: time) {}
        getChageMenuData(date: formatDate, restaurant: Restaurant.studentRestaurant.identifier, time: time) {}

        let weekday = Weekday.from(date: date)
        isWeekend = weekday.isWeekend // 주말 여부 판단

        if time == TextLiteral.lunchRawValue {
            // 학기 중 평일 점심인 경우에만 간식코너 고정 메뉴 요청
            if !FirebaseRemoteConfig.shared.isVacationPeriod, !weekday.isWeekend {
                isSelectable = true
                getFixMenuData(restaurant: TextLiteral.snackCornerRawValue) {}
            } else {
                // 방학/주말에는 더미 고정 메뉴 설정
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
        let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantMenuGroupCell.identifier, for: indexPath) as! RestaurantMenuGroupCell
        let sectionKey = getSectionKey(for: indexPath.section)

        let menuList: [MenuTypeInfo]
        if indexPath.section == 3 {
            menuList = fixMenuTableViewData[sectionKey]?.map { .fix($0) } ?? []
        } else {
            menuList = changeMenuTableViewData[sectionKey]?.map { .change($0) } ?? []
        }

        cell.configure(with: menuList, at: indexPath) { [weak self] indexPath, menuIndex in
            self?.handleMenuTap(section: indexPath.section, menuIndex: menuIndex)
        }
        return cell
    }

    private func handleMenuTap(section: Int, menuIndex: Int) {
        let restaurant = getSectionKey(for: section)
        var reviewMenuTypeInfo = ReviewMenuTypeInfo(menuType: "", menuID: 0)

        if [0, 1, 2].contains(section) {
            reviewMenuTypeInfo.menuType = "VARIABLE"
            reviewMenuTypeInfo.menuID = changeMenuTableViewData[restaurant]?[menuIndex].mealId ?? 100
            if let list = changeMenuTableViewData[restaurant]?[menuIndex].briefMenus {
                reviewMenuTypeInfo.changeMenuIDList = list.compactMap(\.menuId)
            }
        } else if section == 3 {
            if !isSelectable { return }
            reviewMenuTypeInfo.menuType = "FIXED"
            reviewMenuTypeInfo.menuID = fixMenuTableViewData[restaurant]?[menuIndex].menuId ?? 100
        }

        let reviewViewController = ReviewViewController()
        delegate = reviewViewController
        navigationController?.pushViewController(reviewViewController, animated: true)
        delegate?.didDelegateReviewMenuTypeInfo(for: reviewMenuTypeInfo)
    }

    // 섹션 헤더 뷰 설정
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let restaurantTableViewHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: RestaurantTableViewHeader.identifier) as? RestaurantTableViewHeader else {
            return nil
        }

        let restaurantName = sectionHeaderRestaurant[section]
        restaurantTableViewHeader.titleLabel.text = restaurantName

        // 위치 정보도 함께 표시
        if let restaurantInfo = RestaurantInfoData.restaurantInfoData.first(where: { $0.name == restaurantName }) {
            var titleContainer = AttributeContainer()
            titleContainer.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 10)
            restaurantTableViewHeader.infoButton.configuration?.attributedTitle = AttributedString(restaurantInfo.location, attributes: titleContainer)
        }

        // infoButton 클릭 시 식당 정보 화면 modal present
        restaurantTableViewHeader.infoButton.addAction(UIAction { [weak self] _ in
            let restaurantInfoViewController = RestaurantInfoViewController()
            restaurantInfoViewController.modalPresentationStyle = .pageSheet
            restaurantInfoViewController.sheetPresentationController?.prefersGrabberVisible = true

            self?.infoDelegate = restaurantInfoViewController
            self?.infoDelegate?.didTappedRestaurantInfo(restaurantName: restaurantName)

            self?.present(restaurantInfoViewController, animated: true)

        }, for: .touchUpInside)

        return restaurantTableViewHeader
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
