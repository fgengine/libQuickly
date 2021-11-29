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

extension IQWidgetView where Body : IQViewAlphable {
    
    public var alpha: Float {
        set(value) { self.body.alpha = value }
        get { return self.body.alpha }
    }
    
    @discardableResult
    public func alpha(_ value: Float) -> Self {
        self.body.alpha(value)
        return self
    }
    
}
