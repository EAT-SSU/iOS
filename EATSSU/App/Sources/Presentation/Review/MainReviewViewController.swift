//
//  MainReviewViewController.swift
//  EATSSU-DEV
//
//  Created by 최지우 on 1/30/25.
//

import UIKit

final class MainReviewViewController: BaseViewController {
    
    // MARK: - Properties
    private var dataSource = [String]()
    
    // MARK: - UI Components

    private let mainReviewView = MainReviewView()
    
    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTableView()
        self.dataSource = ["고구마치즈돈까스", "막국수", "요구르트","김치","수육+겉절이김치참치", "온두부", "국","짜파게티"]
        mainReviewView.tableView.reloadData()
    }
    
    override func configureUI() {
        view.addSubview(mainReviewView)
        mainReviewView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setButtonEvent() {
        mainReviewView.writingReviewButton.addTarget(self, action: #selector(writeReviewButtonIsTapped), for: .touchUpInside)
    }
    
    private func setTableView() {
        mainReviewView.tableView.dataSource = self
        mainReviewView.tableView.delegate = self
        mainReviewView.tableView.register(ReviewListTableViewCell.self,
                                          forCellReuseIdentifier: ReviewListTableViewCell.id)
        mainReviewView.tableView.register(ReviewListTableViewHeader.self,
                                          forHeaderFooterViewReuseIdentifier: ReviewListTableViewHeader.id)
    }
    
    @objc
    private func writeReviewButtonIsTapped() {
        let writingReviewModalViewController = WritingReviewModalViewController()
        writingReviewModalViewController.modalPresentationStyle = .pageSheet
        self.present(writingReviewModalViewController, animated: true)
    }
}

extension MainReviewViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ReviewListTableViewCell.id,
                                                 for: indexPath) as! ReviewListTableViewCell
//        let row = self.dataSource[indexPath.row]
        cell.selectionStyle = .none
        cell.prepare(review: "name: Jay", menuChipList: dataSource)
        return cell
    }
}

extension MainReviewViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: ReviewListTableViewHeader.id) as! ReviewListTableViewHeader
        return cell
    }
}
