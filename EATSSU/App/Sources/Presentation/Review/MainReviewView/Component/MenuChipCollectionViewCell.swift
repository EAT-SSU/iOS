//
//  MenuChipCollectionViewCell.swift
//  EATSSU-DEV
//
//  Created by 최지우 on 2/2/25.
//

import UIKit
import SnapKit

import EATSSUDesign

final class MenuChipCollectionViewCell: UICollectionViewCell {
    static let id = "MenuChipCollectionViewCell"
    
    private let menuChipView: UIView = {
        let view = UIView()
        view.backgroundColor = EATSSUDesignAsset.Color.Main.secondary.color
        view.layer.cornerRadius = 10
        view.layer.borderColor = EATSSUDesignAsset.Color.Main.primary.color.cgColor
        view.layer.borderWidth = 0.5
        view.backgroundColor = .purple
        return view
    }()
    
    private let thumbsupImageView: UIImageView = {
        let imageView = UIImageView(image: EATSSUDesignAsset.Images.filledThumbUp.image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let menuLabel: UILabel = {
        let label = UILabel()
        label.font = EATSSUDesignFontFamily.Pretendard.medium.font(size: 10)
        label.textColor = EATSSUDesignAsset.Color.Main.primary.color
        label.text = "김치볶음바바바밥"
//        label.numberOfLines = 1
//        label.sizeToFit()
//        label.frame.size = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 22)
        return label
    }()
    
    lazy var menuChipStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [thumbsupImageView, menuLabel])
        stackView.axis = .horizontal
        stackView.spacing = 1
        stackView.backgroundColor = .green
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        addSubview(menuChipView)
        menuChipView.addSubviews(menuChipStackView)
    }
    
    private func setLayout() {
        setupDynamicLayout()

//        menuChipStackView.snp.makeConstraints { make in
//                        make.edges.equalToSuperview()

//            make.verticalEdges.equalToSuperview().inset(5)
//            make.horizontalEdges.equalToSuperview().inset(6)
//        }
//        menuChipView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        thumbsupImageView.snp.makeConstraints { make in
            make.width.height.equalTo(10)
        }
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.prepare(name: nil)
      }
      func prepare(name: String?) {
          self.menuLabel.text = name
          setupDynamicLayout()
      }
    private func setupDynamicLayout() {
        menuLabel.sizeToFit()
        let viewSize = menuLabel.intrinsicContentSize
        let width = viewSize.width + 30
        let height = viewSize.height + 48

        menuChipView.snp.remakeConstraints { make in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }

        menuChipStackView.snp.remakeConstraints { make in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }

        layoutIfNeeded()
    }
    
//    private func setupDynamicLayout() {
//        menuLabel.sizeToFit()
//        let viewSize = menuLabel.intrinsicContentSize
//        let width = viewSize.width + 58
//        let height = viewSize.height + 48
////        menuChipStackView.frame.size = CGSize(width: width, height: height)
//        menuChipStackView.frame.size = CGSize(width: width, height: height)
//        menuChipView.frame.size = CGSize(width: width, height: height)
//        
////        menuChipStackView.center = CGPoint(x: width / 2, y: height / 2)
//    }
    
}
