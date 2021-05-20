//
//  libQuicklyCore
//

#if canImport(CoreGraphics)

import CoreGraphics

public extension QSize {
    
    @inlinable
    var cgSize: CGSize {
        return CGSize(
            width: CGFloat(self.width),
            height: CGFloat(self.height)
        )
    }
    
    @inlinable
    init(_ cgSize: CGSize) {
        self.width = Float(cgSize.width)
        self.height = Float(cgSize.height)
    }
    
}

#endif
