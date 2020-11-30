//
//  libQuicklyCore
//

#if os(OSX)

import AppKit

public extension QRect {
    
    @inlinable
    func apply(inset: NSEdgeInsets) -> QRect {
        return self.apply(inset: QInset(inset))
    }
    
}

#endif
