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
    public class func regular(size: CGFloat) -> UIFont {
        UIFont(name: AppFontName.regularFont.rawValue, size: size)!
    }

    public class func medium(size: CGFloat) -> UIFont {
        UIFont(name: AppFontName.mediumFont.rawValue, size: size)!
    }

    public class func semiBold(size: CGFloat) -> UIFont {
        UIFont(name: AppFontName.semiBoldFont.rawValue, size: size)!
    }

    public class func bold(size: CGFloat) -> UIFont {
        UIFont(name: AppFontName.boldFont.rawValue, size: size)!
    }

    public class func extraBold(size: CGFloat) -> UIFont {
        UIFont(name: AppFontName.extraBoldFont.rawValue, size: size)!
    }

    // MARK: - Heading

    public class var header1: UIFont { EATSSUDesignFontFamily.Pretendard.bold.font(size: 20) }
    public class var header2: UIFont { EATSSUDesignFontFamily.Pretendard.bold.font(size: 18) }

    // MARK: - SubTitle

    public class var subtitle1: UIFont { EATSSUDesignFontFamily.Pretendard.bold.font(size: 16) }
    public class var subtitle2: UIFont { EATSSUDesignFontFamily.Pretendard.semiBold.font(size: 16) }

    // MARK: - Body

    public class var body1: UIFont { EATSSUDesignFontFamily.Pretendard.medium.font(size: 16) }
    public class var body2: UIFont { EATSSUDesignFontFamily.Pretendard.medium.font(size: 14) }
    public class var body3: UIFont { EATSSUDesignFontFamily.Pretendard.regular.font(size: 14) }

    // MARK: - Caption

    public class var caption1: UIFont { EATSSUDesignFontFamily.Pretendard.bold.font(size: 12) }
    public class var caption2: UIFont { EATSSUDesignFontFamily.Pretendard.medium.font(size: 12) }
    public class var caption3: UIFont { EATSSUDesignFontFamily.Pretendard.medium.font(size: 10) }

    // MARK: - Button

    public class var button1: UIFont { EATSSUDesignFontFamily.Pretendard.bold.font(size: 18) }
    public class var button2: UIFont { EATSSUDesignFontFamily.Pretendard.bold.font(size: 14) }

    // MARK: - etc

    public class var rate: UIFont { EATSSUDesignFontFamily.Pretendard.medium.font(size: 40) }

    // MARK: - Widget

    public class var widget1: UIFont { EATSSUDesignFontFamily.Pretendard.medium.font(size: 8) }
    public class var widget2: UIFont { EATSSUDesignFontFamily.Pretendard.bold.font(size: 10) }
}
