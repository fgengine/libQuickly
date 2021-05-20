//
//  libQuicklyCore
//

#if canImport(CoreGraphics)

import CoreGraphics

public extension QPoint {
    
    @inlinable
    var cgPoint: CGPoint {
        return CGPoint(
            x: CGFloat(self.x),
            y: CGFloat(self.y)
        )
    }
    
    @inlinable
    init(_ cgPoint: CGPoint) {
        self.x = Float(cgPoint.x)
        self.y = Float(cgPoint.y)
    }
    
}

#endif
