//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

protocol InputDateViewDelegate : AnyObject {
    
    func beginEditing()
    func select(date: Date)
    func endEditing()
    
}

public class QInputDateView : IQInputDateView {
    
    public private(set) unowned var layout: IQLayout?
    public unowned var item: QLayoutItem?
    public var native: QNativeView {
        return self._view
    }
    public var isLoaded: Bool {
        return self._reuse.isLoaded
    }
    public var bounds: QRect {
        guard self.isLoaded == true else { return QRect() }
        return QRect(self._view.bounds)
    }
    public private(set) var width: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.setNeedForceUpdate()
        }
    }
    public private(set) var height: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.setNeedForceUpdate()
        }
    }
    public private(set) var mode: QInputDateViewMode {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(mode: self.mode)
        }
    }
    public private(set) var minimumDate: Date? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(minimumDate: self.minimumDate)
        }
    }
    public private(set) var maximumDate: Date? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(maximumDate: self.maximumDate)
        }
    }
    public private(set) var selectedDate: Date? {
        set(value) {
            self._selectedDate = value
            guard self.isLoaded == true else { return }
            self._view.update(selectedDate: self._selectedDate)
        }
        get { return self._selectedDate }
    }
    public private(set) var formatter: DateFormatter {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(formatter: self.formatter)
        }
    }
    public private(set) var locale: Locale {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(locale: self.locale)
        }
    }
    public private(set) var calendar: Calendar {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(calendar: self.calendar)
        }
    }
    public private(set) var timeZone: TimeZone? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(timeZone: self.timeZone)
        }
    }
    public private(set) var textFont: QFont {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(textFont: self.textFont)
        }
    }
    public private(set) var textColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(textColor: self.textColor)
        }
    }
    public private(set) var textInset: QInset {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(textInset: self.textInset)
        }
    }
    public private(set) var placeholder: QInputPlaceholder {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(placeholder: self.placeholder)
        }
    }
    public private(set) var placeholderInset: QInset? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(placeholderInset: self.placeholderInset)
        }
    }
    public private(set) var alignment: QTextAlignment {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(alignment: self.alignment)
        }
    }
    #if os(iOS)
    public private(set) var toolbar: IQInputToolbarView? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(toolbar: self.toolbar)
        }
    }
    #endif
    public private(set) var color: QColor? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(color: self.color)
        }
    }
    public private(set) var cornerRadius: QViewCornerRadius {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(cornerRadius: self.cornerRadius)
        }
    }
    public private(set) var border: QViewBorder {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(border: self.border)
        }
    }
    public private(set) var shadow: QViewShadow? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(shadow: self.shadow)
        }
    }
    public private(set) var alpha: Float {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(alpha: self.alpha)
        }
    }
    
    private var _reuse: QReuseItem< InputDateView >
    private var _view: InputDateView {
        if self.isLoaded == false { self._reuse.load(owner: self) }
        return self._reuse.content!
    }
    private var _selectedDate: Date?
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    private var _onBeginEditing: (() -> Void)?
    private var _onEditing: (() -> Void)?
    private var _onEndEditing: (() -> Void)?
    
    public init(
        width: QDimensionBehaviour,
        height: QDimensionBehaviour,
        mode: QInputDateViewMode,
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        selectedDate: Date? = nil,
        formatter: DateFormatter,
        locale: Locale = Locale.current,
        calendar: Calendar = Calendar.current,
        timeZone: TimeZone? = nil,
        textFont: QFont,
        textColor: QColor,
        textInset: QInset = QInset(horizontal: 8, vertical: 4),
        placeholder: QInputPlaceholder,
        placeholderInset: QInset? = nil,
        alignment: QTextAlignment = .left,
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1
    ) {
        self.width = width
        self.height = height
        self.mode = mode
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        self._selectedDate = selectedDate
        self.formatter = formatter
        self.locale = locale
        self.calendar = calendar
        self.timeZone = timeZone
        self.textFont = textFont
        self.textColor = textColor
        self.textInset = textInset
        self.placeholder = placeholder
        self.placeholderInset = placeholderInset
        self.alignment = alignment
        self.color = color
        self.border = border
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.alpha = alpha
        self._reuse = QReuseItem()
    }
    
    public func size(_ available: QSize) -> QSize {
        return available.apply(width: self.width, height: self.height)
    }
    
    public func appear(to layout: IQLayout) {
        self.layout = layout
        self.toolbar?.appear(to: self)
        self._onAppear?()
    }
    
    public func disappear() {
        self.toolbar?.disappear()
        self._reuse.unload(owner: self)
        self.layout = nil
        self._onDisappear?()
    }
    
    @discardableResult
    public func width(_ value: QDimensionBehaviour) -> Self {
        self.width = value
        return self
    }
    
    @discardableResult
    public func height(_ value: QDimensionBehaviour) -> Self {
        self.height = value
        return self
    }
    
    @discardableResult
    public func mode(_ value: QInputDateViewMode) -> Self {
        self.mode = value
        return self
    }
    
    @discardableResult
    public func minimumDate(_ value: Date?) -> Self {
        self.minimumDate = value
        return self
    }
    
    @discardableResult
    public func maximumDate(_ value: Date?) -> Self {
        self.maximumDate = value
        return self
    }
    
    @discardableResult
    public func selectedDate(_ value: Date?) -> Self {
        self.selectedDate = value
        return self
    }
    
    @discardableResult
    public func formatter(_ value: DateFormatter) -> Self {
        self.formatter = value
        return self
    }
    
    @discardableResult
    public func locale(_ value: Locale) -> Self {
        self.locale = value
        return self
    }
    
    @discardableResult
    public func calendar(_ value: Calendar) -> Self {
        self.calendar = value
        return self
    }
    
    @discardableResult
    public func timeZone(_ value: TimeZone?) -> Self {
        self.timeZone = value
        return self
    }
    
    @discardableResult
    public func textFont(_ value: QFont) -> Self {
        self.textFont = value
        return self
    }
    
    @discardableResult
    public func textColor(_ value: QColor) -> Self {
        self.textColor = value
        return self
    }
    
    @discardableResult
    public func textInset(_ value: QInset) -> Self {
        self.textInset = value
        return self
    }
    
    @discardableResult
    public func placeholder(_ value: QInputPlaceholder) -> Self {
        self.placeholder = value
        return self
    }
    
    @discardableResult
    public func placeholderInset(_ value: QInset?) -> Self {
        self.placeholderInset = value
        return self
    }
    
    @discardableResult
    public func alignment(_ value: QTextAlignment) -> Self {
        self.alignment = value
        return self
    }
        
    #if os(iOS)
    
    @discardableResult
    public func toolbar(_ value: IQInputToolbarView?) -> Self {
        self.toolbar = value
        return self
    }
    
    #endif
    
    @discardableResult
    public func color(_ value: QColor?) -> Self {
        self.color = value
        return self
    }
    
    @discardableResult
    public func border(_ value: QViewBorder) -> Self {
        self.border = value
        return self
    }
    
    @discardableResult
    public func cornerRadius(_ value: QViewCornerRadius) -> Self {
        self.cornerRadius = value
        return self
    }
    
    @discardableResult
    public func shadow(_ value: QViewShadow?) -> Self {
        self.shadow = value
        return self
    }
    
    @discardableResult
    public func alpha(_ value: Float) -> Self {
        self.alpha = value
        return self
    }
    
    @discardableResult
    public func onAppear(_ value: (() -> Void)?) -> Self {
        self._onAppear = value
        return self
    }
    
    @discardableResult
    public func onDisappear(_ value: (() -> Void)?) -> Self {
        self._onDisappear = value
        return self
    }
    
    @discardableResult
    public func onBeginEditing(_ value: (() -> Void)?) -> Self {
        self._onBeginEditing = value
        return self
    }
    
    @discardableResult
    public func onEditing(_ value: (() -> Void)?) -> Self {
        self._onEditing = value
        return self
    }
    
    @discardableResult
    public func onEndEditing(_ value: (() -> Void)?) -> Self {
        self._onEndEditing = value
        return self
    }

}

extension QInputDateView: InputDateViewDelegate {
    
    func beginEditing() {
        self._onBeginEditing?()
    }
    
    func select(date: Date) {
        self._selectedDate = date
        self._onEditing?()
    }
    
    func endEditing() {
        self._onEndEditing?()
    }
    
}
