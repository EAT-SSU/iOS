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
                
                let buttonTitle = departmentName.isEmpty ? "내 제휴" : departmentName
                self.root.myOnlyButton.setTitle(buttonTitle, for: .normal)
                
            case .failure(let error):
                print("학과 조회 실패: \(error.localizedDescription)")
                self.currentDepartmentName = nil
                self.currentDepartmentId = nil
                self.currentCollegeId = nil
                self.root.myOnlyButton.setTitle("내 제휴", for: .normal)
            }
            
            completion?()
        }
    }
    
    func fetchMyPartnerships() {
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
            }
        }
    }
}
