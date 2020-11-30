//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public struct QInputPlaceholder {
    
    public var text: String
    public var font: QFont
    public var color: QColor
    
    @inlinable
    public init(
        text: String,
        font: QFont,
        color: QColor
    ) {
        self.text = text
        self.font = font
        self.color = color
    }

}
