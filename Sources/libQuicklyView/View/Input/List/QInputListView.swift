//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

protocol InputListViewDelegate : AnyObject {
    
    func beginEditing()
    func select(item: IQInputListViewItem)
    func endEditing()
    
}

public class QInputListView : IQInputListView {
    
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
    public private(set) var isVisible: Bool
    public var isHidden: Bool {
        didSet(oldValue) {
            guard self.isHidden != oldValue else { return }
            self.setNeedForceLayout()
        }
    }
    public var isEditing: Bool {
        guard self.isLoaded == true else { return false }
        return self._view.isFirstResponder
    }
    public var width: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.setNeedForceLayout()
        }
    }
    public var height: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.setNeedForceLayout()
        }
    }
    public var items: [IQInputListViewItem] {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.update(items: self.items)
        }
    }
    public var selectedItem: IQInputListViewItem? {
        set(value) {
            self._selectedItem = value
            guard self.isLoaded == true else { return }
            self._view.update(selectedItem: self._selectedItem, userIteraction: false)
        }
        get { return self._selectedItem }
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
    
    private var _reuse: QReuseItem< InputListView >
    private var _view: InputListView {
        return self._reuse.content()
    }
    private var _selectedItem: IQInputListViewItem?
    private var _onAppear: (() -> Void)?
    private var _onDisappear: (() -> Void)?
    private var _onVisible: (() -> Void)?
    private var _onVisibility: (() -> Void)?
    private var _onInvisible: (() -> Void)?
    private var _onBeginEditing: (() -> Void)?
    private var _onEditing: (() -> Void)?
    private var _onEndEditing: (() -> Void)?
    
    public init(
        reuseBehaviour: QReuseItemBehaviour = .unloadWhenDisappear,
        reuseName: String? = nil,
        width: QDimensionBehaviour,
        height: QDimensionBehaviour,
        items: [IQInputListViewItem],
        selectedItem: IQInputListViewItem? = nil,
        textFont: QFont,
        textColor: QColor,
        textInset: QInset = QInset(horizontal: 8, vertical: 4),
        placeholder: QInputPlaceholder,
        placeholderInset: QInset? = nil,
        alignment: QTextAlignment = .left,
        color: QColor? = nil,
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1,
        isHidden: Bool = false
    ) {
        self.isVisible = false
        self.width = width
        self.height = height
        self.items = items
        self._selectedItem = selectedItem
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
        self.isHidden = isHidden
        self._reuse = QReuseItem(behaviour: reuseBehaviour, name: reuseName)
        self._reuse.configure(owner: self)
    }
    
    deinit {
        self._reuse.destroy()
    }
    
    public func loadIfNeeded() {
        self._reuse.loadIfNeeded()
    }
    
    public func size(available: QSize) -> QSize {
        guard self.isHidden == false else { return .zero }
        return available.apply(width: self.width, height: self.height)
    }
    
    public func appear(to layout: IQLayout) {
        self.layout = layout
        self.toolbar?.appear(to: self)
        self._onAppear?()
    }
    
    public func disappear() {
        self.toolbar?.disappear()
        self._reuse.disappear()
        self.layout = nil
        self._onDisappear?()
    }
    
    public func visible() {
        self.isVisible = true
        self._onVisible?()
    }
    
    public func visibility() {
        self._onVisibility?()
    }
    
    public func invisible() {
        self.isVisible = false
        self._onInvisible?()
    }
    
    @discardableResult
    public func startEditing() -> Self {
        self._view.becomeFirstResponder()
        return self
    }
    
    @discardableResult
    public func endEditing() -> Self {
        self._view.endEditing(false)
        return self
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
    public func items(_ value: [IQInputListViewItem]) -> Self {
        self.items = value
        return self
    }
    
    @discardableResult
    public func selectedItem(_ value: IQInputListViewItem?) -> Self {
        self.selectedItem = value
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
    public func hidden(_ value: Bool) -> Self {
        self.isHidden = value
        return self
    }
    
    @discardableResult
    public func onAppear(_ value: (() -> Void)?) -> Self {
        self._onAppear = value
        return self
    }
    
    @discardableResult
    public func onVisible(_ value: (() -> Void)?) -> Self {
        self._onVisible = value
        return self
    }
    
    @discardableResult
    public func onVisibility(_ value: (() -> Void)?) -> Self {
        self._onVisibility = value
        return self
    }
    
    @discardableResult
    public func onInvisible(_ value: (() -> Void)?) -> Self {
        self._onInvisible = value
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

public extension QInputListView {
    
    class Item< Value > : IQInputListViewItem {
        
        public var title: String
        public var value: Value
        
        public init(
            title: String,
            value: Value
        ) {
            self.title = title
            self.value = value
        }
        
    }
    
}

extension QInputListView: InputListViewDelegate {
    
    func beginEditing() {
        self._onBeginEditing?()
    }
    
    func select(item: IQInputListViewItem) {
        self._selectedItem = item
        self._view.update(selectedItem: item, userIteraction: true)
        self._onEditing?()
    }
    
    func endEditing() {
        self._onEndEditing?()
    }
    
}
