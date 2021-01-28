//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQViewAlphable : AnyObject {
    
    var alpha: QFloat { get }
    
    @discardableResult
    func alpha(_ value: QFloat) -> Self
    
}
