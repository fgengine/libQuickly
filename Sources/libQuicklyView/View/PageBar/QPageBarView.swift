//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QPageBarView : QBarView, IQPageBarView {
    
    public var delegate: IQPageBarViewDelegate?
    public var leadingView: IQView? {
        didSet(oldValue) {
            guard self.leadingView !== oldValue else { return }
            self._contentLayout.leadingItem = self.leadingView.flatMap({ QLayoutItem(view: $0) })
        }
    }
    public var trailingView: IQView? {
        didSet(oldValue) {
            guard self.trailingView !== oldValue else { return }
            self._contentLayout.trailingItem = self.trailingView.flatMap({ QLayoutItem(view: $0) })
        }
    }
    public var indicatorView: IQView {
        didSet(oldValue) {
            guard self.indicatorView !== oldValue else { return }
            self._contentLayout.indicatorItem = QLayoutItem(view: self.indicatorView)
        }
    }
    public var itemInset: QInset {
        set(value) { self._contentLayout.itemInset = value }
        get { return self._contentLayout.itemInset }
    }
    public var itemSpacing: Float {
        set(value) { self._contentLayout.itemSpacing = value }
        get { return self._contentLayout.itemSpacing }
    }
    public var itemViews: [IQBarItemView] {
        set(value) {
            for itemView in self._itemViews {
                itemView.delegate = nil
            }
            self._itemViews = value
            for itemView in self._itemViews {
                itemView.delegate = self
            }
            self._contentLayout.items = self.itemViews.compactMap({ QLayoutItem(view: $0) })
        }
        get { return self._itemViews }
    }
    public var selectedItemView: IQBarItemView? {
        set(value) {
            guard self._selectedItemView !== value else { return }
            self._selectedItemView?.select(false)
            self._selectedItemView = value
            if let selectedView = self._selectedItemView {
                selectedView.select(true)
                if let contentOffset = self._contentView.contentOffset(with: selectedView, horizontal: .center, vertical: .center) {
                    self._contentView.contentOffset(contentOffset, normalized: true)
                }
                if let item = selectedView.item {
                    self._contentLayout.indicatorState = .alias(current: item)
                }
            } else {
                self._contentLayout.indicatorState = .empty
            }
        }
        get { return self._selectedItemView }
    }
    
    private var _contentLayout: Layout
    private var _contentView: QScrollView< Layout >
    private var _itemViews: [IQBarItemView]
    private var _selectedItemView: IQBarItemView?
    private var _transitionContentOffset: QPoint?
    private var _transitionSelectedView: IQView?
    
    public init(
        leadingView: IQView? = nil,
        trailingView: IQView? = nil,
        indicatorView: IQView,
        itemInset: QInset = QInset(horizontal: 12, vertical: 0),
        itemSpacing: Float = 4,
        size: Float? = nil,
        separatorView: IQView? = nil,
        color: QColor? = nil,
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1,
        isHidden: Bool = false
    ) {
        self.leadingView = leadingView
        self.trailingView = trailingView
        self.indicatorView = indicatorView
        self._itemViews = []
        self._contentLayout = Layout(
            leadingItem: leadingView.flatMap({ QLayoutItem(view: $0) }),
            trailingItem: trailingView.flatMap({ QLayoutItem(view: $0) }),
            indicatorItem: QLayoutItem(view: indicatorView),
            indicatorState: .empty,
            itemInset: itemInset,
            itemSpacing: itemSpacing,
            items: []
        )
        self._contentView = QScrollView(
            direction: .horizontal,
            contentLayout: self._contentLayout
        )
        super.init(
            placement: .top,
            size: size,
            separatorView: separatorView,
            contentView: self._contentView,
            color: color,
            border: border,
            cornerRadius: cornerRadius,
            shadow: shadow,
            alpha: alpha,
            isHidden: isHidden
        )
    }
    
    @discardableResult
    public func leadingView(_ value: IQView?) -> Self {
        self.leadingView = value
        return self
    }
    
    @discardableResult
    public func trailingView(_ value: IQView?) -> Self {
        self.trailingView = value
        return self
    }
    
    @discardableResult
    public func indicatorView(_ value: IQView) -> Self {
        self.indicatorView = value
        return self
    }
    
    @discardableResult
    public func itemInset(_ value: QInset) -> Self {
        self.itemInset = value
        return self
    }
    
    @discardableResult
    public func itemSpacing(_ value: Float) -> Self {
        self.itemSpacing = value
        return self
    }
    
    @discardableResult
    public func itemViews(_ value: [IQBarItemView]) -> Self {
        self.itemViews = value
        return self
    }
    
    @discardableResult
    public func selectedItemView(_ value: IQBarItemView?) -> Self {
        self.selectedItemView = value
        return self
    }
    
    public func beginTransition() {
        self._transitionContentOffset = self._contentView.contentOffset
        self._transitionSelectedView = self._selectedItemView
    }
    
    public func transition(to view: IQBarItemView, progress: Float) {
        if let currentContentOffset = self._transitionContentOffset {
            if let targetContentOffset = self._contentView.contentOffset(with: view, horizontal: .center, vertical: .center) {
                self._contentView.contentOffset(currentContentOffset.lerp(targetContentOffset, progress: progress), normalized: true)
            }
        }
        if let currentView = self._transitionSelectedView, let currentItem = currentView.item, let nextItem = view.item {
            self._contentLayout.indicatorState = .transition(current: currentItem, next: nextItem, progress: progress)
        }
    }
    
    public func finishTransition(to view: IQBarItemView) {
        self._transitionContentOffset = nil
        self._transitionSelectedView = nil
        self.selectedItemView = view
    }
    
    public func cancelTransition() {
        self._transitionContentOffset = nil
        self._transitionSelectedView = nil
    }
    
}

extension QPageBarView : IQBarItemViewDelegate {
    
    public func pressed(barItemView: IQBarItemView) {
        self.delegate?.pressed(pageBar: self, itemView: barItemView)
    }
    
}

private extension QPageBarView {
    
    class Layout : IQLayout {
        
        enum IndicatorState {
            case empty
            case alias(current: QLayoutItem)
            case transition(current: QLayoutItem, next: QLayoutItem, progress: Float)
        }
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var leadingItem: QLayoutItem? {
            didSet { self.setNeedForceUpdate() }
        }
        var trailingItem: QLayoutItem? {
            didSet { self.setNeedForceUpdate() }
        }
        var indicatorItem: QLayoutItem {
            didSet { self.setNeedForceUpdate() }
        }
        var indicatorState: IndicatorState {
            didSet { self.setNeedUpdate() }
        }
        var itemInset: QInset {
            didSet { self.setNeedForceUpdate() }
        }
        var itemSpacing: Float {
            didSet { self.setNeedForceUpdate() }
        }
        var items: [QLayoutItem] {
            didSet {
                self._cache = Array< QSize? >(repeating: nil, count: self.items.count)
                self.setNeedForceUpdate()
            }
        }
        
        private var _cache: [QSize?]

        init(
            leadingItem: QLayoutItem?,
            trailingItem: QLayoutItem?,
            indicatorItem: QLayoutItem,
            indicatorState: IndicatorState,
            itemInset: QInset,
            itemSpacing: Float,
            items: [QLayoutItem]
        ) {
            self.leadingItem = leadingItem
            self.trailingItem = trailingItem
            self.indicatorItem = indicatorItem
            self.indicatorState = indicatorState
            self.itemInset = itemInset
            self.itemSpacing = itemSpacing
            self.items = items
            self._cache = Array< QSize? >(repeating: nil, count: items.count)
        }
        
        func invalidate(item: QLayoutItem) {
            if let index = self.items.firstIndex(where: { $0 === item }) {
                self._cache[index] = nil
            }
        }
        
        func layout(bounds: QRect) -> QSize {
            let leadingSize: QSize
            if let item = self.leadingItem {
                leadingSize = item.size(available: bounds.size)
                item.frame = QRect(
                    left: bounds.left,
                    size: leadingSize
                )
            } else {
                leadingSize = .zero
            }
            let trailingSize: QSize
            if let item = self.trailingItem {
                trailingSize = item.size(available: bounds.size)
                item.frame = QRect(
                    right: bounds.right,
                    size: trailingSize
                )
            } else {
                trailingSize = .zero
            }
            let itemsSize = QListLayout.Helper.layout(
                bounds: bounds.apply(inset: QInset(
                    top: 0,
                    left: leadingSize.width,
                    right: trailingSize.width,
                    bottom: 0
                )),
                direction: .horizontal,
                inset: self.itemInset,
                spacing: self.itemSpacing,
                maxSize: bounds.size.width,
                items: self.items,
                cache: &self._cache
            )
            return QSize(
                width: leadingSize.width + itemsSize.width + trailingSize.width,
                height: max(leadingSize.height, itemsSize.height, trailingSize.height)
            )
        }
        
        func size(available: QSize) -> QSize {
            let leadingSize: QSize
            if let item = self.leadingItem {
                leadingSize = item.size(available: available)
            } else {
                leadingSize = .zero
            }
            let trailingSize: QSize
            if let item = self.trailingItem {
                trailingSize = item.size(available: available)
            } else {
                trailingSize = .zero
            }
            let itemsSize = QListLayout.Helper.size(
                available: available.apply(inset: QInset(
                    top: 0,
                    left: leadingSize.width,
                    right: trailingSize.width,
                    bottom: 0
                )),
                direction: .horizontal,
                inset: self.itemInset,
                spacing: self.itemSpacing,
                maxSize: available.width,
                items: self.items
            )
            return QSize(
                width: leadingSize.width + itemsSize.width + trailingSize.width,
                height: max(leadingSize.height, itemsSize.height, trailingSize.height)
            )
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            var items = self.visible(items: self.items, for: bounds)
            switch self.indicatorState {
            case .empty:
                break
            case .alias(let current):
                self.indicatorItem.frame = current.frame
                items.append(self.indicatorItem)
            case .transition(let current, let next, let progress):
                self.indicatorItem.frame = current.frame.lerp(next.frame, progress: progress)
                items.append(self.indicatorItem)
            }
            if let item = self.leadingItem {
                item.frame = QRect(
                    left: bounds.left,
                    size: item.frame.size
                )
                items.append(item)
            }
            if let item = self.trailingItem {
                item.frame = QRect(
                    right: bounds.right,
                    size: item.frame.size
                )
                items.append(item)
            }
            return items
        }
        
    }
    
}
