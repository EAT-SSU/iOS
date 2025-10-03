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
        partnershipProvider.request(.getAllPartnerships) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try response.map(BaseResponse<[PartnershipDTO]>.self)
                    guard let partnerships = decoded.result else { return }
                    self?.displayMarkers(partnerships)
                } catch {
                    print("전체 제휴 디코딩 실패: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("전체 제휴 네트워크 오류: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchDepartmentAndUpdateButton() {
        myProvider.request(.getDepartment) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try response.map(BaseResponse<GetDepartmentResponse>.self)
                    let departmentName = decoded.result?.departmentName ?? ""
                    self?.currentDepartmentName = departmentName
                    self?.currentDepartmentId = decoded.result?.departmentId
                    self?.currentCollegeId = decoded.result?.collegeId
                    let buttonTitle = departmentName.isEmpty ? "내 제휴" : departmentName
                    self?.root.myOnlyButton.setTitle(buttonTitle, for: .normal)
                } catch {
                    print("학과 디코딩 실패: \(error)")
                    self?.currentDepartmentName = nil
                    self?.currentDepartmentId = nil
                    self?.currentCollegeId = nil
                    self?.root.myOnlyButton.setTitle("내 제휴", for: .normal)
                }
            case .failure(let error):
                print("학과 API 실패: \(error)")
                self?.currentDepartmentName = nil
                self?.currentDepartmentId = nil
                self?.currentCollegeId = nil
                self?.root.myOnlyButton.setTitle("내 제휴", for: .normal)
            }
        }
    }
    
    func fetchMyPartnerships() {
        myProvider.request(.getMyPartnerships) { [weak self] result in
            switch result {
            case .success(let response):
                do {
                    let decoded = try response.map(BaseResponse<[PartnershipDTO]>.self)
                    guard let partnerships = decoded.result else { return }
                    self?.displayMarkers(partnerships)
                } catch {
                    print("내 제휴 디코딩 실패: \(error)")
                }
            case .failure(let error):
                print("내 제휴 네트워크 오류: \(error)")
            }
        }
    }
}
