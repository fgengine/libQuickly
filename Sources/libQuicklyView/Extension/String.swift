//
//  libQuicklyView
//

import Foundation

public extension String {
    
    @inlinable
    func size(font: QFont, available: QSize) -> QSize {
        let attributed = NSAttributedString(string: self, attributes: [ .font : font.native ])
        return attributed.size(available: available)
    }
    
}
