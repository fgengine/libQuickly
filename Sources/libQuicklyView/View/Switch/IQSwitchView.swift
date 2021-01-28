//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQSwitchView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {

    var width: QDimensionBehaviour { get }
    var height: QDimensionBehaviour { get }
    var thumbColor: QColor { get }
    var offColor: QColor { get }
    var onColor: QColor { get }
    var value: Bool { get }
    
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
