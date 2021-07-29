//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQSpinnerView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {
    
    var size: QDimensionBehaviour { set get }
    
    var activityColor: QColor { set get }
    
    var isAnimating: Bool { set get }
    
    @discardableResult
    func size(_ value: QDimensionBehaviour) -> Self
    
    @discardableResult
    func activityColor(_ value: QColor) -> Self
    
    @discardableResult
    func animating(_ value: Bool) -> Self
    
}
