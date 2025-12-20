//
//  Adjusted+.swift
//  EatSSU-iOS
//
//  Created by 박윤빈 on 2023/11/27.
//

import UIKit

extension CGFloat {
    public var adjusted: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.width / 375
        let ratioH: CGFloat = UIScreen.main.bounds.height / 667
        return ratio <= ratioH ? self * ratio : self * ratioH
    }

    public var adjustedWidth: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.width / 375
        return CGFloat(self) * ratio
    }

    public var adjustedHeight: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.height / 667
        return CGFloat(self) * ratio
    }
}

extension Int {
    public var adjusted: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.width / 375
        let ratioH: CGFloat = UIScreen.main.bounds.height / 667
        return ratio <= ratioH ? CGFloat(self) * ratio : CGFloat(self) * ratioH
    }

    public var adjustedWidth: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.width / 375
        return CGFloat(self) * ratio
    }

    public var adjustedHeight: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.height / 667
        return CGFloat(self) * ratio
    }
}

extension Double {
    public var adjusted: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.width / 375
        let ratioH: CGFloat = UIScreen.main.bounds.height / 667
        return ratio <= ratioH ? CGFloat(self) * ratio : CGFloat(self) * ratioH
    }

    public var adjustedWidth: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.width / 375
        return CGFloat(self) * ratio
    }

    public var adjustedHeight: CGFloat {
        let ratio: CGFloat = UIScreen.main.bounds.height / 667
        return CGFloat(self) * ratio
    }
}
