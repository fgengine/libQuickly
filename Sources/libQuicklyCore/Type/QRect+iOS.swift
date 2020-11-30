//
//  libQuicklyCore
//

#if os(iOS)

import UIKit

public extension QRect {
    
    @inlinable
    func apply(inset: UIEdgeInsets) -> QRect {
        return self.apply(inset: QInset(inset))
    }
    
}

#endif
