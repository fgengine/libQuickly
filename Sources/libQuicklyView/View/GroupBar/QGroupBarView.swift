//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QGroupBarView : QBarView, IQGroupBarView {
    
    public var delegate: IQGroupBarViewDelegate?
    public private(set) var itemInset: QInset {
        set(value) { self._contentLayout.itemInset = value }
        get { return self._contentLayout.itemInset }
    }
    public private(set) var itemSpacing: QFloat {
        set(value) { self._contentLayout.itemSpacing = value }
        get { return self._contentLayout.itemSpacing }
    }
    public private(set) var itemViews: [IQBarItemView] {
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
    public private(set) var selectedItemView: IQBarItemView? {
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
        name: String? = nil,
        itemInset: QInset = QInset(horizontal: 12, vertical: 0),
        itemSpacing: QFloat = 4,
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: QFloat = 1
    ) {
        let name = name ?? String(describing: Self.self)
        self._itemViews = []
        self._contentLayout = Layout(
            itemInset: itemInset,
            itemSpacing: itemSpacing,
            items: []
        )
        self._contentView = QCustomView(
            name: "\(name)-BarView",
            layout: self._contentLayout
        )
        super.init(
            name: name,
            contentView: self._contentView,
            color: color,
            border: border,
            cornerRadius: cornerRadius,
            shadow: shadow,
            alpha: alpha
        )
    }
    
    @discardableResult
    public func itemInset(_ value: QInset) -> Self {
        self.itemInset = value
        return self
    }
    
    @discardableResult
    public func itemSpacing(_ value: QFloat) -> Self {
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
        unowned var parentView: IQView?
        var itemInset: QInset {
            didSet { self.setNeedUpdate() }
        }
        var itemSpacing: QFloat {
            didSet { self.setNeedUpdate() }
        }
        var items: [QLayoutItem] {
            didSet {
                self.invalidate()
                self.setNeedUpdate()
            }
        }
        
        private var _cache: [QSize?]

        init(
            itemInset: QInset,
            itemSpacing: QFloat,
            items: [QLayoutItem]
        ) {
            self.itemInset = itemInset
            self.itemSpacing = itemSpacing
            self.items = items
            self._cache = Array< QSize? >(repeating: nil, count: items.count)
        }
        
        func invalidate() {
            self._cache = Array< QSize? >(repeating: nil, count: self.items.count)
        }
        
        func layout(bounds: QRect) -> QSize {
            return QListLayout.Helper.layout(
                bounds: bounds,
                direction: .horizontal,
                origin: .forward,
                inset: self.itemInset,
                spacing: self.itemSpacing,
                minSize: bounds.size.width / QFloat(self.items.count),
                maxSize: bounds.size.width,
                items: self.items,
                cache: &self._cache
            )
        }
        
        func size(_ available: QSize) -> QSize {
            return QListLayout.Helper.size(
                available: available,
                direction: .horizontal,
                inset: self.itemInset,
                spacing: self.itemSpacing,
                minSize: available.width / QFloat(self.items.count),
                maxSize: available.width,
                items: self.items
            )
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            return self.visible(items: self.items, for: bounds)
        }
        
    }
    
}
