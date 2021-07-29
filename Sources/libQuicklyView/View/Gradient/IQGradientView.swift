//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public struct QGradientViewFill {
    
    public let mode: QGradientViewMode
    public let points: [QGradientViewPoint]
    public let start: QPoint
    public let end: QPoint
    
    @inlinable
    public init(
        mode: QGradientViewMode,
        points: [QGradientViewPoint],
        start: QPoint,
        end: QPoint
    ) {
        self.mode = mode
        self.points = points
        self.start = start
        self.end = end
    }
    
}

public enum QGradientViewMode {
    case axial
    case radial
}

public struct QGradientViewPoint {
    
    public let color: QColor
    public let location: Float
    
    @inlinable
    public init(
        color: QColor,
        location: Float
    ) {
        self.color = color
        self.location = location
    }
    
}

public protocol IQGradientView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var width: QDimensionBehaviour { set get }
    
    var height: QDimensionBehaviour { set get }
    
    var fill: QGradientViewFill { set get }
    
    @discardableResult
    func width(_ value: QDimensionBehaviour) -> Self
    
    @discardableResult
    func height(_ value: QDimensionBehaviour) -> Self
    
    @discardableResult
    func fill(_ value: QGradientViewFill) -> Self
    
}

public extension QGradientViewFill {
    
    @inlinable
    var isOpaque: Bool {
        for point in self.points {
            if point.color.isOpaque == false {
                return false
            }
        }
        return true
    }
    
}
