//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQViewSelectable : IQViewStyleable {
    
    var isSelected: Bool { set get }
    
    @discardableResult
    func select(_ value: Bool) -> Self
    
}

extension IQWidgetView where Body : IQViewSelectable {
    
    public var isSelected: Bool {
        set(value) { self.body.isSelected = value }
        get { return self.body.isSelected }
    }
    
    @discardableResult
    public func select(_ value: Bool) -> Self {
        self.body.select(value)
        return self
    }
    
}
