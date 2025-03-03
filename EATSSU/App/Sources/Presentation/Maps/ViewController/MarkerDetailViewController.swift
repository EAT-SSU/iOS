//
//  MarkerDetailViewController.swift
//  EATSSU
//
//  Created by JIWOONG CHOI on 1/31/25.
//

import UIKit

import EATSSUKit

import RxSwift

/// 마커의 상세 정보를 표시하는 Modal View Controller
class MarkerDetailViewController: BaseViewController {
    // MARK: - Properties

    private let markerDetailView = MarkerDetailView()
    private let markerData: MarkerData
    private let partnershipService = PartnershipService()
    private let disposeBag = DisposeBag()

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
        view = markerDetailView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_: Bool) {
        fetchPartnershipDetail(partnershipId: markerData.id)
    }

    override func configureUI() {
        // TODO: loadView 메소드를 사용해서 불필요한 코드라고 생각함. 다만 loadView 메소드 자체를 잘 사용하지 않아서, 어떤 방법을 채택할 지 고민을 해야 할 듯 함.
    }

    override func setLayout() {
        //
    }
}

private extension MarkerDetailViewController {
    func fetchPartnershipDetail(partnershipId: Int) {
        partnershipService.fetchPartnershipDetail(partnershipId: partnershipId)
            .subscribe(
                onSuccess: { [weak self] response in
                    #if DEBUG
                        // JSON 응답 출력
                        print("\n🔍 [FetchPartnershipDetail Service] Response Details:")
                        if let jsonData = try? JSONEncoder().encode(response),
                           let prettyJSON = JSONPrettyPrinter.prettyPrintedJSONString(from: jsonData)
                        {
                            print("\n📦 Response Data Structure:")
                            print(prettyJSON)
                        } else {
                            print("⚠️ JSON 변환 실패")
                        }
                        print("\n" + String(repeating: "-", count: 50) + "\n")
                    #endif

                    self?.markerDetailView.titleLabel.text = response.result.storeName
                    self?.markerDetailView.categoryLabel.text = response.result.restaurantType
                    self?.markerDetailView.partnershipPeriodLabel.text
                        = "\(response.result.startDate) ~ \(response.result.endDate)"
                    self?.markerDetailView.explanatonLabel.text = response.result.description
                },
                onFailure: { error in
                    #if DEBUG
                        print("문제가 발생했습니다 : \(error.localizedDescription)")
                    #endif
                    AlertControllerHelper
                        .showConfirmOnlyAlert(title: "문제가 발생했습니다", message: "다시 시도하세요", in: self)
                }
            )
            .disposed(by: disposeBag)
    }
}
