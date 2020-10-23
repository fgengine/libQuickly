//
//  libQuicklyView
//

import Foundation

public extension NSAttributedString {
    
    @inlinable
    func size(available: QSize) -> QSize {
        let bounding = self.boundingRect(with: available.cgSize, options: [ .usesLineFragmentOrigin ], context: nil)
        return QSize(bounding.integral.size)
    }
    
}
