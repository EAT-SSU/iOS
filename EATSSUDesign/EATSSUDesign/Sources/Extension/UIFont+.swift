//
//  UIFont+.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/03/15.
//

import UIKit

extension UIFont {
    // MARK: - Heading

    class var header1: UIFont { EATSSUDesignFontFamily.Pretendard.bold.font(size: 20) }
    class var header2: UIFont { EATSSUDesignFontFamily.Pretendard.bold.font(size: 18) }

    // MARK: - SubTitle

    class var subtitle1: UIFont { EATSSUDesignFontFamily.Pretendard.bold.font(size: 16) }
    class var subtitle2: UIFont { EATSSUDesignFontFamily.Pretendard.semiBold.font(size: 16) }

    // MARK: - Body

    class var body1: UIFont { EATSSUDesignFontFamily.Pretendard.medium.font(size: 16) }
    class var body2: UIFont { EATSSUDesignFontFamily.Pretendard.medium.font(size: 14) }
    class var body3: UIFont { EATSSUDesignFontFamily.Pretendard.regular.font(size: 14) }

    // MARK: - Caption

    class var caption1: UIFont { EATSSUDesignFontFamily.Pretendard.bold.font(size: 12) }
    class var caption2: UIFont { EATSSUDesignFontFamily.Pretendard.medium.font(size: 12) }
    class var caption3: UIFont { EATSSUDesignFontFamily.Pretendard.medium.font(size: 10) }

    // MARK: - Button

    class var button1: UIFont { EATSSUDesignFontFamily.Pretendard.bold.font(size: 18) }
    class var button2: UIFont { EATSSUDesignFontFamily.Pretendard.bold.font(size: 14) }

    // MARK: - etc

    class var rate: UIFont { EATSSUDesignFontFamily.Pretendard.medium.font(size: 40) }

    // MARK: - Widget

    class var widget1: UIFont { EATSSUDesignFontFamily.Pretendard.medium.font(size: 8) }
    class var widget2: UIFont { EATSSUDesignFontFamily.Pretendard.bold.font(size: 10) }
}
