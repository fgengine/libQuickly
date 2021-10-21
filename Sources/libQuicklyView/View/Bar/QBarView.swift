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
    public var isHidden: Bool {
        set(value) { self._view.isHidden = value }
        get { return self._view.isHidden }
    }
    public var placement: QBarViewPlacement {
        set(value) { self._view.contentLayout.placement = value }
        get { return self._view.contentLayout.placement }
    }
    public var size: Float? {
        set(value) { self._view.contentLayout.size = value }
        get { return self._view.contentLayout.size }
    }
    public var safeArea: QInset {
        set(value) { self._view.contentLayout.safeArea = value }
        get { return self._view.contentLayout.safeArea }
    }
    public var separatorView: IQView? {
        didSet(oldValue) {
            guard self.separatorView !== oldValue else { return }
            self._view.contentLayout.separatorItem = self.separatorView.flatMap({ QLayoutItem(view: $0) })
        }
    }
    public var contentView: IQView? {
        didSet(oldValue) {
            guard self.contentView !== oldValue else { return }
            self._view.contentLayout.contentItem = self.contentView.flatMap({ QLayoutItem(view: $0) })
        }
    }
    public var color: QColor? {
        set(value) { self._backgroundView.color = value }
        get { return self._backgroundView.color }
    }
    public var cornerRadius: QViewCornerRadius {
        set(value) { self._backgroundView.cornerRadius = value }
        get { return self._backgroundView.cornerRadius }
    }
    public var border: QViewBorder {
        set(value) { self._backgroundView.border = value }
        get { return self._backgroundView.border }
    }
    public var shadow: QViewShadow? {
        set(value) { self._backgroundView.shadow = value }
        get { return self._backgroundView.shadow }
    }
    public var alpha: Float {
        set(value) { self._backgroundView.alpha = value }
        get { return self._backgroundView.alpha }
    }
    
    private var _view: QCustomView< Layout >
    private var _backgroundView: QEmptyView

    public init(
        placement: QBarViewPlacement,
        size: Float? = nil,
        separatorView: IQView? = nil,
        contentView: IQView? = nil,
        color: QColor? = nil,
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1,
        isHidden: Bool = false
    ) {
        self.separatorView = separatorView
        self.contentView = contentView
        self._backgroundView = QEmptyView(
            color: color,
            border: border,
            cornerRadius: cornerRadius,
            shadow: shadow,
            alpha: alpha
        )
        self._view = QCustomView(
            contentLayout: Layout(
                placement: placement,
                size: size,
                safeArea: .zero,
                separatorItem: separatorView.flatMap({ QLayoutItem(view: $0) }),
                contentItem: contentView.flatMap({ QLayoutItem(view: $0) }),
                backgroundItem: QLayoutItem(view: self._backgroundView)
            ),
            isHidden: isHidden
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
    public func separatorView(_ value: IQView?) -> Self {
        self.separatorView = value
        return self
    }
    
    @discardableResult
    public func contentView(_ value: IQView?) -> Self {
        self.contentView = value
        return self
    }
    
    @discardableResult
    public func color(_ value: QColor?) -> Self {
        self._backgroundView.color = value
        return self
    }
    
    @discardableResult
    public func border(_ value: QViewBorder) -> Self {
        self._backgroundView.border = value
        return self
    }
    
    @discardableResult
    public func cornerRadius(_ value: QViewCornerRadius) -> Self {
        self._backgroundView.cornerRadius = value
        return self
    }
    
    @discardableResult
    public func shadow(_ value: QViewShadow?) -> Self {
        self._backgroundView.shadow = value
        return self
    }
    
    @discardableResult
    public func alpha(_ value: Float) -> Self {
        self._backgroundView.alpha = value
        return self
    }
    
    @discardableResult
    public func hidden(_ value: Bool) -> Self {
        self._view.hidden(value)
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
        var separatorItem: QLayoutItem? {
            didSet { self.setNeedForceUpdate(item: self.separatorItem) }
        }
        var contentItem: QLayoutItem? {
            didSet { self.setNeedForceUpdate(item: self.contentItem) }
        }
        var backgroundItem: QLayoutItem {
            didSet { self.setNeedForceUpdate(item: self.backgroundItem) }
        }
        
        init(
            placement: QBarViewPlacement,
            size: Float?,
            safeArea: QInset,
            separatorItem: QLayoutItem?,
            contentItem: QLayoutItem?,
            backgroundItem: QLayoutItem
        ) {
            self.placement = placement
            self.size = size
            self.safeArea = safeArea
            self.separatorItem = separatorItem
            self.contentItem = contentItem
            self.backgroundItem = backgroundItem
        }
        
        func layout(bounds: QRect) -> QSize {
            guard let contentItem = self.contentItem else { return .zero }
            let safeBounds = bounds.apply(inset: self.safeArea)
            switch self.placement {
            case .top:
                let separatorHeight: Float
                if let separatorItem = self.separatorItem {
                    let separatorSize = separatorItem.size(available: QSize(
                        width: bounds.width,
                        height: .infinity
                    ))
                    separatorItem.frame = QRect(
                        bottomLeft: safeBounds.bottomLeft,
                        size: separatorSize
                    )
                    separatorHeight = separatorSize.height
                } else {
                    separatorHeight = 0
                }
                let contentHeight: Float
                if let size = self.size {
                    contentHeight = size
                } else {
                    let contentSize = contentItem.size(available: QSize(
                        width: bounds.width - self.safeArea.horizontal,
                        height: .infinity
                    ))
                    contentHeight = contentSize.height
                }
                contentItem.frame = QRect(
                    bottom: safeBounds.bottom + QPoint(x: 0, y: separatorHeight),
                    width: safeBounds.width,
                    height: contentHeight
                )
                self.backgroundItem.frame = QRect(
                    topLeft: bounds.topLeft,
                    bottomRight: contentItem.frame.bottomRight
                )
                return QSize(
                    width: bounds.width,
                    height: separatorHeight + contentHeight + self.safeArea.vertical
                )
            case .bottom:
                let separatorHeight: Float
                if let separatorItem = self.separatorItem {
                    let separatorSize = separatorItem.size(available: QSize(
                        width: bounds.width,
                        height: .infinity
                    ))
                    separatorItem.frame = QRect(
                        topLeft: safeBounds.topLeft,
                        size: separatorSize
                    )
                    separatorHeight = separatorSize.height
                } else {
                    separatorHeight = 0
                }
                let contentHeight: Float
                if let size = self.size {
                    contentHeight = size
                } else {
                    let contentSize = contentItem.size(available: QSize(
                        width: bounds.width - self.safeArea.horizontal,
                        height: .infinity
                    ))
                    contentHeight = contentSize.height
                }
                contentItem.frame = QRect(
                    top: safeBounds.top + QPoint(x: 0, y: separatorHeight),
                    width: safeBounds.width,
                    height: contentHeight
                )
                self.backgroundItem.frame = QRect(
                    topLeft: contentItem.frame.topLeft,
                    bottomRight: bounds.bottomRight
                )
                return QSize(
                    width: bounds.width,
                    height: separatorHeight + contentHeight + self.safeArea.vertical
                )
            }
        }
        
        func size(available: QSize) -> QSize {
            guard let contentItem = self.contentItem else { return .zero }
            var height: Float
            if let size = self.size {
                height = size
            } else {
                let contentSize = contentItem.size(available: QSize(
                    width: available.width - self.safeArea.horizontal,
                    height: .infinity
                ))
                height = contentSize.height
            }
            if let separatorItem = self.separatorItem {
                let separatorSize = separatorItem.size(available: QSize(
                    width: available.width - self.safeArea.horizontal,
                    height: .infinity
                ))
                height += separatorSize.height
            }
            return QSize(
                width: available.width,
                height: height + self.safeArea.vertical
            )
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            var items: [QLayoutItem] = [
                self.backgroundItem
            ]
            if let separatorItem = self.separatorItem {
                items.append(separatorItem)
            }
            if let contentItem = self.contentItem {
                items.append(contentItem)
            }
            return items
        }
        
    }
    
}
