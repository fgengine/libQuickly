//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public enum QViewBorder {
    case none
    case manual(width: QFloat, color: QColor)
}

public protocol IQViewBorderable : AnyObject {
    
    var border: QViewBorder { get }
    
    @discardableResult
    func border(_ value: QViewBorder) -> Self
    
}
