//
//  NoticeSplashViewController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 3/25/25.
//

import UIKit

import SnapKit

import EATSSUDesign

/// 점검 혹은 공지가 필요할 때 사용하는 스플래시 뷰
class NoticeSplashViewController: BaseViewController {

    // MARK: - UI Components

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.alertCircle.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = EATSSUDesignAsset.Images.authLogo.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "긴급 서버 점검 안내"
        label.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 16)
        label.textColor = EATSSUDesignAsset.Color.Main.primary.color
        label.textAlignment = .center
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        let text = """
        3월 29일(토) 오후 11시부터 3월 30일(일) 오전 1시까지
        서버 점검으로 인해 앱 이용이 일시 중단됩니다.
        이용에 불편을 드려 죄송합니다.
        빠르게 정상화될 수 있도록 최선을 다하겠습니다.
        """
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.0
        paragraphStyle.alignment = .center

        let attributes: [NSAttributedString.Key: Any] = [
            .font: EATSSUDesignFontFamily.Pretendard.medium.font(size: 12),
            .foregroundColor: UIColor.black,
            .paragraphStyle: paragraphStyle
        ]

        label.attributedText = NSAttributedString(string: text, attributes: attributes)
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = EATSSUDesignAsset.Color.Main.secondary.color
    }

    // MARK: - UI Setup

    override func configureUI() {
        [iconImageView, logoImageView, titleLabel, messageLabel].forEach {
            view.addSubview($0)
        }
    }

    override func setLayout() {
        iconImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(300)
            $0.width.height.equalTo(45)
        }

        logoImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(iconImageView.snp.bottom).offset(12)
            $0.width.equalTo(120)
            $0.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(logoImageView.snp.bottom).offset(12)
        }

        messageLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.centerX.equalToSuperview()
        }
    }
}
