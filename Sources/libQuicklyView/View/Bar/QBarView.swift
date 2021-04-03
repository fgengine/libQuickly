//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QBarView : IQBarView {
    
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
    public private(set) var safeArea: QInset {
        set(value) {
            self._layout.safeArea = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.safeArea }
    }
    public private(set) var contentView: IQView? {
        didSet(oldValue) {
            guard self.contentView !== oldValue else { return }
            self._layout.contentItem = contentView.flatMap({ QLayoutItem(view: $0) })
            self._layout.setNeedUpdate()
        }
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
    
    public init(
        name: String? = nil,
        contentView: IQView? = nil,
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: QFloat = 1
    ) {
        let name = name ?? String(describing: Self.self)
        self.contentView = contentView
        self._layout = Layout(
            safeArea: QInset(),
            contentItem: contentView.flatMap({ QLayoutItem(view: $0) })
        )
        self._view = QCustomView(
            name: name,
            layout: self._layout,
            color: color,
            border: border,
            cornerRadius: cornerRadius,
            shadow: shadow,
            alpha: alpha
        )
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
    
    @discardableResult
    public func safeArea(_ value: QInset) -> Self {
        self.safeArea = value
        return self
    }
    
    @discardableResult
    public func contentView(_ value: IQView?) -> Self {
        self.contentView = value
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
    
}

extension QBarView {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var parentView: IQView?
        var safeArea: QInset
        var contentItem: QLayoutItem?
        var items: [QLayoutItem] {
            guard let contentItem = self.contentItem else { return [] }
            return [ contentItem ]
        }
        
        init(
            safeArea: QInset,
            contentItem: QLayoutItem?
        ) {
            self.safeArea = safeArea
            self.contentItem = contentItem
        }
        
        func invalidate() {
        }
        
        func layout(bounds: QRect) -> QSize {
            guard let contentItem = self.contentItem else { return QSize() }
            contentItem.frame = bounds.apply(inset: self.safeArea)
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            guard let contentItem = self.contentItem else { return QSize() }
            let contentSize = contentItem.size(available.apply(inset: self.safeArea))
            return QSize(
                width: contentSize.width + (self.safeArea.left + self.safeArea.right),
                height: contentSize.height + (self.safeArea.top + self.safeArea.bottom)
            )
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            guard let contentItem = self.contentItem else { return [] }
            return self.visible(items: [ contentItem ], for: bounds)
        }
        
    }
    
}
