//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QBarItemView : IQBarItemView {
    
    public var parentLayout: IQLayout? {
        get { return self._view.parentLayout }
    }
    public unowned var item: QLayoutItem? {
        set(value) { self._view.item = value }
        get { return self._view.item }
    }
    public var name: String {
        return self._view.name
    }
    public var native: QNativeView {
        return self._view.native
    }
    public var isLoaded: Bool {
        return self._view.isLoaded
    }
    public var isAppeared: Bool {
        return self._view.isAppeared
    }
    public var bounds: QRect {
        return self._view.bounds
    }
    public unowned var delegate: IQBarItemViewDelegate?
    public private(set) var contentInset: QInset {
        set(value) { self._layout.contentInset = value }
        get { return self._layout.contentInset }
    }
    public private(set) var contentView: IQView {
        didSet(oldValue) {
            guard self.contentView !== oldValue else { return }
            self._layout.contentItem = QLayoutItem(view: self.contentView)
        }
    }
    public var isHighlighted: Bool {
        return self._view.isHighlighted
    }
    public private(set) var isSelected: Bool {
        set(value) {
            if self._isSelected != value {
                self._isSelected = value
                self.triggeredChangeStyle(false)
            }
        }
        get { return self._isSelected }
    }
    public var color: QColor? {
        get { return self._view.color }
    }
    public var border: QViewBorder {
        get { return self._view.border }
    }
    public var cornerRadius: QViewCornerRadius {
        get { return self._view.cornerRadius }
    }
    public var shadow: QViewShadow? {
        get { return self._view.shadow }
    }
    public var alpha: QFloat {
        get { return self._view.alpha }
    }
    
    private var _layout: Layout
    private var _view: IQCustomView
    private var _tapGesture: IQTapGesture
    private var _isSelected: Bool
    
    public init(
        name: String? = nil,
        contentInset: QInset = QInset(horizontal: 8, vertical: 4),
        contentView: IQView,
        color: QColor? = nil,
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: QFloat = 1
    ) {
        let name = name ?? String(describing: Self.self)
        self.contentView = contentView
        self._layout = Layout(
            contentInset: contentInset,
            contentItem: QLayoutItem(view: contentView)
        )
        self._tapGesture = QTapGesture(name: "\(name)-TapGesture")
        self._isSelected = false
        self._view = QCustomView(
            name: name,
            gestures: [ self._tapGesture ],
            layout: self._layout,
            shouldHighlighting: true,
            isHighlighted: false,
            color: color,
            border: border,
            cornerRadius: cornerRadius,
            shadow: shadow,
            alpha: alpha
        )
        self._init()
    }
    
    public func size(_ available: QSize) -> QSize {
        return self._view.size(available)
    }
    
    public func appear(to layout: IQLayout) {
        self._view.appear(to: layout)
    }
    
    public func disappear() {
        self._view.disappear()
    }
    
    public func triggeredChangeStyle(_ userIteraction: Bool) {
        self._view.triggeredChangeStyle(userIteraction)
    }
    
    @discardableResult
    public func contentInset(_ value: QInset) -> Self {
        self.contentInset = value
        return self
    }
    
    @discardableResult
    public func contentView(_ value: IQView) -> Self {
        self.contentView = value
        return self
    }
    
    @discardableResult
    public func highlight(_ value: Bool) -> Self {
        self._view.highlight(value)
        return self
    }
    
    @discardableResult
    public func select(_ value: Bool) -> Self {
        self.isSelected = value
        return self
    }
    
    @discardableResult
    public func color(_ value: QColor?) -> Self {
        self._view.color(value)
        return self
    }
    
    @discardableResult
    public func border(_ value: QViewBorder) -> Self {
        self._view.border(value)
        return self
    }
    
    @discardableResult
    public func cornerRadius(_ value: QViewCornerRadius) -> Self {
        self._view.cornerRadius(value)
        return self
    }
    
    @discardableResult
    public func shadow(_ value: QViewShadow?) -> Self {
        self._view.shadow(value)
        return self
    }
    
    @discardableResult
    public func alpha(_ value: QFloat) -> Self {
        self._view.alpha(value)
        return self
    }
    
    @discardableResult
    public func onAppear(_ value: (() -> Void)?) -> Self {
        self._view.onAppear(value)
        return self
    }
    
    @discardableResult
    public func onDisappear(_ value: (() -> Void)?) -> Self {
        self._view.onDisappear(value)
        return self
    }
    
    @discardableResult
    public func onChangeStyle(_ value: ((Bool) -> Void)?) -> Self {
        self._view.onChangeStyle(value)
        return self
    }
    
}

private extension QBarItemView {
    
    func _init() {
        self._tapGesture.onTriggered({ [weak self] in
            guard let self = self else { return }
            self.delegate?.pressed(barItemView: self)
        })
    }
    
}

private extension QBarItemView {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var parentView: IQView?
        var contentInset: QInset {
            didSet { self.setNeedUpdate() }
        }
        var contentItem: QLayoutItem {
            didSet { self.setNeedUpdate() }
        }
        
        init(
            contentInset: QInset,
            contentItem: QLayoutItem
        ) {
            self.contentInset = contentInset
            self.contentItem = contentItem
        }
        
        func invalidate() {
        }
        
        func layout(bounds: QRect) -> QSize {
            self.contentItem.frame = bounds.apply(inset: self.contentInset)
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            let contentSize = self.contentItem.size(available.apply(inset: self.contentInset))
            let contentBounds = contentSize.apply(inset: -self.contentInset)
            return contentBounds
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            return [ self.contentItem ]
        }
        
    }
    
}
