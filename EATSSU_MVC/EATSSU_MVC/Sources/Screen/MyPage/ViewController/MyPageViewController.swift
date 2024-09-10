//
//  File.swift
//  EatSSU-iOS
//
//  Created by 최지우 on 2023/05/22.
//

// Swift Module
import Foundation
import WebKit

// External Module
import FirebaseAnalytics
import SnapKit
import UIKit
import Moya
import Realm

final class MyPageViewController: BaseViewController {
    
    // MARK: - Properties
    
    private let myProvider = MoyaProvider<MyRouter>(plugins: [MoyaLoggingPlugin()])
    private var nickName = String()
    
    // MARK: - UI Components
    
    let mypageView = MyPageView()
    
    // MARK: - Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegate()
        Analytics.logEvent("MypageViewControllerLoad", parameters: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getMyInfo()
    }
    
    // MARK: - Functions
    
    override func setCustomNavigationBar() {
        super.setCustomNavigationBar()
        navigationItem.title = TextLiteral.myPage
    }
    
    override func configureUI() {
        view.addSubviews(mypageView)
    }
    
    override func setLayout() {
        mypageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    override func setButtonEvent() {
        mypageView.userNicknameButton.addTarget(self, action: #selector(didTappedChangeNicknameButton), for: .touchUpInside)
    }
    
    @objc
    func didTappedChangeNicknameButton() {
        
        let setNickNameVC = SetNickNameViewController()
        self.navigationController?.pushViewController(setNickNameVC, animated: true)
    }
    
    func setDelegate() {
        mypageView.myPageTableView.dataSource = self
        mypageView.myPageTableView.delegate = self
    }
    
    private func showAlert() {
        let alert = UIAlertController(title: "로그아웃",
                                      message: "정말 로그아웃 하시겠습니까?",
                                      preferredStyle: UIAlertController.Style.alert
        )
        
        let cancelAction = UIAlertAction(title: "취소하기",
                                         style: .default,
                                         handler: nil)
        
        let fixAction = UIAlertAction(title: "로그아웃",
                                      style: .default,
                                      handler: { okAction in
            RealmService.shared.resetDB()
          
            let loginViewController = LoginViewController()
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
              keyWindow.replaceRootViewController(UINavigationController(rootViewController: loginViewController))
            }
        })
        
        alert.addAction(cancelAction)
        alert.addAction(fixAction)

        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Server

extension MyPageViewController {
    private func getMyInfo() {
        self.myProvider.request(.myInfo) { response in
            switch response {
            case .success(let moyaResponse):
                do {
                    let responseData = try moyaResponse.map(BaseResponse<MyInfoResponse>.self)
                    self.mypageView.dataBind(model: responseData.result)
                    self.nickName = responseData.result.nickname ?? ""
                } catch(let err) {
                    print(err.localizedDescription)
                }
            case .failure(let err):
                print(err.localizedDescription)
            }
        }
    }
}

// MARK: - TableView DataSource

extension MyPageViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mypageView.myPageServiceLabelList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MyPageServiceCell.identifier,
                                                       for: indexPath)
                as? MyPageServiceCell else {
            return MyPageServiceCell()
        }

        let title = mypageView.myPageServiceLabelList[indexPath.row].titleLabel
        cell.serviceLabel.text = title
        if title == TextLiteral.myReview || title == TextLiteral.termsOfUse || title == TextLiteral.privacyTermsOfUse || title == TextLiteral.inquiry {
            cell.rightItemLabel.text = mypageView.myPageRightItemListDate[0].rightArrow
        } else if title == TextLiteral.appVersion {
            cell.rightItemLabel.text = mypageView.myPageRightItemListDate[0].appVersion
            cell.selectionStyle = .none
        }
        return cell
    }
}

// MARK: - UITableView Delegate

extension MyPageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row == 0 {
            let myReviewViewController = MyReviewViewController()
            self.navigationController?.pushViewController(myReviewViewController, animated: true)
        } else if indexPath.row == 1 {
          if let kakaoChannelLink = URL(string: "http://pf.kakao.com/_ZlVAn") {
            UIApplication.shared.open(kakaoChannelLink)
          } else {
            showAlertController(title: "다시 시도하세요", message: "에러가 발생했습니다", style: .default)
          }
          // 서비스 이용약관
        } else if indexPath.row == 2 {
          let provisionViewController = ProvisionViewController(agreementType: .termsOfService)
            provisionViewController.navigationTitle = TextLiteral.termsOfUse
            self.navigationController?.pushViewController(provisionViewController, animated: true)
          // 개인정보처리방침
        } else if indexPath.row == 3 {
          let provisionViewController = ProvisionViewController(agreementType: .privacyPolicy)
            provisionViewController.navigationTitle = TextLiteral.privacyTermsOfUse
            self.navigationController?.pushViewController(provisionViewController, animated: true)
        } else if indexPath.row == 4 {
            showAlert()
        } else if indexPath.row == 5 {
            let userWithdrawViewController = UserWithdrawViewController()
            userWithdrawViewController.getUsernickName(nickName: self.nickName)
            self.navigationController?.pushViewController(userWithdrawViewController, animated: true)
        } else {
            return
        }
    }
}
