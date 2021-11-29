//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public enum QViewBorder : Equatable {
    case none
    case manual(width: Float, color: QColor)
}

public protocol IQViewBorderable : AnyObject {
    
    var border: QViewBorder { set get }
    
    @discardableResult
    func border(_ value: QViewBorder) -> Self
    
}

extension IQWidgetView where Body : IQViewBorderable {
    
    public var border: QViewBorder {
        set(value) { self.body.border = value }
        get { return self.body.border }
    }
    
    @discardableResult
    public func border(_ value: QViewBorder) -> Self {
        self.body.border(value)
        return self
    }
    
}
