//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QBarView : IQBarView {
    
    public var layout: IQLayout? {
        get { return self._view.layout }
    }
    public unowned var item: QLayoutItem? {
        set(value) { self._view.item = value }
        get { return self._view.item }
    }
    public var native: QNativeView {
        return self._view.native
    }
    public var isLoaded: Bool {
        return self._view.isLoaded
    }
    public var bounds: QRect {
        return self._view.bounds
    }
    public var isVisible: Bool {
        return self._view.isVisible
    }
    public var placement: QBarViewPlacement {
        set(value) { self._layout.placement = value }
        get { return self._layout.placement }
    }
    public var size: Float? {
        set(value) { self._layout.size = value }
        get { return self._layout.size }
    }
    public var safeArea: QInset {
        set(value) { self._layout.safeArea = value }
        get { return self._layout.safeArea }
    }
    public var contentView: IQView? {
        didSet(oldValue) {
            guard self.contentView !== oldValue else { return }
            self._layout.contentItem = self.contentView.flatMap({ QLayoutItem(view: $0) })
        }
    }
    public var color: QColor? {
        set(value) { self._view.color = value }
        get { return self._view.color }
    }
    public var cornerRadius: QViewCornerRadius {
        set(value) { self._view.cornerRadius = value }
        get { return self._view.cornerRadius }
    }
    public var border: QViewBorder {
        set(value) { self._view.border = value }
        get { return self._view.border }
    }
    public var shadow: QViewShadow? {
        set(value) { self._view.shadow = value }
        get { return self._view.shadow }
    }
    public var alpha: Float {
        set(value) { self._view.alpha = value }
        get { return self._view.alpha }
    }
    
    private var _layout: Layout
    private var _view: QCustomView< Layout >
    
    public init(
        placement: QBarViewPlacement,
        size: Float? = nil,
        contentView: IQView? = nil,
        color: QColor? = nil,
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1
    ) {
        self.contentView = contentView
        self._layout = Layout(
            placement: placement,
            size: size,
            safeArea: .zero,
            contentItem: contentView.flatMap({ QLayoutItem(view: $0) })
        )
        self._view = QCustomView(
            contentLayout: self._layout,
            color: color,
            border: border,
            cornerRadius: cornerRadius,
            shadow: shadow,
            alpha: alpha
        )
    }
    
    public func loadIfNeeded() {
        self._view.loadIfNeeded()
    }
    
    public func size(available: QSize) -> QSize {
        return self._view.size(available: available)
    }
    
    public func appear(to layout: IQLayout) {
        self._view.appear(to: layout)
    }
    
    public func disappear() {
        self._view.disappear()
    }
    
    public func visible() {
        self._view.visible()
    }
    
    public func visibility() {
        self._view.visibility()
    }
    
    public func invisible() {
        self._view.invisible()
    }
    
    @discardableResult
    public func placement(_ value: QBarViewPlacement) -> Self {
        self.placement = value
        return self
    }
    
    @discardableResult
    public func size(_ value: Float?) -> Self {
        self.size = value
        return self
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
    public func alpha(_ value: Float) -> Self {
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
    public func onVisible(_ value: (() -> Void)?) -> Self {
        self._view.onVisible(value)
        return self
    }
    
    @discardableResult
    public func onVisibility(_ value: (() -> Void)?) -> Self {
        self._view.onVisibility(value)
        return self
    }
    
    @discardableResult
    public func onInvisible(_ value: (() -> Void)?) -> Self {
        self._view.onInvisible(value)
        return self
    }
    
}

extension QBarView {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var placement: QBarViewPlacement {
            didSet { self.setNeedForceUpdate() }
        }
        var size: Float? {
            didSet { self.setNeedForceUpdate() }
        }
        var safeArea: QInset {
            didSet { self.setNeedForceUpdate() }
        }
        var contentItem: QLayoutItem? {
            didSet { self.setNeedForceUpdate(item: self.contentItem) }
        }
        
        init(
            placement: QBarViewPlacement,
            size: Float?,
            safeArea: QInset,
            contentItem: QLayoutItem?
        ) {
            self.placement = placement
            self.size = size
            self.safeArea = safeArea
            self.contentItem = contentItem
        }
        
        func layout(bounds: QRect) -> QSize {
            guard let contentItem = self.contentItem else { return .zero }
            let safeBounds = bounds.apply(inset: self.safeArea)
            switch self.placement {
            case .top:
                let height: Float
                if let size = self.size {
                    height = size
                } else {
                    let contentSize = contentItem.size(available: QSize(
                        width: bounds.width - self.safeArea.horizontal,
                        height: .infinity
                    ))
                    height = contentSize.height
                }
                contentItem.frame = QRect(
                    bottom: safeBounds.bottom,
                    width: safeBounds.width,
                    height: height
                )
                return QSize(
                    width: bounds.width,
                    height: height + self.safeArea.vertical
                )
            case .left:
                let width: Float
                if let size = self.size {
                    width = size
                } else {
                    let contentSize = contentItem.size(available: QSize(
                        width: .infinity,
                        height: bounds.height - self.safeArea.vertical
                    ))
                    width = contentSize.width
                }
                contentItem.frame = QRect(
                    right: safeBounds.right,
                    width: width,
                    height: safeBounds.height
                )
                return QSize(
                    width: width + self.safeArea.horizontal,
                    height: bounds.height
                )
            case .right:
                let width: Float
                if let size = self.size {
                    width = size
                } else {
                    let contentSize = contentItem.size(available: QSize(
                        width: .infinity,
                        height: bounds.height - self.safeArea.vertical
                    ))
                    width = contentSize.width
                }
                contentItem.frame = QRect(
                    left: safeBounds.left,
                    width: width,
                    height: safeBounds.height
                )
                return QSize(
                    width: width + self.safeArea.horizontal,
                    height: bounds.height
                )
            case .bottom:
                let height: Float
                if let size = self.size {
                    height = size
                } else {
                    let contentSize = contentItem.size(available: QSize(
                        width: bounds.width - self.safeArea.horizontal,
                        height: .infinity
                    ))
                    height = contentSize.height
                }
                contentItem.frame = QRect(
                    top: safeBounds.top,
                    width: safeBounds.width,
                    height: height
                )
                return QSize(
                    width: bounds.width,
                    height: height + self.safeArea.vertical
                )
            }
        }
        
        func size(available: QSize) -> QSize {
            guard let contentItem = self.contentItem else { return .zero }
            switch self.placement {
            case .top, .bottom:
                let height: Float
                if let size = self.size {
                    height = size
                } else {
                    let contentSize = contentItem.size(available: QSize(
                        width: available.width - self.safeArea.horizontal,
                        height: .infinity
                    ))
                    height = contentSize.height
                }
                return QSize(
                    width: available.width,
                    height: height + self.safeArea.vertical
                )
            case .left, .right:
                let width: Float
                if let size = self.size {
                    width = size
                } else {
                    let contentSize = contentItem.size(available: QSize(
                        width: .infinity,
                        height: available.height - self.safeArea.vertical
                    ))
                    width = contentSize.width
                }
                return QSize(
                    width: width + self.safeArea.horizontal,
                    height: available.height
                )
            }
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            guard let contentItem = self.contentItem else { return [] }
            return [ contentItem ]
        }
        
    }
    
}
