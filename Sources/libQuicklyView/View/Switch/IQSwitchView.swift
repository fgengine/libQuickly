//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQSwitchView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {

    var width: QDimensionBehaviour { set get }
    
    var height: QDimensionBehaviour { set get }
    
    var thumbColor: QColor { set get }
    
    var offColor: QColor { set get }
    
    var onColor: QColor { set get }
    
    var value: Bool { set get }
    
    @discardableResult
    func width(_ value: QDimensionBehaviour) -> Self
    
    @discardableResult
    func height(_ value: QDimensionBehaviour) -> Self
    
    @discardableResult
    func thumbColor(_ value: QColor) -> Self
    
    @discardableResult
    func offColor(_ value: QColor) -> Self
    
    @discardableResult
    func onColor(_ value: QColor) -> Self
    
    @discardableResult
    func value(_ value: Bool) -> Self
    
    @discardableResult
    func onChangeValue(_ value: (() -> Void)?) -> Self
    
}
