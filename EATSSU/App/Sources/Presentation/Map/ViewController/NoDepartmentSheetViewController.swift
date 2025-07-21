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
        label.text = "학과를 입력하고\n나만의 제휴를 확인해보세요!"
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
        let button = ESButton(size: .big, title: "학과 입력하기")
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
        tabContainer.setTab(index: 2)

        if let myNav = tabContainer.getNavController(at: 2) {
            // 닉네임/학과 설정 화면으로 푸시
            dismiss(animated: true) {
                myNav.pushViewController(SetNickNameViewController(), animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
}
