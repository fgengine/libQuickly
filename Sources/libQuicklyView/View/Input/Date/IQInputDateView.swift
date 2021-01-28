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

    var width: QDimensionBehaviour { get }
    
    var height: QDimensionBehaviour { get }
    
    var mode: QInputDateViewMode { get }
    
    var minimumDate: Date? { get }
    
    var maximumDate: Date? { get }
    
    var selectedDate: Date? { get }
    
    var formatter: DateFormatter { get }
    
    var locale: Locale { get }
    
    var calendar: Calendar { get }
    
    var timeZone: TimeZone? { get }
    
    var textFont: QFont { get }
    
    var textColor: QColor { get }
    
    var textInset: QInset { get }
    
    var placeholder: QInputPlaceholder { get }
    
    var placeholderInset: QInset? { get }
    
    var alignment: QTextAlignment { get }
    
    #if os(iOS)
    
    var toolbar: IQInputToolbarView? { get }
    
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
