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

open class QInputDateView : IQView {
    
    public typealias SimpleClosure = (_ inputDateView: QInputDateView) -> Void
    
    public private(set) weak var parentLayout: IQLayout?
    public weak var item: IQLayoutItem?
    public var width: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.parentLayout?.setNeedUpdate()
        }
    }
    public var height: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.parentLayout?.setNeedUpdate()
        }
    }
    public var mode: Mode {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qMode = self.mode
        }
    }
    public var minimumDate: Date? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qMinimumDate = self.minimumDate
        }
    }
    public var maximumDate: Date? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qMaximumDate = self.maximumDate
        }
    }
    public var selectedDate: Date? {
        set(value) {
            self._selectedDate = value
            guard self.isLoaded == true else { return }
            self._view.qSelectedDate = self._selectedDate
        }
        get { return self._selectedDate }
    }
    public var formatter: DateFormatter {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qFormatter = self.formatter
        }
    }
    public var locale: Locale {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qLocale = self.locale
        }
    }
    public var calendar: Calendar {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qCalendar = self.calendar
        }
    }
    public var timeZone: TimeZone? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qTimeZone = self.timeZone
        }
    }
    public var font: QFont {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qFont = self.font
        }
    }
    public var color: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qColor = self.color
        }
    }
    public var inset: QInset {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qInset = self.inset
        }
    }
    public var placeholder: QInputPlaceholder {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qPlaceholder = self.placeholder
        }
    }
    public var placeholderInset: QInset? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qPlaceholderInset = self.placeholderInset
        }
    }
    public var alignment: QTextAlignment {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qAlignment = self.alignment
        }
    }
    public var alpha: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qAlpha = self.alpha
        }
    }
    #if os(iOS)
    public var toolbar: QInputToolbarView? {
        didSet {
            self.toolbar?.delegate = self
            guard self.isLoaded == true else { return }
            self._view.qToolbar = self.toolbar
        }
    }
    #endif
    public var onBeginEditing: SimpleClosure?
    public var onSelected: SimpleClosure
    public var onEndEditing: SimpleClosure?
    public var isLoaded: Bool {
        return self._reuseView.isLoaded
    }
    public var isAppeared: Bool {
        guard self.isLoaded == true else { return false }
        return self._view.qIsAppeared
    }
    public var native: QNativeView {
        return self._view
    }
    
    private var _selectedDate: Date?
    private var _view: InputDateView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _reuseView: QReuseView< InputDateView >
    
    #if os(iOS)
    public init(
        width: QDimensionBehaviour,
        height: QDimensionBehaviour,
        mode: Mode,
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        selectedDate: Date? = nil,
        formatter: DateFormatter,
        locale: Locale = Locale.current,
        calendar: Calendar = Calendar.current,
        timeZone: TimeZone? = nil,
        font: QFont,
        color: QColor,
        inset: QInset = QInset(horizontal: 8, vertical: 4),
        placeholder: QInputPlaceholder,
        placeholderInset: QInset? = nil,
        alignment: QTextAlignment = .left,
        alpha: QFloat = 1,
        toolbar: QInputToolbarView? = nil,
        onBeginEditing: SimpleClosure? = nil,
        onSelected: @escaping SimpleClosure,
        onEndEditing: SimpleClosure? = nil
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
        self.font = font
        self.color = color
        self.inset = inset
        self.placeholder = placeholder
        self.placeholderInset = placeholderInset
        self.alignment = alignment
        self.alpha = alpha
        self.toolbar = toolbar
        self.onBeginEditing = onBeginEditing
        self.onSelected = onSelected
        self.onEndEditing = onEndEditing
        self._reuseView = QReuseView()
    }
    #else
    public init(
        width: QDimensionBehaviour,
        height: QDimensionBehaviour,
        mode: Mode,
        minimumDate: Date? = nil,
        maximumDate: Date? = nil,
        selectedDate: Date? = nil,
        formatter: DateFormatter,
        locale: Locale = Locale.current,
        calendar: Calendar = Calendar.current,
        timeZone: TimeZone? = nil,
        font: QFont,
        color: QColor,
        inset: QInset = QInset(horizontal: 8, vertical: 4),
        placeholder: QInputPlaceholder,
        placeholderInset: QInset? = nil,
        alignment: QTextAlignment = .left,
        alpha: QFloat = 1,
        onBeginEditing: SimpleClosure? = nil,
        onSelected: @escaping SimpleClosure,
        onEndEditing: SimpleClosure? = nil
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
        self.font = font
        self.color = color
        self.inset = inset
        self.placeholder = placeholder
        self.placeholderInset = placeholderInset
        self.alignment = alignment
        self.alpha = alpha
        self.onBeginEditing = onBeginEditing
        self.onSelected = onSelected
        self.onEndEditing = onEndEditing
        self._reuseView = QReuseView()
    }
    #endif
    
    public func onAppear(to layout: IQLayout) {
        self.parentLayout = layout
    }
    
    public func onDisappear() {
        self._reuseView.unload(view: self)
        self.parentLayout = nil
    }
    
    public func size(_ available: QSize) -> QSize {
        return available.apply(width: self.width, height: self.height)
    }

}

public extension QInputDateView {
    
    enum Mode {
        case time
        case date
        case dateTime
    }
    
}

#if os(iOS)

extension QInputDateView : QInputToolbarDelegate {
    
    public func pressed(_ toolbar: QInputToolbarView, item: IQInputToolbarItem) {
        guard self.toolbar === toolbar else { return }
        if let actionItem = item as? QInputToolbarActionItem< QInputDateView > {
            actionItem.callback(self)
        }
    }
    
}

#endif

extension QInputDateView: InputDateViewDelegate {
    
    func beginEditing() {
        self.onBeginEditing?(self)
    }
    
    func select(date: Date) {
        self._selectedDate = date
        self.onSelected(self)
    }
    
    func endEditing() {
        self.onEndEditing?(self)
    }
    
}
