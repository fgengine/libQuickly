//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQProgressView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {

    var width: QDimensionBehaviour { set get }
    
    var height: QDimensionBehaviour { set get }
    
    var progressColor: QColor { set get }
    
    var trackColor: QColor { set get }
    
    var progress: Float { set get }
    
    @discardableResult
    func width(_ value: QDimensionBehaviour) -> Self
    
    @discardableResult
    func height(_ value: QDimensionBehaviour) -> Self
    
    @discardableResult
    func progressColor(_ value: QColor) -> Self
    
    @discardableResult
    func trackColor(_ value: QColor) -> Self
    
    @discardableResult
    func progress(_ value: Float) -> Self
    
}
