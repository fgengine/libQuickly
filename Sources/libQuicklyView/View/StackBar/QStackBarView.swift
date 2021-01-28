//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public final class QStackBarView : QBarView, IQStackBarView {
    
    public private(set) var leadingViews: [IQView] {
        didSet(oldValue) {
            self._contentLayout.leadingItems = self.leadingViews.compactMap({ QLayoutItem(view: $0) })
        }
    }
    public private(set) var titleView: IQView? {
        didSet(oldValue) {
            guard self.titleView !== oldValue else { return }
            self._contentLayout.titleItem = self.titleView.flatMap({ QLayoutItem(view: $0) })
        }
    }
    public private(set) var detailView: IQView? {
        didSet(oldValue) {
            guard self.detailView !== oldValue else { return }
            self._contentLayout.detailItem = self.detailView.flatMap({ QLayoutItem(view: $0) })
        }
    }
    public private(set) var trailingViews: [IQView] {
        didSet(oldValue) {
            self._contentLayout.trailingItems = self.trailingViews.compactMap({ QLayoutItem(view: $0) })
        }
    }
    
    private var _contentLayout: Layout
    private var _contentView: QCustomView
    
    public init(
        leadingViews: [IQView] = [],
        titleView: IQView? = nil,
        detailView: IQView? = nil,
        trailingViews: [IQView] = [],
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: QFloat = 1
    ) {
        self.leadingViews = leadingViews
        self.titleView = titleView
        self.detailView = detailView
        self.trailingViews = trailingViews
        self._contentLayout = Layout(
            leadingItems: leadingViews.compactMap({ QLayoutItem(view: $0) }),
            titleItem: titleView.flatMap({ QLayoutItem(view: $0) }),
            detailItem: detailView.flatMap({ QLayoutItem(view: $0) }),
            trailingItems: trailingViews.compactMap({ QLayoutItem(view: $0) })
        )
        self._contentView = QCustomView(
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
    public func leadingViews(_ value: [IQView]) -> Self {
        self.leadingViews = value
        return self
    }
    
    @discardableResult
    public func titleView(_ value: IQView?) -> Self {
        self.titleView = value
        return self
    }
    
    @discardableResult
    public func detailView(_ value: IQView?) -> Self {
        self.detailView = value
        return self
    }
    
    @discardableResult
    public func trailingViews(_ value: [IQView]) -> Self {
        self.trailingViews = value
        return self
    }
    
}

private extension QStackBarView {
    
    class Layout : IQLayout {
        
        weak var delegate: IQLayoutDelegate?
        weak var parentView: IQView?
        var leadingItems: [IQLayoutItem] {
            didSet { self.setNeedUpdate() }
        }
        var titleItem: IQLayoutItem? {
            didSet { self.setNeedUpdate() }
        }
        var detailItem: IQLayoutItem? {
            didSet { self.setNeedUpdate() }
        }
        var trailingItems: [IQLayoutItem] {
            didSet { self.setNeedUpdate() }
        }

        init(
            leadingItems: [IQLayoutItem],
            titleItem: IQLayoutItem?,
            detailItem: IQLayoutItem?,
            trailingItems: [IQLayoutItem]
        ) {
            self.leadingItems = leadingItems
            self.titleItem = titleItem
            self.detailItem = detailItem
            self.trailingItems = trailingItems
        }
        
        func layout(bounds: QRect) -> QSize {
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            var size = QSize(width: 0, height: available.height)
            return size
        }
        
        func items(bounds: QRect) -> [IQLayoutItem] {
            var items: [IQLayoutItem] = self.leadingItems + self.trailingItems
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
