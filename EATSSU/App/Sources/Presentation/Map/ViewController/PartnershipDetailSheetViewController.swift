//
//  PartnershipDetailSheetViewController.swift
//  EATSSU
//
//  Created by 황상환 on 7/2/25.
//

import UIKit

import EATSSUDesign

final class PartnershipDetailSheetViewController: UIViewController {

    private let partnership: PartnershipDTO

    init(partnership: PartnershipDTO) {
        self.partnership = partnership
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private let storeNameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let dateLabel = UILabel()
    private let collegeLabel = UILabel()
    private let departmentLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupLayout()
        configureData()
    }

    private func setupViews() {
        storeNameLabel.font = EATSSUDesignFontFamily.Pretendard.bold.font(size: 18)
        descriptionLabel.font = EATSSUDesignFontFamily.Pretendard.regular.font(size: 14)
        dateLabel.font = EATSSUDesignFontFamily.Pretendard.light.font(size: 12)
        collegeLabel.font = EATSSUDesignFontFamily.Pretendard.light.font(size: 12)
        departmentLabel.font = EATSSUDesignFontFamily.Pretendard.light.font(size: 12)

        descriptionLabel.numberOfLines = 0
        collegeLabel.numberOfLines = 0
        departmentLabel.numberOfLines = 0

        [storeNameLabel, descriptionLabel, dateLabel, collegeLabel, departmentLabel].forEach {
            view.addSubview($0)
        }
    }

    private func setupLayout() {
        storeNameLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(storeNameLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        collegeLabel.snp.makeConstraints {
            $0.top.equalTo(dateLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        departmentLabel.snp.makeConstraints {
            $0.top.equalTo(collegeLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }

    private func configureData() {
        storeNameLabel.text = partnership.storeName
        descriptionLabel.text = partnership.description
        dateLabel.text = "기간: \(partnership.startDate) ~ \(partnership.endDate)"
        collegeLabel.text = "대학: \(partnership.collegeNames.joined(separator: ", "))"
        departmentLabel.text = "학과: \(partnership.departmentNames.joined(separator: ", "))"
    }
}
