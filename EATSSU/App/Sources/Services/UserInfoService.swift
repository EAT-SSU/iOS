//
//  UserInfoService.swift
//  EATSSU
//
//  Created by 황상환 on 8/6/25.
//

import Foundation
import Moya
import RealmSwift

final class UserInfoService {
    static let shared = UserInfoService()

    private let provider = MoyaProvider<MyRouter>(session: Session(interceptor: AuthInterceptor.shared))

    private init() {}

    /// 서버에서 유저 정보를 조회하고, nickname이 있으면 UserInfoManager에 저장
    func fetchAndUpdateUserInfo(completion: (() -> Void)? = nil) {
        print("[UserInfoService] 유저 정보 조회 시작")

        provider.request(.myInfo) { result in
            switch result {
            case let .success(response):
                do {
                    let responseData = try response.map(BaseResponse<MyInfoResponse>.self)
                    guard let data = responseData.result else {
                        print("[UserInfoService] result가 nil임")
                        return
                    }

                    if let nickname = data.nickname {
                        print("[UserInfoService] 닉네임: \(nickname)")

                        if let _ = UserInfoManager.shared.getCurrentUserInfo() {
                            DispatchQueue.global(qos: .userInitiated).async {
                                autoreleasepool {
                                    let realm = try! Realm()
                                    guard let user = realm.objects(UserInfo.self).first else {
                                        print("[UserInfoService] 백그라운드에서 user 조회 실패")
                                        return
                                    }

                                    try! realm.write {
                                        user.nickname = nickname
                                    }

                                    print("[UserInfoService] 닉네임 업데이트 완료 (Realm 백그라운드)")
                                }
                            }
                        } else {
                            print("[UserInfoService] currentUserInfo가 nil임")
                        }
                    } else {
                        print("[UserInfoService] 닉네임이 없음 → 설정이 필요한 유저")
                    }

                    completion?()
                } catch {
                    print("[UserInfoService] 디코딩 실패: \(error.localizedDescription)")
                }

            case let .failure(error):
                print("[UserInfoService] 요청 실패: \(error.localizedDescription)")
            }
        }
    }
}
