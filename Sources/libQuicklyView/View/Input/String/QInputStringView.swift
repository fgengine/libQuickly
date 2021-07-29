//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

protocol InputStringViewDelegate : AnyObject {
    
    func beginEditing()
    func editing(text: String)
    func endEditing()
    
}

public class QInputStringView : IQInputStringView {
    
    public private(set) unowned var layout: IQLayout?
    public unowned var item: QLayoutItem?
    public var native: QNativeView {
        return self._view
    }
    public var isLoaded: Bool {
        return self._reuse.isLoaded
    }
    public var bounds: QRect {
        guard self.isLoaded == true else { return .zero }
        return QRect(self._view.bounds)
    }
    public var width: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.setNeedForceUpdate()
        }
    }
    public var height: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.setNeedForceUpdate()
        }
    }
    public var text: String {
        set(value) {
            self._text = value
            guard self.isLoaded == true else { return }
            self._view.update(text: self._text)
        }
        get { return self._text }
    }
    public var textFont: QFont {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(textFont: self.textFont)
        }
    }
    public var textColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(textColor: self.textColor)
        }
    }
    public var textInset: QInset {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(textInset: self.textInset)
        }
    }
    public var editingColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(editingColor: self.editingColor)
        }
    }
    public var placeholder: QInputPlaceholder {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(placeholder: self.placeholder)
        }
    }
    public var placeholderInset: QInset? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(placeholderInset: self.placeholderInset)
        }
    }
    public var alignment: QTextAlignment {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(alignment: self.alignment)
        }
    }
    #if os(iOS)
    public var toolbar: IQInputToolbarView? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(toolbar: self.toolbar)
        }
    }
    public var keyboard: QInputKeyboard? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(keyboard: self.keyboard)
        }
    }
    #endif
    public var color: QColor? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(color: self.color)
        }
    }
    public var cornerRadius: QViewCornerRadius {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(cornerRadius: self.cornerRadius)
        }
    }
    public var border: QViewBorder {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(border: self.border)
        }
    }
    public var shadow: QViewShadow? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(shadow: self.shadow)
        }
    }
    public var alpha: Float {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(alpha: self.alpha)
        }
    }

    private var _reuse: QReuseItem< InputStringView >
    private var _view: InputStringView {
        if self.isLoaded == false { self._reuse.load(owner: self) }
        return self._reuse.content!
    }
    private var _text: String
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    private var _onBeginEditing: (() -> Void)?
    private var _onEditing: (() -> Void)?
    private var _onEndEditing: (() -> Void)?

    public init(
        width: QDimensionBehaviour,
        height: QDimensionBehaviour,
        text: String,
        textFont: QFont,
        textColor: QColor,
        textInset: QInset = QInset(horizontal: 8, vertical: 4),
        editingColor: QColor,
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
        self.textFont = textFont
        self.textColor = textColor
        self.textInset = textInset
        self.editingColor = editingColor
        self.placeholder = placeholder
        self.placeholderInset = placeholderInset
        self.alignment = alignment
        self.color = color
        self.border = border
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.alpha = alpha
        self._text = text
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
    public func text(_ value: String) -> Self {
        self.text = value
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
    public func editingColor(_ value: QColor) -> Self {
        self.editingColor = value
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
    
    @discardableResult
    public func keyboard(_ value: QInputKeyboard?) -> Self {
        self.keyboard = value
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

extension QInputStringView: InputStringViewDelegate {
    
    func beginEditing() {
        self._onBeginEditing?()
    }
    
    func editing(text: String) {
        self._text = text
        self._onEditing?()
    }
    
    func endEditing() {
        self._onEndEditing?()
    }
    
}
