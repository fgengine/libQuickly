//
//  libQuicklyCore
//

#if os(iOS)

import UIKit

public extension QInset {
    
    @inlinable
    var uiEdgeInsets: UIEdgeInsets {
        return UIEdgeInsets(
            top: CGFloat(self.top),
            left: CGFloat(self.left),
            bottom: CGFloat(self.bottom),
            right: CGFloat(self.right)
        )
    }
    
    @inlinable
    init(_ uiEdgeInsets: UIEdgeInsets) {
        self.top = Float(uiEdgeInsets.top)
        self.left = Float(uiEdgeInsets.left)
        self.right = Float(uiEdgeInsets.right)
        self.bottom = Float(uiEdgeInsets.bottom)
    }
    
}

#endif
