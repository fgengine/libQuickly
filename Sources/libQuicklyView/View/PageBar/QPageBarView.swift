//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public final class QPageBarView : QBarView, IQPageBarView {
    
    public var delegate: IQPageBarViewDelegate?
    public private(set) var indicatorView: IQView {
        didSet(oldValue) {
            guard self.indicatorView !== oldValue else { return }
            self._contentLayout.indicatorItem = QLayoutItem(view: self.indicatorView)
        }
    }
    public private(set) var views: [IQView] {
        didSet(oldValue) {
            self._contentLayout.items = self.views.compactMap({ QLayoutItem(view: $0) })
        }
    }
    public private(set) var selectedView: IQView? {
        didSet(oldValue) {
            guard self.selectedView !== oldValue else { return }
            if let selectedView = self.selectedView {
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
    }
    
    private var _contentLayout: Layout
    private var _contentView: QScrollView
    private var _transitionContentOffset: QPoint?
    private var _transitionSelectedView: IQView?
    
    public init(
        indicatorView: IQView,
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: QFloat = 1
    ) {
        self.indicatorView = indicatorView
        self.views = []
        self._contentLayout = Layout(
            indicatorItem: QLayoutItem(view: indicatorView),
            indicatorState: .empty,
            itemSpacing: 10,
            items: []
        )
        self._contentView = QScrollView(
            direction: .horizontal,
            layout: self._contentLayout
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
    public func indicatorView(_ value: IQView) -> Self {
        self.indicatorView = value
        return self
    }
    
    @discardableResult
    public func views(_ value: [IQView]) -> Self {
        self.views = value
        return self
    }
    
    @discardableResult
    public func selectedView(_ value: IQView?) -> Self {
        self.selectedView = value
        return self
    }
    
    public func beginTransition() {
        self._transitionContentOffset = self._contentView.contentOffset
        self._transitionSelectedView = self.selectedView
    }
    
    public func changeTransition(to view: IQView, progress: QFloat) {
        if let currentContentOffset = self._transitionContentOffset {
            if let targetContentOffset = self._contentView.contentOffset(with: view, horizontal: .center, vertical: .center) {
                self._contentView.contentOffset(currentContentOffset.lerp(targetContentOffset, progress: progress), normalized: true)
            }
        }
        if let currentView = self._transitionSelectedView, let currentItem = currentView.item, let nextItem = view.item {
            self._contentLayout.indicatorState = .transition(current: currentItem, next: nextItem, progress: progress)
        }
    }
    
    public func finishTransition(to view: IQView) {
        self._transitionContentOffset = nil
        self._transitionSelectedView = nil
        self.selectedView = view
    }
    
    public func cancelTransition() {
        self._transitionContentOffset = nil
        self._transitionSelectedView = nil
    }
    
}

private extension QPageBarView {
    
    class Layout : IQLayout {
        
        enum IndicatorState {
            case empty
            case alias(current: IQLayoutItem)
            case transition(current: IQLayoutItem, next: IQLayoutItem, progress: QFloat)
        }
        
        weak var delegate: IQLayoutDelegate?
        weak var parentView: IQView?
        var indicatorItem: IQLayoutItem {
            didSet { self.setNeedUpdate() }
        }
        var indicatorState: IndicatorState {
            didSet { self.setNeedUpdate() }
        }
        var itemSpacing: QFloat {
            didSet { self.setNeedUpdate() }
        }
        var items: [IQLayoutItem] {
            didSet { self.setNeedUpdate() }
        }

        init(
            indicatorItem: IQLayoutItem,
            indicatorState: IndicatorState,
            itemSpacing: QFloat,
            items: [IQLayoutItem]
        ) {
            self.indicatorItem = indicatorItem
            self.indicatorState = indicatorState
            self.itemSpacing = itemSpacing
            self.items = items
        }
        
        func layout(bounds: QRect) -> QSize {
            var size = QSize(width: 0, height: bounds.size.height)
            if self.items.count > 1 {
                var sizes: [QFloat] = []
                for item in self.items {
                    let itemSize = item.size(QSize(width: bounds.size.width, height: bounds.size.height))
                    sizes.append(itemSize.width)
                    size.width += itemSize.width + self.itemSpacing
                    size.height = bounds.size.height
                }
                size.width -= self.itemSpacing
                let additionalItemSize: QFloat
                if size.width < bounds.size.width {
                    additionalItemSize = (bounds.size.width - size.width) / QFloat(self.items.count)
                    size.width = bounds.size.width
                } else {
                    additionalItemSize = 0
                }
                var origin = bounds.origin
                for index in 0 ..< self.items.count {
                    let item = self.items[index]
                    let itemSize = sizes[index]
                    item.frame = QRect(
                        x: origin.x,
                        y: origin.y,
                        width: itemSize + additionalItemSize,
                        height: bounds.size.height
                    )
                    origin.x += itemSize + additionalItemSize + self.itemSpacing
                }
            } else if let item = self.items.first {
                item.frame = QRect(
                    x: bounds.origin.x,
                    y: bounds.origin.y,
                    width: bounds.size.width,
                    height: bounds.size.height
                )
            }
            return size
        }
        
        func size(_ available: QSize) -> QSize {
            var size = QSize(width: 0, height: available.height)
            if self.items.count > 1 {
                for item in self.items {
                    let itemSize = item.size(QSize(width: available.width, height: available.height))
                    size.width += itemSize.width + self.itemSpacing
                    size.height = available.height
                }
                size.width -= self.itemSpacing
                if size.width < available.width {
                    size.width = available.width
                }
            } else {
                size.width = available.width
            }
            return size
        }
        
        func items(bounds: QRect) -> [IQLayoutItem] {
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
            return items
        }
        
    }
    
}
