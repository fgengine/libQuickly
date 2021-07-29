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
    public var detailView: IQView? {
        didSet(oldValue) {
            guard self.detailView !== oldValue else { return }
            self._contentLayout.detailItem = self.detailView.flatMap({ QLayoutItem(view: $0) })
        }
    }
    public var detailSpacing: Float {
        set(value) { self._contentLayout.detailSpacing = value }
        get { return self._contentLayout.detailSpacing }
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

    private var _contentLayout: Layout
    private var _contentView: QCustomView< Layout >
    
    public init(
        inset: QInset,
        leadingViews: [IQView] = [],
        leadingViewSpacing: Float = 4,
        titleView: IQView? = nil,
        titleSpacing: Float = 4,
        detailView: IQView? = nil,
        detailSpacing: Float = 8,
        trailingViews: [IQView] = [],
        trailingViewSpacing: Float = 4,
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1
    ) {
        self.leadingViews = leadingViews
        self.titleView = titleView
        self.detailView = detailView
        self.trailingViews = trailingViews
        self._contentLayout = Layout(
            inset: inset,
            leadingItems: leadingViews.compactMap({ QLayoutItem(view: $0) }),
            leadingItemSpacing: leadingViewSpacing,
            titleItem: titleView.flatMap({ QLayoutItem(view: $0) }),
            titleSpacing: titleSpacing,
            detailItem: detailView.flatMap({ QLayoutItem(view: $0) }),
            detailSpacing: detailSpacing,
            trailingItems: trailingViews.compactMap({ QLayoutItem(view: $0) }),
            trailingItemSpacing: trailingViewSpacing
        )
        self._contentView = QCustomView(
            contentLayout: self._contentLayout
        )
        super.init(
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
    public func detailView(_ value: IQView?) -> Self {
        self.detailView = value
        return self
    }
    
    @discardableResult
    public func detailSpacing(_ value: Float) -> Self {
        self.detailSpacing = value
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
    
}

private extension QStackBarView {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var inset: QInset {
            didSet { self.setNeedForceUpdate() }
        }
        var leadingItems: [QLayoutItem] {
            didSet { self.setNeedForceUpdate() }
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
        var detailItem: QLayoutItem? {
            didSet { self.setNeedForceUpdate() }
        }
        var detailSpacing: Float {
            didSet { self.setNeedForceUpdate() }
        }
        var trailingItems: [QLayoutItem] {
            didSet { self.setNeedForceUpdate() }
        }
        var trailingItemSpacing: Float {
            didSet { self.setNeedForceUpdate() }
        }
        
        private var _leadingItemsCache: [QSize?]
        private var _trailingItemsCache: [QSize?]

        init(
            inset: QInset,
            leadingItems: [QLayoutItem],
            leadingItemSpacing: Float,
            titleItem: QLayoutItem?,
            titleSpacing: Float,
            detailItem: QLayoutItem?,
            detailSpacing: Float,
            trailingItems: [QLayoutItem],
            trailingItemSpacing: Float
        ) {
            self.inset = inset
            self.leadingItems = leadingItems
            self.leadingItemSpacing = leadingItemSpacing
            self.titleItem = titleItem
            self.titleSpacing = titleSpacing
            self.detailItem = detailItem
            self.detailSpacing = detailSpacing
            self.trailingItems = trailingItems
            self.trailingItemSpacing = trailingItemSpacing
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
        
        func invalidate() {
            self._leadingItemsCache = Array< QSize? >(repeating: nil, count: self.leadingItems.count)
            self._trailingItemsCache = Array< QSize? >(repeating: nil, count: self.trailingItems.count)
        }
        
        func layout(bounds: QRect) -> QSize {
            let safeBounds = bounds.apply(inset: self.inset)
            let footerHeight: Float
            if let detailItem = self.detailItem {
                let detailSize = detailItem.size(safeBounds.size)
                detailItem.frame = QRect(
                    bottomLeft: safeBounds.bottomLeft,
                    size: QSize(width: safeBounds.size.width, height: detailSize.height)
                )
                footerHeight = detailSize.height + self.detailSpacing
            } else {
                footerHeight = 0
            }
            let headerBounds = QRect(
                x: safeBounds.origin.x,
                y: safeBounds.origin.y,
                width: safeBounds.size.width,
                height: safeBounds.size.height - footerHeight
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
                let leadingOffset = self.leadingItems.count > 0 ? self.titleSpacing : 0
                let trailingOffset = self.trailingItems.count > 0 ? self.titleSpacing : 0
                titleItem.frame = QRect(
                    x: headerBounds.origin.x + leadingSize.width + leadingOffset,
                    y: headerBounds.origin.y,
                    width: headerBounds.size.width - (leadingSize.width + leadingOffset) - (trailingSize.width + trailingOffset),
                    height: headerBounds.size.height
                )
            }
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            let detailSize = self.detailItem?.size(available.apply(inset: self.inset))
            let headerHeight: Float
            let footerHeight: Float
            if let detailSize = detailSize {
                footerHeight = detailSize.height + self.detailSpacing
            } else {
                footerHeight = 0
            }
            let itemsAvailable = QSize(
                width: available.width - (self.inset.left + self.inset.right),
                height: available.height - (self.inset.top + footerHeight + self.inset.bottom)
            )
            let leadingSize = QListLayout.Helper.size(
                available: itemsAvailable,
                direction: .horizontal,
                inset: .zero,
                spacing: self.leadingItemSpacing,
                items: self.leadingItems
            )
            let trailingSize = QListLayout.Helper.size(
                available: itemsAvailable,
                direction: .horizontal,
                inset: .zero,
                spacing: self.trailingItemSpacing,
                items: self.trailingItems
            )
            if let titleItem = self.titleItem {
                let titleLeadingSpacing = self.leadingItems.count > 0 ? leadingSize.width + self.titleSpacing : 0
                let titleTrailingSpacing = self.trailingItems.count > 0 ? trailingSize.width + self.titleSpacing : 0
                let titleAvailable = QSize(
                    width: available.width - (self.inset.left + titleLeadingSpacing + titleTrailingSpacing + self.inset.right),
                    height: available.height - (self.inset.top + footerHeight + self.inset.bottom)
                )
                let titleSize = titleItem.size(titleAvailable)
                headerHeight = max(leadingSize.height, titleSize.height, trailingSize.height)
            } else {
                headerHeight = max(leadingSize.height, trailingSize.height)
            }
            return QSize(
                width: available.width - (self.inset.left + self.inset.right),
                height: self.inset.top + headerHeight + footerHeight + self.inset.bottom
            )
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            var items: [QLayoutItem] = self.leadingItems + self.trailingItems
            if let titleItem = self.titleItem {
                items.append(titleItem)
            }
            if let detailItem = self.detailItem {
                items.append(detailItem)
            }
            return items
        }
        
    }
    
}
