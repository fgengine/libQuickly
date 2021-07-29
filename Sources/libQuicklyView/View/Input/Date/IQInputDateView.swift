//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public enum QInputDateViewMode {
    case time
    case date
    case dateTime
}

public protocol IQInputDateView : IQView, IQViewColorable, IQViewBorderable, IQViewCornerRadiusable, IQViewShadowable, IQViewAlphable {

    var width: QDimensionBehaviour { set get }
    
    var height: QDimensionBehaviour { set get }
    
    var mode: QInputDateViewMode { set get }
    
    var minimumDate: Date? { set get }
    
    var maximumDate: Date? { set get }
    
    var selectedDate: Date? { set get }
    
    var formatter: DateFormatter { set get }
    
    var locale: Locale { set get }
    
    var calendar: Calendar { set get }
    
    var timeZone: TimeZone? { set get }
    
    var textFont: QFont { set get }
    
    var textColor: QColor { set get }
    
    var textInset: QInset { set get }
    
    var placeholder: QInputPlaceholder { set get }
    
    var placeholderInset: QInset? { set get }
    
    var alignment: QTextAlignment { set get }
    
    #if os(iOS)
    
    var toolbar: IQInputToolbarView? { set get }
    
    #endif
    
    @discardableResult
    func width(_ value: QDimensionBehaviour) -> Self
    
    @discardableResult
    func height(_ value: QDimensionBehaviour) -> Self
    
    @discardableResult
    func mode(_ value: QInputDateViewMode) -> Self
    
    @discardableResult
    func minimumDate(_ value: Date?) -> Self
    
    @discardableResult
    func maximumDate(_ value: Date?) -> Self
    
    @discardableResult
    func selectedDate(_ value: Date?) -> Self
    
    @discardableResult
    func formatter(_ value: DateFormatter) -> Self
    
    @discardableResult
    func locale(_ value: Locale) -> Self
    
    @discardableResult
    func calendar(_ value: Calendar) -> Self
    
    @discardableResult
    func timeZone(_ value: TimeZone?) -> Self
    
    @discardableResult
    func textFont(_ value: QFont) -> Self
    
    @discardableResult
    func textColor(_ value: QColor) -> Self
    
    @discardableResult
    func textInset(_ value: QInset) -> Self
    
    @discardableResult
    func placeholder(_ value: QInputPlaceholder) -> Self
    
    @discardableResult
    func placeholderInset(_ value: QInset?) -> Self
    
    @discardableResult
    func alignment(_ value: QTextAlignment) -> Self
    
    #if os(iOS)
    
    @discardableResult
    func toolbar(_ value: IQInputToolbarView?) -> Self
    
    #endif
    
    @discardableResult
    func onBeginEditing(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onEditing(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onEndEditing(_ value: (() -> Void)?) -> Self
    
}
