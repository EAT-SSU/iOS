//
//  MainReviewView.swift
//  EATSSU-DEV
//
//  Created by 최지우 on 1/30/25.
//

import UIKit
import SnapKit

import EATSSUDesign

final class MainReviewView: BaseUIView {
    
    // MARK: - Properties
  

    
    // MARK: - UI Components
    
    private let menuChipHorizontalScrollView = MenuChipHorizontalScrollView()
    
    /// 사용자 정보
    private let profileImageView: UIImageView = {
        let imageView = UIImageView(image: EATSSUDesignAsset.Images.profile.image)
        return imageView
    }()
    
    /// 리뷰 리스트
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = 150
        tableView.backgroundColor = .yellow
        return tableView
    }()
    
    
    
    // MARK: - Functions
    
    override func configureUI() {
        addSubview(
            tableView
        )
    }
    
    override func setLayout() {
        self.tableView.snp.makeConstraints {
          $0.edges.equalTo(self.safeAreaLayoutGuide)
        }
//        profileImageView.snp.makeConstraints { make in
//            make.top.leading.equalToSuperview()
//        }
//        menuChipHorizontalScrollView.snp.makeConstraints { make in
//            make.horizontalEdges.equalToSuperview()
//            make.top.equalToSuperview().offset(100)
//            
//        }
    }
    
    private func insertMenuData() {
        menuChipHorizontalScrollView.menuDataSource = ["고구마치즈돈까스", "막국수", "요구르트","김치","고구마치즈돈까스", "막국수", "요구르트","김치"]
    }
    
}

#if DEBUG
import SwiftUI

struct Preview: PreviewProvider {
    static var previews: some View {
        MainReviewViewController().toPreview()
    }
}
#endif


