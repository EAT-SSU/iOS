//
//  UIFont+.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/03/15.
//

import UIKit

extension UIFont {
/*
 설명
 1.x.x 버전에서 사용 중이던 AppleSD 폰트 사용입니다.
 이제 더 이상 사용하지는 않지만, 개발단계에 있어서 빌드에러가 발생하지 않도록 남겨두고, 추후 제거하겠습니다.
 */
    class func regular(size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.regularFont.rawValue, size: size)!
    }
    
    class func medium(size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.mediumFont.rawValue, size: size)!
    }
    
    class func semiBold(size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.semiBoldFont.rawValue, size: size)!
    }
    
    class func bold(size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.boldFont.rawValue, size: size)!
    }
    
    class func extraBold(size: CGFloat) -> UIFont {
        return UIFont(name: AppFontName.extraBoldFont.rawValue, size: size)!
    }
 
  // MARK: - Heading
      
  class var header1: UIFont { return EATSSUFontFamily.Pretendard.bold.font(size: 20) }
  class var header2: UIFont { return EATSSUFontFamily.Pretendard.bold.font(size: 18) }
      
  // MARK: - SubTitle
      
  class var subtitle1: UIFont { return EATSSUFontFamily.Pretendard.bold.font(size: 16) }
  class var subtitle2: UIFont { return EATSSUFontFamily.Pretendard.semiBold.font(size: 16) }
      
  // MARK: - Body
      
  class var body1: UIFont { return EATSSUFontFamily.Pretendard.medium.font(size: 16) }
  class var body2: UIFont { return EATSSUFontFamily.Pretendard.medium.font(size: 14) }
  class var body3: UIFont { return EATSSUFontFamily.Pretendard.regular.font(size: 14) }
      
  // MARK: - Caption
      
  class var caption1: UIFont { return EATSSUFontFamily.Pretendard.bold.font(size: 12) }
  class var caption2: UIFont { return EATSSUFontFamily.Pretendard.medium.font(size: 12) }
  class var caption3: UIFont { return EATSSUFontFamily.Pretendard.medium.font(size: 10) }

  // MARK: - Button
      
  class var button1: UIFont { return EATSSUFontFamily.Pretendard.bold.font(size: 18) }
  class var button2: UIFont { return EATSSUFontFamily.Pretendard.bold.font(size: 14) }
      
  // MARK: - etc
      
  class var rate: UIFont { return EATSSUFontFamily.Pretendard.medium.font(size: 40) }
  
  // MARK: - Widget
  
  class var widget1: UIFont { return EATSSUFontFamily.Pretendard.medium.font(size: 8) }
  class var widget2: UIFont { return EATSSUFontFamily.Pretendard.bold.font(size: 10) }

}
