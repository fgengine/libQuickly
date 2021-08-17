//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QStackBarView : QBarView, IQStackBarView {
    
    public var inset: QInset {
        set(value) { self._contentLayout.inset = value }
        get { return self._contentLayout.inset }
    }
    public var headerView: IQView? {
        didSet(oldValue) {
            guard self.headerView !== oldValue else { return }
            self._contentLayout.headerItem = self.headerView.flatMap({ QLayoutItem(view: $0) })
        }
    }
    public var headerSpacing: Float {
        set(value) { self._contentLayout.headerSpacing = value }
        get { return self._contentLayout.headerSpacing }
    }
    public var leadingViews: [IQView] {
        didSet(oldValue) {
            self._contentLayout.leadingItems = self.leadingViews.compactMap({ QLayoutItem(view: $0) })
        }
    }
    public var leadingViewSpacing: Float {
        set(value) { self._contentLayout.leadingItemSpacing = value }
        get { return self._contentLayout.leadingItemSpacing }
    }
    public var titleView: IQView? {
        didSet(oldValue) {
            guard self.titleView !== oldValue else { return }
            self._contentLayout.titleItem = self.titleView.flatMap({ QLayoutItem(view: $0) })
        }
    }
    public var titleSpacing: Float {
        set(value) { self._contentLayout.titleSpacing = value }
        get { return self._contentLayout.titleSpacing }
    }
    public var trailingViews: [IQView] {
        didSet(oldValue) {
            self._contentLayout.trailingItems = self.trailingViews.compactMap({ QLayoutItem(view: $0) })
        }
    }
    public var trailingViewSpacing: Float {
        set(value) { self._contentLayout.trailingItemSpacing = value }
        get { return self._contentLayout.trailingItemSpacing }
    }
    public var footerView: IQView? {
        didSet(oldValue) {
            guard self.footerView !== oldValue else { return }
            self._contentLayout.footerItem = self.footerView.flatMap({ QLayoutItem(view: $0) })
        }
    }
    public var footerSpacing: Float {
        set(value) { self._contentLayout.footerSpacing = value }
        get { return self._contentLayout.footerSpacing }
    }

    private var _contentLayout: Layout
    private var _contentView: QCustomView< Layout >
    
    public init(
        inset: QInset,
        headerView: IQView? = nil,
        headerSpacing: Float = 8,
        leadingViews: [IQView] = [],
        leadingViewSpacing: Float = 4,
        titleView: IQView? = nil,
        titleSpacing: Float = 4,
        trailingViews: [IQView] = [],
        trailingViewSpacing: Float = 4,
        footerView: IQView? = nil,
        footerSpacing: Float = 8,
        color: QColor? = nil,
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1
    ) {
        self.headerView = headerView
        self.leadingViews = leadingViews
        self.titleView = titleView
        self.trailingViews = trailingViews
        self.footerView = footerView
        self._contentLayout = Layout(
            inset: inset,
            headerItem: headerView.flatMap({ QLayoutItem(view: $0) }),
            headerSpacing: headerSpacing,
            leadingItems: leadingViews.compactMap({ QLayoutItem(view: $0) }),
            leadingItemSpacing: leadingViewSpacing,
            titleItem: titleView.flatMap({ QLayoutItem(view: $0) }),
            titleSpacing: titleSpacing,
            trailingItems: trailingViews.compactMap({ QLayoutItem(view: $0) }),
            trailingItemSpacing: trailingViewSpacing,
            footerItem: footerView.flatMap({ QLayoutItem(view: $0) }),
            footerSpacing: footerSpacing
        )
        self._contentView = QCustomView(
            contentLayout: self._contentLayout
        )
        super.init(
            placement: .top,
            contentView: self._contentView,
            color: color,
            border: border,
            cornerRadius: cornerRadius,
            shadow: shadow,
            alpha: alpha
        )
    }
    
    @discardableResult
    public func inset(_ value: QInset) -> Self {
        self.inset = value
        return self
    }
    
    @discardableResult
    public func headerView(_ value: IQView?) -> Self {
        self.headerView = value
        return self
    }
    
    @discardableResult
    public func headerSpacing(_ value: Float) -> Self {
        self.headerSpacing = value
        return self
    }
    
    @discardableResult
    public func leadingViews(_ value: [IQView]) -> Self {
        self.leadingViews = value
        return self
    }
    
    @discardableResult
    public func leadingViewSpacing(_ value: Float) -> Self {
        self.leadingViewSpacing = value
        return self
    }
    
    @discardableResult
    public func titleView(_ value: IQView?) -> Self {
        self.titleView = value
        return self
    }
    
    @discardableResult
    public func titleSpacing(_ value: Float) -> Self {
        self.titleSpacing = value
        return self
    }
    
    @discardableResult
    public func trailingViews(_ value: [IQView]) -> Self {
        self.trailingViews = value
        return self
    }
    
    @discardableResult
    public func trailingViewSpacing(_ value: Float) -> Self {
        self.trailingViewSpacing = value
        return self
    }
    
    @discardableResult
    public func footerView(_ value: IQView?) -> Self {
        self.footerView = value
        return self
    }
    
    @discardableResult
    public func footerSpacing(_ value: Float) -> Self {
        self.footerSpacing = value
        return self
    }
    
}

private extension QStackBarView {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var inset: QInset {
            didSet { self.setNeedForceUpdate() }
        }
        var headerItem: QLayoutItem? {
            didSet { self.setNeedForceUpdate() }
        }
        var headerSpacing: Float {
            didSet { self.setNeedForceUpdate() }
        }
        var leadingItems: [QLayoutItem] {
            didSet {
                self._leadingItemsCache = Array< QSize? >(repeating: nil, count: self.leadingItems.count)
                self.setNeedForceUpdate()
            }
        }
        var leadingItemSpacing: Float {
            didSet { self.setNeedForceUpdate() }
        }
        var titleItem: QLayoutItem? {
            didSet { self.setNeedForceUpdate() }
        }
        var titleSpacing: Float {
            didSet { self.setNeedForceUpdate() }
        }
        var trailingItems: [QLayoutItem] {
            didSet {
                self._trailingItemsCache = Array< QSize? >(repeating: nil, count: self.trailingItems.count)
                self.setNeedForceUpdate()
            }
        }
        var trailingItemSpacing: Float {
            didSet { self.setNeedForceUpdate() }
        }
        var footerItem: QLayoutItem? {
            didSet { self.setNeedForceUpdate() }
        }
        var footerSpacing: Float {
            didSet { self.setNeedForceUpdate() }
        }
        
        private var _leadingItemsCache: [QSize?]
        private var _trailingItemsCache: [QSize?]

        init(
            inset: QInset,
            headerItem: QLayoutItem?,
            headerSpacing: Float,
            leadingItems: [QLayoutItem],
            leadingItemSpacing: Float,
            titleItem: QLayoutItem?,
            titleSpacing: Float,
            trailingItems: [QLayoutItem],
            trailingItemSpacing: Float,
            footerItem: QLayoutItem?,
            footerSpacing: Float
        ) {
            self.inset = inset
            self.headerItem = headerItem
            self.headerSpacing = headerSpacing
            self.leadingItems = leadingItems
            self.leadingItemSpacing = leadingItemSpacing
            self.titleItem = titleItem
            self.titleSpacing = titleSpacing
            self.trailingItems = trailingItems
            self.trailingItemSpacing = trailingItemSpacing
            self.footerItem = footerItem
            self.footerSpacing = footerSpacing
            self._leadingItemsCache = Array< QSize? >(repeating: nil, count: leadingItems.count)
            self._trailingItemsCache = Array< QSize? >(repeating: nil, count: trailingItems.count)
        }
        
        func invalidate(item: QLayoutItem) {
            if let index = self.leadingItems.firstIndex(where: { $0 === item }) {
                self._leadingItemsCache.remove(at: index)
            }
            if let index = self.trailingItems.firstIndex(where: { $0 === item }) {
                self._trailingItemsCache.remove(at: index)
            }
        }
        
        func layout(bounds: QRect) -> QSize {
            let availableSize = QSize(
                width: bounds.width - self.inset.horizontal,
                height: .infinity
            )
            var origin = self.inset.top
            if let headerItem = self.headerItem {
                let headerSize = headerItem.size(availableSize)
                headerItem.frame = QRect(
                    x: bounds.x + self.inset.left,
                    y: bounds.y + origin,
                    width: headerSize.width,
                    height: headerSize.height
                )
                origin += headerSize.height + self.headerSpacing
            }
            let headerBounds = QRect(
                x: bounds.x + self.inset.left,
                y: bounds.y + origin,
                width: availableSize.width,
                height: .infinity
            )
            let leadingSize = QListLayout.Helper.layout(
                bounds: headerBounds,
                direction: .horizontal,
                origin: .forward,
                inset: .zero,
                spacing: self.leadingItemSpacing,
                items: self.leadingItems,
                cache: &self._leadingItemsCache
            )
            let trailingSize = QListLayout.Helper.layout(
                bounds: headerBounds,
                direction: .horizontal,
                origin: .backward,
                inset: .zero,
                spacing: self.trailingItemSpacing,
                items: self.trailingItems,
                cache: &self._trailingItemsCache
            )
            if let titleItem = self.titleItem {
                let leadingSpacing = self.leadingItems.count > 0 ? self.titleSpacing : 0
                let trailingSpacing = self.trailingItems.count > 0 ? self.titleSpacing : 0
                let titleSize = titleItem.size(QSize(
                    width: availableSize.width - (leadingSize.width + leadingSpacing) - (trailingSize.width + trailingSpacing),
                    height: max(leadingSize.height, trailingSize.height)
                ))
                titleItem.frame = QRect(
                    x: bounds.x + self.inset.left + (leadingSize.width + leadingSpacing),
                    y: bounds.y + origin,
                    width: titleSize.width,
                    height: titleSize.height
                )
                origin += max(leadingSize.height, titleSize.height, trailingSize.height)
            } else {
                origin += max(leadingSize.height, trailingSize.height)
            }
            if let footerItem = self.footerItem {
                origin += self.footerSpacing
                let footerSize = footerItem.size(availableSize)
                footerItem.frame = QRect(
                    x: bounds.x + self.inset.left,
                    y: bounds.y + origin,
                    width: footerSize.width,
                    height: footerSize.height
                )
                origin += footerSize.height
            }
            origin += self.inset.bottom
            return QSize(
                width: bounds.width,
                height: origin
            )
        }
        
        func size(_ available: QSize) -> QSize {
            let availableSize = QSize(
                width: available.width - self.inset.horizontal,
                height: .infinity
            )
            let headerHeight: Float
            if let headerItem = self.headerItem {
                let headerSize = headerItem.size(availableSize)
                headerHeight = headerSize.height + self.headerSpacing
            } else {
                headerHeight = 0
            }
            let leadingSize = QListLayout.Helper.size(
                available: availableSize,
                direction: .horizontal,
                inset: .zero,
                spacing: self.leadingItemSpacing,
                items: self.leadingItems
            )
            let trailingSize = QListLayout.Helper.size(
                available: availableSize,
                direction: .horizontal,
                inset: .zero,
                spacing: self.trailingItemSpacing,
                items: self.trailingItems
            )
            let titleHeight: Float
            if let titleItem = self.titleItem {
                let leadingSpacing = self.leadingItems.count > 0 ? self.titleSpacing : 0
                let trailingSpacing = self.trailingItems.count > 0 ? self.titleSpacing : 0
                let titleSize = titleItem.size(QSize(
                    width: availableSize.width - (leadingSize.width + leadingSpacing) - (trailingSize.width + trailingSpacing),
                    height: max(leadingSize.height, trailingSize.height)
                ))
                titleHeight = titleSize.height
            } else {
                titleHeight = 0
            }
            let footerHeight: Float
            if let footerItem = self.footerItem {
                let footerSize = footerItem.size(availableSize)
                footerHeight = footerSize.height + self.footerSpacing
            } else {
                footerHeight = 0
            }
            return QSize(
                width: available.width,
                height: headerHeight + max(leadingSize.height, titleHeight, trailingSize.height) + footerHeight + self.inset.vertical
            )
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            var items: [QLayoutItem] = []
            if let headerItem = self.headerItem {
                items.append(headerItem)
            }
            items.append(contentsOf: self.leadingItems)
            if let titleItem = self.titleItem {
                items.append(titleItem)
            }
            items.append(contentsOf: self.trailingItems)
            if let footerItem = self.footerItem {
                items.append(footerItem)
            }
            return items
        }
        
    }
    
}
