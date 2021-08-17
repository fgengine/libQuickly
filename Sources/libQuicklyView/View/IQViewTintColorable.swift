//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQViewTintColorable : AnyObject {
    
    var tintColor: QColor? { set get }
    
    @discardableResult
    func tintColor(_ value: QColor?) -> Self
    
}
