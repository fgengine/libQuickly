//
//  libQuicklyView
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
        self.top = QFloat(nsEdgeInsets.top)
        self.left = QFloat(nsEdgeInsets.left)
        self.right = QFloat(nsEdgeInsets.right)
        self.bottom = QFloat(nsEdgeInsets.bottom)
    }
    
}

#endif
