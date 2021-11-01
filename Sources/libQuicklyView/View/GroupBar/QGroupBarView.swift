//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QGroupBarView : QBarView, IQGroupBarView {
    
    public var delegate: IQGroupBarViewDelegate?
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
            self._selectedItemView?.select(true)
        }
        get { return self._selectedItemView }
    }
    
    private var _contentLayout: Layout
    private var _contentView: QCustomView< Layout >
    private var _itemViews: [IQBarItemView]
    private var _selectedItemView: IQBarItemView?
    
    public init(
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
        self._itemViews = []
        self._contentLayout = Layout(
            itemInset: itemInset,
            itemSpacing: itemSpacing,
            items: []
        )
        self._contentView = QCustomView(
            contentLayout: self._contentLayout
        )
        super.init(
            placement: .bottom,
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
    
}

extension QGroupBarView : IQBarItemViewDelegate {
    
    public func pressed(barItemView: IQBarItemView) {
        self.delegate?.pressed(groupBar: self, itemView: barItemView)
    }
    
}

private extension QGroupBarView {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
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
            itemInset: QInset,
            itemSpacing: Float,
            items: [QLayoutItem]
        ) {
            self.itemInset = itemInset
            self.itemSpacing = itemSpacing
            self.items = items
            self._cache = Array< QSize? >(repeating: nil, count: items.count)
        }
        
        func invalidate(item: QLayoutItem) {
            if let index = self.items.firstIndex(where: { $0 === item }) {
                self._cache.remove(at: index)
            }
        }
        
        func layout(bounds: QRect) -> QSize {
            return QListLayout.Helper.layout(
                bounds: bounds,
                direction: .horizontal,
                inset: self.itemInset,
                spacing: self.itemSpacing,
                minSize: bounds.size.width / Float(self.items.count),
                maxSize: bounds.size.width,
                items: self.items,
                cache: &self._cache
            )
        }
        
        func size(available: QSize) -> QSize {
            return QListLayout.Helper.size(
                available: available,
                direction: .horizontal,
                inset: self.itemInset,
                spacing: self.itemSpacing,
                minSize: available.width / Float(self.items.count),
                maxSize: available.width,
                items: self.items
            )
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            return self.visible(items: self.items, for: bounds)
        }
        
    }
    
}
