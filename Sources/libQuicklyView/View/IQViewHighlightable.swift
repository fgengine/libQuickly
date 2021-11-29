//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQViewHighlightable : IQViewStyleable {
    
    var isHighlighted: Bool { set get }
    
    @discardableResult
    func highlight(_ value: Bool) -> Self
    
}

extension IQWidgetView where Body : IQViewHighlightable {
    
    public var isHighlighted: Bool {
        set(value) { self.body.isHighlighted = value }
        get { return self.body.isHighlighted }
    }
    
    @discardableResult
    public func highlight(_ value: Bool) -> Self {
        self.body.highlight(value)
        return self
    }
    
}
