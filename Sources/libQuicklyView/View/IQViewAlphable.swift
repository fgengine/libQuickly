//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQViewAlphable : AnyObject {
    
    var alpha: Float { set get }
    
    @discardableResult
    func alpha(_ value: Float) -> Self
    
}
