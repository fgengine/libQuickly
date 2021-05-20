//
//  libQuicklyView
//

#if os(OSX)

import AppKit

public extension QColor {
    
    @inlinable
    var cgColor: CGColor {
        return self.native.cgColor
    }
    
    @inlinable
    var native: NSColor {
        return NSColor(
            red: CGFloat(self.r),
            green: CGFloat(self.g),
            blue: CGFloat(self.b),
            alpha: CGFloat(self.a)
        )
    }
    
    @inlinable
    init(_ native: NSColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        native.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.r = Float(r)
        self.g = Float(g)
        self.b = Float(b)
        self.a = Float(a)
    }
    
    @inlinable
    init(_ cgColor: CGColor) {
        self.init(NSColor(cgColor: cgColor) ?? NSColor.black)
    }
    
}

#endif
