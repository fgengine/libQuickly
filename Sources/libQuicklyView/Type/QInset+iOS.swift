//
//  libQuicklyView
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
        self.top = QFloat(uiEdgeInsets.top)
        self.left = QFloat(uiEdgeInsets.left)
        self.right = QFloat(uiEdgeInsets.right)
        self.bottom = QFloat(uiEdgeInsets.bottom)
    }
    
}

#endif
