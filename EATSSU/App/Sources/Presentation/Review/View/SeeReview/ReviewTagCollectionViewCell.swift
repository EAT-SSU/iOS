//
//  ReviewTagCollectionViewCell.swift
//  EATSSU
//
//  Created by 한금준 on 10/3/25.
//

import UIKit
import SnapKit

final class ReviewTagCollectionViewCell: UICollectionViewCell {
    static let identifier = "ReviewTagCollectionViewCell"

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "hand.thumbsup")
        iv.tintColor = .systemTeal
        iv.isHidden = true
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = .systemTeal
        return label
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
        return sv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layer.cornerRadius = contentView.bounds.height / 2
    }


    private func setupViews() {
        contentView.backgroundColor = UIColor.systemTeal.withAlphaComponent(0.1)
        contentView.layer.borderColor = UIColor.systemTeal.cgColor
        contentView.layer.borderWidth = 1

        stackView.addArrangedSubview(iconImageView)
        stackView.addArrangedSubview(titleLabel)

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        iconImageView.snp.makeConstraints { make in
            make.width.height.equalTo(10)
        }
        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.top.equalToSuperview().offset(2)
            make.bottom.equalToSuperview().inset(2)
        }
    }

    func configure(tagName: String, isLiked: Bool) {
        titleLabel.text = tagName
        if isLiked {
            iconImageView.isHidden = false
            iconImageView.image = UIImage(systemName: "hand.thumbsup")
        } else {
            iconImageView.isHidden = true
        }
    }
}
