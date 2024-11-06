//
//  UIFont+.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/03/15.
//

import UIKit

extension UIFont {
 
  // MARK: - Heading
      
	class var header1: UIFont { return EATSSUDesignFontFamily.Pretendard.bold.font(size: 20) }
  class var header2: UIFont { return EATSSUDesignFontFamily.Pretendard.bold.font(size: 18) }
      
  // MARK: - SubTitle
      
  class var subtitle1: UIFont { return EATSSUDesignFontFamily.Pretendard.bold.font(size: 16) }
  class var subtitle2: UIFont { return EATSSUDesignFontFamily.Pretendard.semiBold.font(size: 16) }
      
  // MARK: - Body
      
  class var body1: UIFont { return EATSSUDesignFontFamily.Pretendard.medium.font(size: 16) }
  class var body2: UIFont { return EATSSUDesignFontFamily.Pretendard.medium.font(size: 14) }
  class var body3: UIFont { return EATSSUDesignFontFamily.Pretendard.regular.font(size: 14) }
      
  // MARK: - Caption
      
  class var caption1: UIFont { return EATSSUDesignFontFamily.Pretendard.bold.font(size: 12) }
  class var caption2: UIFont { return EATSSUDesignFontFamily.Pretendard.medium.font(size: 12) }
  class var caption3: UIFont { return EATSSUDesignFontFamily.Pretendard.medium.font(size: 10) }

  // MARK: - Button
      
  class var button1: UIFont { return EATSSUDesignFontFamily.Pretendard.bold.font(size: 18) }
  class var button2: UIFont { return EATSSUDesignFontFamily.Pretendard.bold.font(size: 14) }
      
  // MARK: - etc
      
  class var rate: UIFont { return EATSSUDesignFontFamily.Pretendard.medium.font(size: 40) }
  
  // MARK: - Widget
  
  class var widget1: UIFont { return EATSSUDesignFontFamily.Pretendard.medium.font(size: 8) }
  class var widget2: UIFont { return EATSSUDesignFontFamily.Pretendard.bold.font(size: 10) }

}
