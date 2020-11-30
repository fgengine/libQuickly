//
//  libQuicklyCore
//

#if os(iOS)

import UIKit

public extension QColor {
    
    @inlinable
    var cgColor: CGColor {
        return self.native.cgColor
    }
    
    @inlinable
    var native: UIColor {
        return UIColor(
            red: CGFloat(self.r),
            green: CGFloat(self.g),
            blue: CGFloat(self.b),
            alpha: CGFloat(self.a)
        )
    }
    
    @inlinable
    init(_ native: UIColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        native.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.r = QFloat(r)
        self.g = QFloat(g)
        self.b = QFloat(b)
        self.a = QFloat(a)
    }
    
    @inlinable
    init(_ cgColor: CGColor) {
        self.init(UIColor(cgColor: cgColor))
    }
    
}

#endif
