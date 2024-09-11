//
//  BaseUIView.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/03/15.
//

/*
 해야 할 일
 - BaseUIView 코드 모듈화 간 재정비
 */

import UIKit

class BaseUIView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        setLayout()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
  /*
   해야 할 일
   - 아래 메소드들은 꼭 필요한 성격을 가지는 메소드이다.
   - 그럼에도 불구하고 꼭 오버라이드 해야 한다는 옵션을 주고 있지 않기 때문에 해당 함수를 꼭 사용해야 한다는 메시지가 담긴 추상화가 부족함.
   - 추상화가 부족하기 때문에 3자가 봤을 때 중복되는 함수를 설계할 가능성이 높음.
   - 그러므로 Swift 고유의 문법인 Protocol로 해당 부분을 개편할 것
   */
  
    func configureUI() {
        
    }
    
    func setLayout() {
        
    }
}

