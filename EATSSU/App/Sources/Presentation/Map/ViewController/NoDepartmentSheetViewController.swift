//
//  NoDepartmentSheetViewController.swift
//  EATSSU
//
//  Created by 황상환 on 7/15/25.
//

import UIKit

import SnapKit

import EATSSUDesign

final class NoDepartmentSheetViewController: BaseViewController {

    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = TextLiteral.Map.inputDepartment
        label.numberOfLines = 2
        label.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 18)
        label.textColor = .label
        return label
    }()

    private let logoImageView = UIImageView(image: EATSSUDesignAsset.Images.authLogo.image)
    private let subTitleImageView = UIImageView(image: EATSSUDesignAsset.Images.authSubTitle.image)

    private lazy var logoStackView: UIStackView = {
        logoImageView.contentMode = .scaleAspectFit
        subTitleImageView.contentMode = .scaleAspectFit
        subTitleImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        let stack = UIStackView(arrangedSubviews: [logoImageView, subTitleImageView])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        return stack
    }()

    private let inputButton: ESButton = {
        let button = ESButton(size: .big, title: TextLiteral.Map.inputDepartmentButton)
        button.isEnabled = true
        return button
    }()

    // MARK: - View Setup

    override func configureUI() {
        // 바텀시트 배경 및 모서리 설정
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }

        view.addSubview(titleLabel)
        view.addSubview(logoStackView)
        view.addSubview(inputButton)
    }

    override func setLayout() {

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        logoStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(100)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(160)
            $0.height.equalTo(70)
        }

        inputButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(5)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        logScreenView(screenID: FirebaseScreenID.Map.map3)
    }

    override func setButtonEvent() {
        inputButton.addTarget(self, action: #selector(goToDepartmentSetting), for: .touchUpInside)
    }

    // MARK: - Navigation

    /// "학과 입력하기" 버튼 클릭 시 학과 설정 화면으로 이동
    @objc private func goToDepartmentSetting() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let tabContainer = sceneDelegate.window?.rootViewController as? CustomTabBarContainerController else {
            dismiss(animated: true)
            return
        }

        // "내 정보" 탭으로 전환
        tabContainer.setTab(index: 3)

        guard let myNav = tabContainer.getNavController(at: 3) else {
            dismiss(animated: true)
            return
        }

        dismiss(animated: true) {
            if let existingVC = myNav.viewControllers.first(where: { $0 is SetNickNameViewController }) {
                myNav.popToViewController(existingVC, animated: true)
            } else {
                let setNickNameVC = SetNickNameViewController()
                setNickNameVC.source = .mypage
                myNav.pushViewController(setNickNameVC, animated: true)
            }
        }
    }
}
