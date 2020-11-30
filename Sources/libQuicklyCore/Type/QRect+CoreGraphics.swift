//
//  libQuicklyCore
//

#if canImport(CoreGraphics)

import CoreGraphics

public extension QRect {
    
    @inlinable
    var cgRect: CGRect {
        return CGRect(
            origin: self.origin.cgPoint,
            size: self.size.cgSize
        )
    }
    
    @inlinable
    init(_ cgRect: CGRect) {
        self.origin = QPoint(cgRect.origin)
        self.size = QSize(cgRect.size)
    }
    
}

#endif
