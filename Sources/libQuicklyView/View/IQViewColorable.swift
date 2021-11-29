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

extension IQWidgetView where Body : IQViewColorable {
    
    public var color: QColor? {
        set(value) { self.body.color = value }
        get { return self.body.color }
    }
    
    @discardableResult
    public func color(_ value: QColor?) -> Self {
        self.body.color(value)
        return self
    }
    
}
