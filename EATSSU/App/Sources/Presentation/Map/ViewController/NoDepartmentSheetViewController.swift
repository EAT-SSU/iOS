//
//  NoDepartmentSheetViewController.swift
//  EATSSU
//
//  Created by 황상환 on 7/15/25.
//

import UIKit
import SnapKit
import EATSSUDesign

final class NoDepartmentSheetViewController: UIViewController {

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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSheet()
        setupLayout()
        inputButton.addTarget(self, action: #selector(goToDepartmentSetting), for: .touchUpInside)
    }

    private func setupSheet() {
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        if let sheet = sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
    }

    private func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(logoStackView)
        view.addSubview(inputButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        logoStackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(90)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(160)
            $0.height.equalTo(70)
        }

        inputButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(26)
            $0.height.equalTo(52)
        }
    }

    @objc private func goToDepartmentSetting() {
        let vc = SetNickNameViewController()
        if let nav = presentingViewController as? UINavigationController {
            dismiss(animated: true) {
                nav.pushViewController(vc, animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
}
