//
//  MainMapViewController+Network.swift
//  EATSSU
//
//  Created by 황상환 on 10/4/25.
//

import Foundation

// MARK: - Network Requests

extension MainMapViewController {
    
    func fetchPartnerships() {
        NetworkService.shared.request(
            PartnershipRouter.getAllPartnerships,
            responseType: [PartnershipDTO].self,
            useAuth: true
        ) { [weak self] result in
            switch result {
            case .success(let partnerships):
                self?.displayMarkers(partnerships)
                
            case .failure(let error):
                print("전체 제휴 조회 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchDepartmentAndUpdateButton(completion: (() -> Void)? = nil) {
        NetworkService.shared.request(
            MyRouter.getDepartment,
            responseType: GetDepartmentResponse.self,
            useAuth: true
        ) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let department):
                let departmentName = department.departmentName
                self.currentDepartmentName = departmentName
                self.currentDepartmentId = department.departmentId
                self.currentCollegeId = department.collegeId

                let buttonTitle = departmentName.isEmpty ? TextLiteral.Map.myPartner : departmentName
                self.root.myOnlyButton.setTitle(buttonTitle, for: .normal)

                // Realm 데이터도 함께 동기화하여 서버-클라이언트 불일치 방지
                if let userInfo = UserInfoManager.shared.getCurrentUserInfo() {
                    UserInfoManager.shared.updateDepartment(
                        for: userInfo,
                        collegeId: department.collegeId,
                        collegeName: department.collegeName,
                        departmentId: department.departmentId,
                        departmentName: department.departmentName
                    )
                }

            case .failure(let error):
                print("학과 조회 실패: \(error.localizedDescription)")
                self.currentDepartmentName = nil
                self.currentDepartmentId = nil
                self.currentCollegeId = nil
                self.root.myOnlyButton.setTitle(TextLiteral.Map.myPartner, for: .normal)

                // Realm 데이터도 함께 동기화하여 서버-클라이언트 불일치 방지
                if let userInfo = UserInfoManager.shared.getCurrentUserInfo() {
                    UserInfoManager.shared.updateDepartment(
                        for: userInfo,
                        collegeId: nil,
                        collegeName: nil,
                        departmentId: nil,
                        departmentName: nil
                    )
                }
            }

            completion?()
        }
    }
    
    func fetchMyPartnerships() {
        // 학과 정보가 없으면 API 호출하지 않음 (서버 에러 방지)
        guard let departmentName = currentDepartmentName,
              !departmentName.isEmpty else {
            print("학과 정보가 없어 학과별 제휴 조회를 건너뜁니다")
            displayMarkers([])
            return
        }

        NetworkService.shared.request(
            MyRouter.getMyPartnerships,
            responseType: [PartnershipDTO].self,
            useAuth: true
        ) { [weak self] result in
            switch result {
            case .success(let partnerships):
                self?.displayMarkers(partnerships)

            case .failure(let error):
                print("내 제휴 조회 실패: \(error.localizedDescription)")
                self?.displayMarkers([])
            }
        }
    }
}
