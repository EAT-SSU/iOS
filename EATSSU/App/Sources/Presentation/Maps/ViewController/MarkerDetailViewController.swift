//
//  MarkerDetailViewController.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 1/31/25.
//

import UIKit

import EATSSUKit

/// 마커의 상세 정보를 표시하는 Modal View Controller
class MarkerDetailViewController: UIViewController {
    // MARK: - Properties

    var markerData: MarkerData?

    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.layer.cornerRadius = 8
        iv.clipsToBounds = true
        return iv
    }()

    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureData()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .white

        // Stack View 구성
        let stackView = UIStackView(arrangedSubviews: [titleLabel, imageView, descriptionLabel])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        // Auto Layout 설정
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalToConstant: 200),
        ])

        // 닫기 버튼 추가
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("닫기", for: .normal)
        closeButton.addTarget(self, action: #selector(dismissModal), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: closeButton)
    }

    // MARK: - Data Configuration

    private func configureData() {
        guard let data = markerData else { return }
        titleLabel.text = data.title
        descriptionLabel.text = data.description
    }

    // MARK: - Actions

    @objc
    private func dismissModal() {
        dismiss(animated: true, completion: nil)
    }
}
