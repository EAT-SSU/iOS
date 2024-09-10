//
//  BaseViewController.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/03/15.
//

import UIKit

import Moya
import SnapKit

class BaseViewController: UIViewController {
    
    // MARK: - Properties
    
    lazy private(set) var className: String = {
      return type(of: self).description().components(separatedBy: ".").last ?? ""
    }()
    
    // MARK: - Initializing
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("DEINIT: \(className)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setCustomNavigationBar()
        configureUI()
        setLayout()
        setButtonEvent()
        view.backgroundColor = .systemBackground

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !NetworkMonitor.shared.isConnected {
            print("네트워크오류")
            self.showAlertController(title: "오류", message: "네트워크를 확인해주세요", style: .destructive)

        }
    }
    
    //MARK: - Functions
    
    func configureUI() {
        //override Point

    }
    
    func setLayout() {
        //override Point
    }
    
    func setButtonEvent() {
        //override Point
    }
    
    func setCustomNavigationBar() {
      
      // 네비게이션 바 타이틀 속성
        navigationController?.navigationBar.titleTextAttributes = [
          .foregroundColor: EATSSUAsset.Color.GrayScale.gray700.color,
          NSAttributedString.Key.font: EATSSUFontFamily.Pretendard.bold.font(size: 16)
        ]
      
      // 네비게이션 바 백버튼 속성
        let backButton = UIBarButtonItem()
      backButton.tintColor = EATSSUAsset.Color.GrayScale.gray500.color
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
}


