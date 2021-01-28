//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQInputTextView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {

    var width: QDimensionBehaviour { get }
    
    var height: QDimensionBehaviour { get }
    
    var text: String { get }
    
    var textFont: QFont { get }
    
    var textColor: QColor { get }
    
    var textInset: QInset { get }
    
    var editingColor: QColor { get }
    
    var placeholder: QInputPlaceholder { get }
    
    var placeholderInset: QInset? { get }
    
    var alignment: QTextAlignment { get }
    
    #if os(iOS)
    
    var toolbar: IQInputToolbarView? { get }
    
    var keyboard: QInputKeyboard? { get }
    
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
