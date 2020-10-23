//
//  libQuicklyView
//

import Foundation

public struct QContentDetailValueCellComposition< BackgroundView: IQView, ContentView: IQView, DetailView: IQView, ValueView: IQView > : IQCellComposition {
    
    public private(set) var backgroundView: BackgroundView?
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
    public var valueInset: QInset {
        set(value) {
            self._layout.valueInset = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.valueInset }
    }
    public private(set) var valueView: ValueView
    public var layout: IQDynamicLayout {
        return self._layout
    }
    public var isOpaque: Bool {
        return self.backgroundView == nil
    }
    
    private var _layout: Layout
    
    public init(
        backgroundView: BackgroundView? = nil,
        contentInset: QInset,
        contentView: ContentView,
        detailInset: QInset,
        detailView: DetailView,
        valueInset: QInset,
        valueView: ValueView
    ) {
        self.backgroundView = backgroundView
        self.contentView = contentView
        self.detailView = detailView
        self.valueView = valueView
        self._layout = Layout(
            backgroundItem: backgroundView.flatMap({ QLayoutItem(view: $0) }),
            contentInset: contentInset,
            contentItem: QLayoutItem(view: contentView),
            detailInset: detailInset,
            detailItem: QLayoutItem(view: detailView),
            valueInset: valueInset,
            valueItem: QLayoutItem(view: valueView)
        )
    }
    
}

extension QContentDetailValueCellComposition {
    
    class Layout : IQDynamicLayout {
        
        var delegate: IQLayoutDelegate?
        var parentView: IQView?
        var backgroundItem: IQLayoutItem?
        var contentInset: QInset
        var contentItem: IQLayoutItem
        var detailInset: QInset
        var detailItem: IQLayoutItem
        var valueInset: QInset
        var valueItem: IQLayoutItem
        var items: [IQLayoutItem] {
            var items: [IQLayoutItem] = []
            if let item = self.backgroundItem {
                items.append(item)
            }
            items.append(contentsOf: [
                self.contentItem,
                self.detailItem,
                self.valueItem
            ])
            return items
        }
        var size: QSize

        init(
            backgroundItem: IQLayoutItem?,
            contentInset: QInset,
            contentItem: IQLayoutItem,
            detailInset: QInset,
            detailItem: IQLayoutItem,
            valueInset: QInset,
            valueItem: IQLayoutItem
        ) {
            self.backgroundItem = backgroundItem
            self.contentInset = contentInset
            self.contentItem = contentItem
            self.detailInset = detailInset
            self.detailItem = detailItem
            self.valueInset = valueInset
            self.valueItem = valueItem
            self.size = QSize()
        }
        
        func layout() {
            var size: QSize
            if let bounds = self.delegate?.bounds(self) {
                size = bounds.size
                if let item = self.backgroundItem {
                    item.frame = bounds
                }
                let valueSize = self.valueItem.size(bounds.size.apply(inset: self.valueInset))
                let contentDetailValue = bounds.split(
                    right: self.valueInset.left + valueSize.width + self.valueInset.right
                )
                let contentSize = self.contentItem.size(contentDetailValue.left.size.apply(inset: self.contentInset))
                let contentDetail = contentDetailValue.left.split(
                    top: self.contentInset.top + contentSize.height + self.contentInset.bottom
                )
                self.contentItem.frame = contentDetail.top.apply(inset: self.contentInset)
                self.detailItem.frame = contentDetail.bottom.apply(inset: self.detailInset)
                self.valueItem.frame = contentDetailValue.right.apply(inset: self.valueInset)
            } else {
                size = QSize()
            }
            self.size = size
        }
        
        func size(_ available: QSize) -> QSize {
            let valueSize = self.valueItem.size(available.apply(inset: self.valueInset))
            let valueBounds = valueSize.apply(inset: -self.valueInset)
            let contentAvailable = QSize(
                width: available.width - valueBounds.width,
                height: available.height
            )
            let contentSize = self.contentItem.size(contentAvailable.apply(inset: self.contentInset))
            let contentBounds = contentSize.apply(inset: -self.contentInset)
            let detailSize = self.detailItem.size(contentAvailable.apply(inset: self.detailInset))
            let detailBounds = detailSize.apply(inset: -self.detailInset)
            return QSize(
                width: max(contentBounds.width, detailBounds.width) + valueBounds.width,
                height: max(contentBounds.height + detailBounds.height, valueBounds.height)
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
