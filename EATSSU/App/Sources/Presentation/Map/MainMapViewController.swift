//
//  MainMapViewController.swift
//  EATSSU-DEV
//
//  Created by 황상환 on 6/24/25.
//

import UIKit
import NMapsMap

import EATSSUDesign

final class MainMapViewController: UIViewController {

    private let mainView = MainMapView()

    override func loadView() {
        self.view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "제휴 지도"

        // 배경색 채우기
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = .white 
        navBarAppearance.titleTextAttributes = [
            .foregroundColor: UIColor.black,
            .font: EATSSUDesignFontFamily.Pretendard.bold.font(size: 16)
        ]

        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.compactAppearance = navBarAppearance

        mainView.wholeButton.addTarget(self, action: #selector(didTapWhole), for: .touchUpInside)
        mainView.myOnlyButton.addTarget(self, action: #selector(didTapMyOnly), for: .touchUpInside)
        mainView.heartButton.addTarget(self, action: #selector(didTapHeart), for: .touchUpInside)
        
    }

    @objc private func didTapWhole() {
        mainView.selectWhole(true)
        print("전체 보기")
    }

    @objc private func didTapMyOnly() {
        mainView.selectWhole(false)
        print("내 제휴 보기")
    }

    @objc private func didTapHeart() {
        print("하트 버튼 클릭됨")
    }
}
