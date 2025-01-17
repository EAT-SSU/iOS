//
//  HomeRestaurantViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/08.
//

import UIKit

import Moya
import SnapKit
import Then

protocol ReviewMenuTypeInfoDelegate: AnyObject {
    func didDelegateReviewMenuTypeInfo(for menuTypeData: ReviewMenuTypeInfo)
}

protocol RestaurantInfoDelegate: AnyObject {
    func didTappedRestaurantInfo(restaurantName: String)
}

final class HomeRestaurantViewController: BaseViewController {
    // MARK: - Properties

    private let restaurantTableViewMenuTitleCellCount = 1
    private let headerHeight: CGFloat = 48

    weak var infoDelegate: RestaurantInfoDelegate?
    var delegate: ReviewMenuTypeInfoDelegate?
    private let fixedDummy = FixedMenuInfoData.Dummy()
    private let sectionHeaderRestaurant = [TextLiteral.dormitoryRestaurant,
                                           TextLiteral.dodamRestaurant,
                                           TextLiteral.studentRestaurant,
                                           TextLiteral.snackCorner]
    let restaurantButtonTitleToName = [TextLiteral.dormitoryRestaurant: "DORMITORY",
                                       TextLiteral.dodamRestaurant: "DODAM",
                                       TextLiteral.studentRestaurant: "HAKSIK",
                                       TextLiteral.snackCorner: "SNACK_CORNER"]
    var currentRestaurant = ""
    var isWeekend = false
    var isSelectable = false

    var changeMenuTableViewData: [String: [ChangeMenuTableResponse]] = [:] {
        didSet {
            // 빈 name을 가지지 않은 ChangeMenuTableResponse만 필터링
            changeMenuTableViewData = changeMenuTableViewData.mapValues { menuTableResponses in
                menuTableResponses.filter { response in
                    !(response.briefMenus.first?.name.isEmpty ?? true)
                }
            }

            // 필터링된 데이터로 테이블 뷰 섹션을 새로고침
            if let sectionIndex = getSectionIndex(for: currentRestaurant) {
                restaurantView.restaurantTableView.reloadSections([sectionIndex], with: .automatic)
            }
        }
    }

    var fixMenuTableViewData: [String: [Menus]] = [:] {
        didSet {
            if let sectionIndex = getSectionIndex(for: currentRestaurant) {
                restaurantView.restaurantTableView.reloadSections([sectionIndex], with: .automatic)
            }
        }
    }

    let menuProvider = MoyaProvider<HomeRouter>(plugins: [MoyaLoggingPlugin()])

    // MARK: - UI Components

    let restaurantView = HomeRestaurantView()

    // MARK: - Life Cycles

    override func viewDidLoad() {
        super.viewDidLoad()

        setDelegate()
        setTableView()
    }

    // MARK: - Functions

    override func configureUI() {
        view.addSubviews(restaurantView)
    }

    override func setLayout() {
        restaurantView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    func setDelegate() {
        restaurantView.restaurantTableView.dataSource = self
        restaurantView.restaurantTableView.delegate = self
    }

    func setTableView() {
        restaurantView.restaurantTableView.register(RestaurantTableViewMenuTitleCell.self,
                                                    forCellReuseIdentifier: RestaurantTableViewMenuTitleCell.identifier)
        restaurantView.restaurantTableView.register(RestaurantTableViewMenuCell.self,
                                                    forCellReuseIdentifier: RestaurantTableViewMenuCell.identifier)
        restaurantView.restaurantTableView.register(RestaurantTableViewHeader.self,
                                                    forHeaderFooterViewReuseIdentifier: RestaurantTableViewHeader.identifier)
    }

    func getSectionIndex(for restaurant: String) -> Int? {
        let restaurantRawValue = [Restaurant.dormitoryRestaurant.identifier,
                                  Restaurant.dodamRestaurant.identifier,
                                  Restaurant.studentRestaurant.identifier,
                                  Restaurant.snackCorner.identifier]
        return restaurantRawValue.firstIndex(of: restaurant)
    }

    func getSectionKey(for section: Int) -> String {
        let restaurantRawValue = [Restaurant.dormitoryRestaurant.identifier,
                                  Restaurant.dodamRestaurant.identifier,
                                  Restaurant.studentRestaurant.identifier,
                                  Restaurant.snackCorner.identifier]
        return restaurantRawValue[section]
    }

    func fetchData(date: Date, time: String) {
        let formatDate = changeDateFormat(date: date)
        getChageMenuData(date: formatDate, restaurant: Restaurant.dormitoryRestaurant.identifier, time: time) {}
        getChageMenuData(date: formatDate, restaurant: Restaurant.dodamRestaurant.identifier, time: time) {}
        getChageMenuData(date: formatDate, restaurant: Restaurant.studentRestaurant.identifier, time: time) {}

        let weekday = Weekday.from(date: date)
        isWeekend = weekday.isWeekend

        if time == TextLiteral.lunchRawValue {
            if !FirebaseRemoteConfig.shared.isVacationPeriod && !weekday.isWeekend {
                getFixMenuData(restaurant: TextLiteral.snackCornerRawValue) {}
            } else {
                currentRestaurant = Restaurant.snackCorner.identifier
                fixMenuTableViewData[Restaurant.snackCorner.identifier] = [Menus(menuId: 0, name: "", price: nil, rating: nil)]
            }
        }
    }

    func changeDateFormat(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: date)
    }
}

// MARK: - UITableViewDataSource

extension HomeRestaurantViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return sectionHeaderRestaurant.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionKey = getSectionKey(for: section)

        if [0, 1, 2].contains(section) {
            return (changeMenuTableViewData[sectionKey]?.count ?? 0) + restaurantTableViewMenuTitleCellCount
        } else if [3, 4, 5].contains(section) {
            return (fixMenuTableViewData[sectionKey]?.count ?? 0) + restaurantTableViewMenuTitleCellCount
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// Menu Title Cell
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantTableViewMenuTitleCell.identifier, for: indexPath)
            cell.selectionStyle = .none
            return cell
        }

        /// Menu Cell
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantTableViewMenuCell.identifier, for: indexPath) as! RestaurantTableViewMenuCell

            // MARK: 섹션지정

            if indexPath.section == 0 {
                if let data = changeMenuTableViewData[TextLiteral.dormitoryRawValue]?[indexPath.row - restaurantTableViewMenuTitleCellCount] {
                    cell.model = .change(data)
                }
            } else if indexPath.section == 1 {
                if let data = changeMenuTableViewData[TextLiteral.dodamRawValue]?[indexPath.row - restaurantTableViewMenuTitleCellCount] {
                    cell.model = .change(data)
                }
            } else if indexPath.section == 2 {
                if let data = changeMenuTableViewData[TextLiteral.studentRestaurantRawValue]?[indexPath.row - restaurantTableViewMenuTitleCellCount] {
                    cell.model = .change(data)
                }
            } else if indexPath.section == 3 {
                if let data = fixMenuTableViewData[TextLiteral.snackCornerRawValue]?[indexPath.row - restaurantTableViewMenuTitleCellCount] {
                    if data.price != nil {
                        isSelectable = true
                        cell.selectionStyle = .default
                    } else {
                        isSelectable = false
                        cell.selectionStyle = .none
                    }
                    cell.model = .fix(data)
                }
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let restaurantTableViewHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: RestaurantTableViewHeader.identifier) as? RestaurantTableViewHeader else {
            return nil
        }

        let restaurantName = sectionHeaderRestaurant[section]
        restaurantTableViewHeader.titleLabel.text = restaurantName

        if let restaurantInfo = RestaurantInfoData.restaurantInfoData.first(where: { $0.name == restaurantName }) {
            var titleContainer = AttributeContainer()
            titleContainer.font = .caption3
            restaurantTableViewHeader.infoButton.configuration?.attributedTitle = AttributedString(restaurantInfo.location, attributes: titleContainer)
        }

        // Action for infoButton
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
    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        return headerHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row == 0 {
            return
        }

        let restaurant = getSectionKey(for: indexPath.section)
        /// bind Data
        var reviewMenuTypeInfo = ReviewMenuTypeInfo(menuType: "", menuID: 0)

        if [0, 1, 2].contains(indexPath.section) {
            reviewMenuTypeInfo.menuType = "VARIABLE"
            reviewMenuTypeInfo.menuID = changeMenuTableViewData[restaurant]?[indexPath.row - restaurantTableViewMenuTitleCellCount].mealId ?? 100
            if let list = changeMenuTableViewData[restaurant]?[indexPath.row - restaurantTableViewMenuTitleCellCount].briefMenus {
                reviewMenuTypeInfo.changeMenuIDList = list.compactMap { $0.menuId }
            }
        } else if [3, 4, 5].contains(indexPath.section) {
            if !isSelectable {
                return
            }
            reviewMenuTypeInfo.menuType = "FIXED"
            reviewMenuTypeInfo.menuID = fixMenuTableViewData[restaurant]?[indexPath.row - restaurantTableViewMenuTitleCellCount].menuId ?? 100
        }

        /// push VC
        let reviewViewController = ReviewViewController()
        delegate = reviewViewController
        navigationController?.pushViewController(reviewViewController, animated: true)

        delegate?.didDelegateReviewMenuTypeInfo(for: reviewMenuTypeInfo)
    }
}

// MARK: - Network

extension HomeRestaurantViewController {
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

    func getFixMenuData(restaurant: String, completion: @escaping () -> Void) {
        menuProvider.request(.getFixedMenuTableResponse(restaurant: restaurant)) { response in
            switch response {
            case let .success(responseData):
                do {
                    self.currentRestaurant = restaurant
                    let responseDetailDto = try responseData.map(BaseResponse<FixedMenuTableResponse>.self)
                    let responseResult = responseDetailDto.result

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
