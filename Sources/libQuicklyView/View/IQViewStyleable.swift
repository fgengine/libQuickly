//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQViewStyleable : AnyObject {
    
    func triggeredChangeStyle(_ userIteraction: Bool)
    
    @discardableResult
    func onChangeStyle(_ value: ((_ userIteraction: Bool) -> Void)?) -> Self
    
}

extension IQWidgetView where Body : IQViewStyleable {
    
    public func triggeredChangeStyle(_ userIteraction: Bool) {
        self.body.triggeredChangeStyle(userIteraction)
    }
    
    @discardableResult
    public func onChangeStyle(_ value: ((_ userIteraction: Bool) -> Void)?) -> Self {
        self.body.onChangeStyle(value)
        return self
    }
    
}
