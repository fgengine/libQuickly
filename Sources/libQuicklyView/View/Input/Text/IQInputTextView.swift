//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQInputTextView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {

    var width: QDimensionBehaviour { set get }
    
    var height: QDimensionBehaviour { set get }
    
    var text: String { set get }
    
    var textFont: QFont { set get }
    
    var textColor: QColor { set get }
    
    var textInset: QInset { set get }
    
    var editingColor: QColor { set get }
    
    var placeholder: QInputPlaceholder { set get }
    
    var placeholderInset: QInset? { set get }
    
    var alignment: QTextAlignment { set get }
    
    #if os(iOS)
    
    var toolbar: IQInputToolbarView? { set get }
    
    var keyboard: QInputKeyboard? { set get }
    
    #endif
    
    @discardableResult
    func width(_ value: QDimensionBehaviour) -> Self
    
    @discardableResult
    func height(_ value: QDimensionBehaviour) -> Self
    
    @discardableResult
    func text(_ value: String) -> Self
    
    @discardableResult
    func textFont(_ value: QFont) -> Self
    
    @discardableResult
    func textColor(_ value: QColor) -> Self
    
    @discardableResult
    func textInset(_ value: QInset) -> Self
    
    @discardableResult
    func editingColor(_ value: QColor) -> Self
    
    @discardableResult
    func placeholder(_ value: QInputPlaceholder) -> Self
    
    @discardableResult
    func placeholderInset(_ value: QInset?) -> Self
    
    @discardableResult
    func alignment(_ value: QTextAlignment) -> Self
    
    #if os(iOS)
    
    @discardableResult
    func toolbar(_ value: IQInputToolbarView?) -> Self
    
    @discardableResult
    func keyboard(_ value: QInputKeyboard?) -> Self
    
    #endif
    
    @discardableResult
    func onBeginEditing(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onEditing(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onEndEditing(_ value: (() -> Void)?) -> Self
    
}
