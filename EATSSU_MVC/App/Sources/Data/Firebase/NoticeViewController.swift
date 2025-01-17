//
//  NoticeViewController.swift
//  EAT-SSU
//
//  Created by 최지우 on 3/6/24.
//

import UIKit

import SnapKit

/// FirebaseRemoteConfig 관련 ViewController
class NoticeViewController: BaseViewController {
    // MARK: - Properties

    var noticeMessage: String

    // MARK: - UI Components

    let backgroundImage = UIImageView(image: ImageLiteral.splashLogo)

    // MARK: - Life Cycles

    init(noticeMessage: String) {
        self.noticeMessage = noticeMessage
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        showNoticeAlert()
    }

    // MARK: - Functions

    override func configureUI() {
        view.addSubview(backgroundImage)
    }

    override func setLayout() {
        backgroundImage.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func showNoticeAlert() {
        let alert = UIAlertController(title: "NOTICE",
                                      message: noticeMessage,
                                      preferredStyle: UIAlertController.Style.alert)

        let action = UIAlertAction(title: "확인", style: .default, handler: { _ in
            self.quitService()
        })
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    private func quitService() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
}
