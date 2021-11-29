//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQViewLockable : IQViewStyleable {
    
    var isLocked: Bool { set get }
    
    @discardableResult
    func lock(_ value: Bool) -> Self
    
}

extension IQWidgetView where Body : IQViewLockable {
    
    public var isLocked: Bool {
        set(value) { self.body.isLocked = value }
        get { return self.body.isLocked }
    }
    
    @discardableResult
    public func lock(_ value: Bool) -> Self {
        self.body.lock(value)
        return self
    }
    
}
