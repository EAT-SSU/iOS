//
//  MarkerDetailViewController.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 1/31/25.
//

import UIKit

import EATSSUKit

/// 마커의 상세 정보를 표시하는 Modal View Controller
class MarkerDetailViewController: BaseViewController {
    // MARK: - Properties

    private let markerDetailView = MarkerDetailView()
    private let markerData: MarkerData

    // MARK: - Initialization

    /// Initializes the view controller with the required marker data.
    ///
    /// - Parameter markerData: 마커의 상세 정보를 담은 데이터
    init(markerData: MarkerData) {
        self.markerData = markerData
        super.init(nibName: nil, bundle: nil)
    }

    /// 스토리보드나 XIB를 통한 초기화를 지원하지 않습니다.
    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life Cycle

    override func loadView() {
        markerDetailView.titleLabel.text = markerData.title
        markerDetailView.categoryLabel.text = "테스트"
        markerDetailView.partnershipPeriodLabel.text = "테스트 기간"
        markerDetailView.explanatonLabel.text = markerData.description
        markerDetailView.businessStatusLabel.text = "영업기간 테스트"
        view = markerDetailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func configureUI() {
        // loadView 메소드를 사용해서 불필요한 코드라고 생각함. 다만 loadView 메소드 자체를 잘 사용하지 않아서, 어떤 방법을 채택할 지 고민을 해야 할 듯 함.
    }

    override func setLayout() {
        //
    }
}
