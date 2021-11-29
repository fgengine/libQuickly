//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public enum QViewCornerRadius : Equatable {
    case none
    case manual(radius: Float)
    case auto
}

public protocol IQViewCornerRadiusable : AnyObject {
    
    var cornerRadius: QViewCornerRadius { set get }
    
    @discardableResult
    func cornerRadius(_ value: QViewCornerRadius) -> Self
    
}

extension IQWidgetView where Body : IQViewCornerRadiusable {
    
    public var cornerRadius: QViewCornerRadius {
        set(value) { self.body.cornerRadius = value }
        get { return self.body.cornerRadius }
    }
    
    @discardableResult
    public func cornerRadius(_ value: QViewCornerRadius) -> Self {
        self.body.cornerRadius(value)
        return self
    }
    
}
