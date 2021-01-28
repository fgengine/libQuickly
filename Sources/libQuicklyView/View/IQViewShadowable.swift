//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public struct QViewShadow {

    public let color: QColor
    public let opacity: QFloat
    public let radius: QFloat
    public let offset: QPoint
    
    @inlinable
    public init(
        color: QColor,
        opacity: QFloat,
        radius: QFloat,
        offset: QPoint
    ) {
        self.color = color
        self.opacity = opacity
        self.radius = radius
        self.offset = offset
    }

}

public protocol IQViewShadowable : AnyObject {
    
    var shadow: QViewShadow? { get }
    
    @discardableResult
    func shadow(_ value: QViewShadow?) -> Self
    
}
