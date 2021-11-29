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

extension IQWidgetView where Body : IQViewTintColorable {
    
    public var tintColor: QColor? {
        set(value) { self.body.tintColor = value }
        get { return self.body.tintColor }
    }
    
    @discardableResult
    public func tintColor(_ value: QColor?) -> Self {
        self.body.tintColor(value)
        return self
    }
    
}
