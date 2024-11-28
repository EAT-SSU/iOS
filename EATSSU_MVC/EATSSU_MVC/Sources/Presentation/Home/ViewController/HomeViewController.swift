//
//  HomeViewController.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/08/08.
//
import UIKit

import FirebaseAnalytics
import Moya
import SnapKit

final class HomeViewController: BaseViewController {
    
    // MARK: - Properties
            
    var currentDate: Date = Date() {
        didSet {
            print("Changed Date: \(currentDate)")
        }
    }
    
    // MARK: - UI Components
    
    let tabmanController = HomeTimeTabmanController()
    let homeCalendarView = HomeCalendarView()
        
    //MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        homeCalendarView.delegate = tabmanController
        
        registerTabman()
        setnavigation()
        configureUI()
        setLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setFirebaseTask()
    }
    
    // MARK: - Functions
    
    override func configureUI() {
        view.addSubviews(homeCalendarView)
    }

    override func setLayout() {
        homeCalendarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(80)
        }
    }
    
    private func setFirebaseTask() {
        FirebaseRemoteConfig.shared.fetchRestaurantInfo()
        
#if DEBUG
#else
        Analytics.logEvent("HomeViewControllerLoad", parameters: nil)
#endif
    }
    
    private func setnavigation() {
        navigationItem.titleView = UIImageView(image: EATSSUAsset.Images.Version2.mainLogoSmall.image)
        
        let rightButton = UIBarButtonItem(
            // FIXME: myPageIcon은 Version 1 소속 이미지 파일입니다. 앞으로도 사용한다면 Version 2로 옮겨주세요.
            image: EATSSUAsset.Images.Version1.myPageIcon.image,
            style: .plain, target: self,
            action: #selector(rightBarButtonTapped))
        navigationItem.rightBarButtonItem = rightButton
        navigationItem.rightBarButtonItem?.tintColor = EATSSUAsset.Color.Main.primary.color
        
        navigationController?.isNavigationBarHidden = false
    }
    
    private func registerTabman() {
        
        // 자식 뷰 컨트롤러로 추가
        addChild(tabmanController)
        
        // 자식 뷰를 부모 뷰에 추가
        view.addSubview(tabmanController.view)
        
        // tabman 레이아웃 설정
        tabmanController.view.snp.makeConstraints {
            $0.top.equalTo(homeCalendarView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        // 자식 뷰 컨트롤러로서의 위치를 확정
        tabmanController.didMove(toParent: self)
    }
    
    @objc
    private func rightBarButtonTapped() {
        /// 로그인 되어있는 경우
        if RealmService.shared.isAccessTokenPresent() {
            let nextVC = MyPageViewController()
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
        /// 로그인 되어있지 않은 경우
        else {
            let loginPromptVC = LoginPromptViewController()
            loginPromptVC.modalPresentationStyle = .pageSheet
            
            // Check if iOS 16+
            if #available(iOS 16.0, *) {
                if let sheet = loginPromptVC.sheetPresentationController {
                    let small = UISheetPresentationController.Detent.Identifier("small")
                    sheet.detents = [
                        .custom(identifier: small) { context in
                            0.34 * context.maximumDetentValue
                        }
                    ]
                    
                    sheet.prefersScrollingExpandsWhenScrolledToEdge = false
                    sheet.preferredCornerRadius = 30
                }
                present(loginPromptVC, animated: true, completion: nil)
            }

//            showAlertControllerWithCancel(title: "로그인이 필요한 서비스입니다", message: "로그인 하시겠습니까?", confirmStyle: .default) {
//                self.changeIntoLoginViewController()
//            }
            
        }
    }
    
    private func changeIntoLoginViewController() {
      let loginViewController = LoginViewController()
     
      guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let sceneDelegate = windowScene.delegate as? SceneDelegate,
            let window = sceneDelegate.window else {
                  return
        }
      
      window.replaceRootViewController(loginViewController)
      
      /*
       해야 할 일
       - 아래의 더 쉬운 방법이 있는데, window 클래스의 커스텀 메소드 중 replaceRootViewController를 사용할 필요가 있을까?
       
      UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
        window.rootViewController = loginViewController
      }
       */
      
    }
}

// MARK: Calendar Selection
extension HomeViewController: CalendarSeletionDelegate {
    func didSelectCalendar(date: Date) {
        self.currentDate = date
    }
}
