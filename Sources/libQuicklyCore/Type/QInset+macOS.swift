//
//  libQuicklyCore
//

#if os(OSX)

import AppKit

public extension QInset {
    
    @inlinable
    var nsEdgeInsets: NSEdgeInsets {
        return NSEdgeInsets(
            top: CGFloat(self.top),
            left: CGFloat(self.left),
            bottom: CGFloat(self.bottom),
            right: CGFloat(self.right)
        )
    }
    
    @inlinable
    init(_ nsEdgeInsets: NSEdgeInsets) {
        self.top = Float(nsEdgeInsets.top)
        self.left = Float(nsEdgeInsets.left)
        self.right = Float(nsEdgeInsets.right)
        self.bottom = Float(nsEdgeInsets.bottom)
    }
    
}

#endif
