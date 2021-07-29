//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQViewColorable : AnyObject {
    
    var color: QColor? { set get }
    
    @discardableResult
    func color(_ value: QColor?) -> Self
    
}
