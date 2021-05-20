//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQProgressView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {

    var width: QDimensionBehaviour { get }
    var height: QDimensionBehaviour { get }
    var progressColor: QColor { get }
    var trackColor: QColor { get }
    var progress: Float { get }
    
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
