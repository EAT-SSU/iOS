//
//  CreatorViewController.swift
//  EATSSU
//
//  Created by Jiwoong CHOI on 9/11/24.
//

// Swift Module
import UIKit

// External Module
import SnapKit

class CreatorViewController: BaseViewController {
  
	// MARK: - Properties

	// View Properties
	private let creatorsView = CreatorsView()
  
	// MARK: - View Life Cycle
  
	override func viewDidLoad() {
		super.viewDidLoad()
	}
  
	// MARK: - Methods
  
	override func configureUI() {
		view.addSubview(creatorsView)
	}
	
	override func setLayout() {
		creatorsView.snp.makeConstraints { make in
			make.top.equalToSuperview().inset(103)
			make.leading.trailing.equalToSuperview().inset(24)
			make.bottom.equalToSuperview().inset(52)
		}
	}

	override func setCustomNavigationBar() {
		// TODO: setCustomNavigationBar에 파라미터로 title 값을 받아서 네비게이션 바를 설계하도록 변경
		super.setCustomNavigationBar()
		navigationItem.title = "만든 사람들"
	}
}
