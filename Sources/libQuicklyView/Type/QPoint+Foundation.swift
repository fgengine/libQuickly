//
//  libQuicklyView
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
        self.x = QFloat(cgPoint.x)
        self.y = QFloat(cgPoint.y)
    }
    
}

#endif
