//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public struct QViewShadow : Equatable {

    public let color: QColor
    public let opacity: Float
    public let radius: Float
    public let offset: QPoint
    
    @inlinable
    public init(
        color: QColor,
        opacity: Float,
        radius: Float,
        offset: QPoint
    ) {
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.offset = offset
    }

}

public protocol IQViewShadowable : AnyObject {
    
    var shadow: QViewShadow? { set get }
    
    @discardableResult
    func shadow(_ value: QViewShadow?) -> Self
    
}

extension IQWidgetView where Body : IQViewShadowable {
    
    public var shadow: QViewShadow? {
        set(value) { self.body.shadow = value }
        get { return self.body.shadow }
    }
    
    @discardableResult
    public func shadow(_ value: QViewShadow?) -> Self {
        self.body.shadow(value)
        return self
    }
    
}
