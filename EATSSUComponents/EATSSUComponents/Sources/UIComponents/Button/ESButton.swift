//
//  ESButton.swift
//  EATSSUComponents
//
//  Created by Jiwoong CHOI on 8/29/24.
//

import Foundation
import UIKit

import SnapKit

/// 두 가지 크기의 EATSSU 버튼
///
/// Big & Small 사이즈를 제공합니다.
public enum ButtonSize {
  
  /// 큰 사이즈 EATSSU 버튼입니다.
    case big
  
  /// 작은 사이즈 EATSSU 버튼입니다.
    case small
}

/// EATSSU 앱에서 보편적으로 사용하는 버튼
final public class ESButton: UIButton {
    
    private enum Size {
        static let height: CGFloat = 52.adjusted
        static let smallButtonWidth: CGFloat = 80.adjusted
    }
    
    // MARK: - Properties
    
    private var buttonSize: ButtonSize
    private var title: String
  
  /*
   설명
   - isEnabled 프로퍼티는 UIView의 프로퍼티를 오버라이드했다.
   - 오버라이드한 프로퍼티는 public이나 open 접근제한자로 설정해야 한다.
   - 여기서는 final로 명시를 했지만, 만약 ESButton 클래스를 상속받는 클래스가 있다면 똑같이 오버라이드할 수 있도록 조건을 형성해야 한다.
   */
    public override var isEnabled: Bool {
        didSet {
            setButtonState(as: isEnabled)
        }
    }
    
    // MARK: - Initializer
    
  /// EATSSU 버튼
  ///
  /// - Parameters:
  ///   - size: 큰 버튼과 작은 버튼을 선택합니다.
  ///   - title: 버튼의 타이틀입니다.
    public init(size: ButtonSize, title: String) {
      self.title = title
      self.buttonSize = size
      
      /// 설명
      /// 지정 이니셜라이저를 오버라이딩할 필요가 없는 상황이라 판단해서,
      /// 이니셜라이저를 직접 구현하고, 초기화가 끝나면 Swift 문법에 맞추어 슈퍼 클래스 이니셜라이저를 호출합니다.
      ///
      /// super.init이 해당 클래스 초기화 코드 이후에 온 이유는 다음과 같다.
      /// 스위프트의 two - phase intializer에 따라서 서브 클래스의 이니셜라이저가 먼저 호출되고, 슈퍼 클래스의 이니셜라이저가 호출된다.
      /// 그래서 서버 클래스의 이니셜라이저 호출 간 초기화 사항들이 정상적으로 이루어지고, 슈퍼 클래스 이니셜라이저가 생성된다.
      
      super.init(frame: .zero)
      
      self.configureUI(size: size)
    }
  
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
  
  // MARK: - Functions

    public override func didMoveToSuperview() {
      super.didMoveToSuperview()
      self.setLayout(size: buttonSize)
    }
    
    
    private func configureUI(size: ButtonSize) {
      self.layer.cornerRadius = 12.adjusted
      self.clipsToBounds = true
      self.backgroundColor = EATSSUComponentsAsset.Colors.MainColor.primary.color
      self.titleLabel?.textColor = .white
      self.setTitle(self.title, for: .normal)
        
      switch size {
      case .big:
          self.titleLabel?.font = .button1
      case .small:
          self.titleLabel?.font = .button2
        }
    }
    
    private func setLayout(size: ButtonSize) {
        switch size {
        case .big:
            self.snp.makeConstraints {
                $0.height.equalTo(Size.height)
            }
        case .small:
            self.snp.makeConstraints {
                $0.height.equalTo(Size.height)
                $0.width.equalTo(Size.smallButtonWidth)
            }
        }
    }
    
    private func setButtonState(as isEnabled: Bool) {
        if isEnabled {
            self.alpha = 1
        } else {
            self.alpha = 0.5
        }
    }
}
