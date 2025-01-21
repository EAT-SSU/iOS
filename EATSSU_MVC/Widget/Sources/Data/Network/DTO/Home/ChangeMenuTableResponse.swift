//
//  ChangeMenuTableResponse.swift
//  EATSSU
//
//  Edited by JIWOONG CHOI on 2024/01/21.
//

import Foundation

// TODO: App과 Widget에 동일한 코드가 중복으로 존재. 재사용할 수 있게 변경.

/// 개별 음식 메뉴에 대한 정보를 디코딩하는 DTO
///
/// 서버에서 전달받은 식사 정보를 포함하는 데이터 모델입니다.
///
/// # JSON 예제
/// ```json
/// {
///   "mealId": 123,
///   "price": 10000,
///   "rating": 4.5,
///   "briefMenus": [
///     { "menuId": 1, "name": "Bibimbap" },
///     { "menuId": 2, "name": "Kimchi Stew" }
///   ]
/// }
/// ```
///
/// # 사용 예제
/// ```swift
/// menuProvider.request(.getChangeMenuTableResponse(date: date, restaurant: restaurant, time: time)) { response in
///     switch response {
///     case let .success(responseData):
///         do {
///             self.currentRestaurant = restaurant
///             let responseDetailDto = try responseData.map(BaseResponse<[ChangeMenuTableResponse]>.self)
///             self.changeMenuTableViewData[restaurant] = responseDetailDto.result
///         } catch let err {
///             print(err.localizedDescription)
///         }
///     case let .failure(err):
///         print(err.localizedDescription)
///     }
///     completion()
/// }
/// ```
///
/// - Note:
///   - `mealId`, `price`, `rating` 값은 서버에서 제공되지 않을 수도 있으므로 옵셔널 처리되어야 합니다.
///   - API 응답은 `BaseResponse<[ChangeMenuTableResponse]>` 형태로 배열을 감싸서 제공됩니다.
///     따라서 네트워크 응답을 디코딩할 때 해당 형식을 고려해야 합니다.///
///
struct ChangeMenuTableResponse: Codable {
    
    /// 식사의 고유 ID (옵셔널)
    ///
    /// - 예시: `123`
    let mealId: Int?
    
    /// 식사의 가격 (KRW 기준, 옵셔널)
    ///
    /// - 예시: `10000`
    let price: Int?
    
    /// 식사의 평점 (5점 만점, 옵셔널)
    ///
    /// - 예시: `4.5`
    let rating: Double?
    
    /// 간단한 메뉴 목록
    ///
    /// 해당 식사에 포함된 간단한 메뉴 정보를 포함하는 배열입니다.
    let briefMenus: [BriefMenus]
}

/// 개별 메뉴 항목을 나타내는 모델
///
/// `ChangeMenuTableResponse`의 `briefMenus` 속성에서 사용됩니다.
///
/// # JSON 예제
/// ```json
/// {
///   "menuId": 1,
///   "name": "Bibimbap"
/// }
/// ```
struct BriefMenus: Codable {
    
    /// 개별 메뉴의 고유 ID
    ///
    /// - 예시: `1`
    let menuId: Int
    
    /// 메뉴의 이름
    ///
    /// - 예시: `"Bibimbap"`
    let name: String
}
