//
//  libQuicklyView
//

import Foundation

public struct QIconContentDetailCellComposition< BackgroundView: IQView, IconView: IQView, ContentView: IQView, DetailView: IQView > : IQCellComposition {
    
    public private(set) var backgroundView: BackgroundView?
    public var iconInset: QInset {
        set(value) {
            self._layout.iconInset = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.iconInset }
    }
    public private(set) var iconView: IconView
    public var contentInset: QInset {
        set(value) {
            self._layout.contentInset = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.contentInset }
    }
    public private(set) var contentView: ContentView
    public var detailInset: QInset {
        set(value) {
            self._layout.detailInset = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.detailInset }
    }
    public private(set) var detailView: DetailView
    public var layout: IQDynamicLayout {
        return self._layout
    }
    public var isOpaque: Bool {
        return self.backgroundView == nil
    }
    
    private var _layout: Layout
    
    public init(
        backgroundView: BackgroundView? = nil,
        iconInset: QInset,
        iconView: IconView,
        contentInset: QInset,
        contentView: ContentView,
        detailInset: QInset,
        detailView: DetailView
    ) {
        self.backgroundView = backgroundView
        self.iconView = iconView
        self.contentView = contentView
        self.detailView = detailView
        self._layout = Layout(
            backgroundItem: backgroundView.flatMap({ QLayoutItem(view: $0) }),
            iconInset: iconInset,
            iconItem: QLayoutItem(view: iconView),
            contentInset: contentInset,
            contentItem: QLayoutItem(view: contentView),
            detailInset: detailInset,
            detailItem: QLayoutItem(view: detailView)
        )
    }
    
}

extension QIconContentDetailCellComposition {
    
    class Layout : IQDynamicLayout {
        
        var delegate: IQLayoutDelegate?
        var parentView: IQView?
        var backgroundItem: IQLayoutItem?
        var iconInset: QInset
        var iconItem: IQLayoutItem
        var contentInset: QInset
        var contentItem: IQLayoutItem
        var detailInset: QInset
        var detailItem: IQLayoutItem
        var items: [IQLayoutItem] {
            var items: [IQLayoutItem] = []
            if let item = self.backgroundItem {
                items.append(item)
            }
            items.append(contentsOf: [
                self.iconItem,
                self.contentItem,
                self.detailItem
            ])
            return items
        }
        var size: QSize

        init(
            backgroundItem: IQLayoutItem?,
            iconInset: QInset,
            iconItem: IQLayoutItem,
            contentInset: QInset,
            contentItem: IQLayoutItem,
            detailInset: QInset,
            detailItem: IQLayoutItem
        ) {
            self.backgroundItem = backgroundItem
            self.iconInset = iconInset
            self.iconItem = iconItem
            self.contentInset = contentInset
            self.contentItem = contentItem
            self.detailInset = detailInset
            self.detailItem = detailItem
            self.size = QSize()
        }
        
        func layout() {
            var size: QSize
            if let bounds = self.delegate?.bounds(self) {
                size = bounds.size
                if let item = self.backgroundItem {
                    item.frame = bounds
                }
                let iconSize = self.iconItem.size(bounds.size.apply(inset: self.iconInset))
                let contentDetailValue = bounds.split(
                    left: self.iconInset.left + iconSize.width + self.iconInset.right
                )
                let contentSize = self.contentItem.size(contentDetailValue.right.size.apply(inset: self.contentInset))
                let contentDetail = contentDetailValue.right.split(
                    top: self.contentInset.top + contentSize.height + self.contentInset.bottom
                )
                self.iconItem.frame = contentDetailValue.left.apply(inset: self.iconInset)
                self.contentItem.frame = contentDetail.top.apply(inset: self.contentInset)
                self.detailItem.frame = contentDetail.bottom.apply(inset: self.detailInset)
            } else {
                size = QSize()
            }
            self.size = size
        }
        
        func size(_ available: QSize) -> QSize {
            let iconSize = self.iconItem.size(available.apply(inset: self.iconInset))
            let iconBounds = iconSize.apply(inset: -self.iconInset)
            let contentAvailable = QSize(
                width: available.width - iconBounds.width,
                height: available.height
            )
            let contentSize = self.contentItem.size(contentAvailable.apply(inset: self.contentInset))
            let contentBounds = contentSize.apply(inset: -self.contentInset)
            let detailSize = self.detailItem.size(contentAvailable.apply(inset: self.detailInset))
            let detailBounds = detailSize.apply(inset: -self.detailInset)
            return QSize(
                width: iconBounds.width + max(contentBounds.width, detailBounds.width),
                height: max(iconBounds.height, contentBounds.height + detailBounds.height)
            )
        }
        
        func items(bounds: QRect) -> [IQLayoutItem] {
            return self.items
        }
        
        func insert(item: IQLayoutItem, at index: UInt) {
        }
        
        func delete(item: IQLayoutItem) {
        }
        
    }
    
}
