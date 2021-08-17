//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension NSAttributedString {
    
    @inlinable
    func size(available: QSize) -> QSize {
        let bounding = self.boundingRect(with: available.cgSize, options: [ .usesLineFragmentOrigin, .usesFontLeading ], context: nil)
        let size = bounding.integral.size
        return QSize(size)
    }
    
}

public extension NSAttributedString.Key {
    
    static let customLink = NSAttributedString.Key("Quickly::CustomLink")
    
}
