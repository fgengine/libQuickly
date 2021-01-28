//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQSpinnerView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var size: QDimensionBehaviour { get }
    var activityColor: QColor { get }
    var isAnimating: Bool { get }
    
    @discardableResult
    func size(_ value: QDimensionBehaviour) -> Self
    
    @discardableResult
    func activityColor(_ value: QColor) -> Self
    
    @discardableResult
    func animating(_ value: Bool) -> Self
    
}
