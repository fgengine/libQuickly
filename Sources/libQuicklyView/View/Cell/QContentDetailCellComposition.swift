//
//  libQuicklyView
//

import Foundation

public struct QContentDetailCellComposition< BackgroundView: IQView, ContentView: IQView, DetailView: IQView > : IQCellComposition {
    
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
        detailView: DetailView
    ) {
        self.backgroundView = backgroundView
        self.contentView = contentView
        self.detailView = detailView
        self._layout = Layout(
            backgroundItem: backgroundView.flatMap({ QLayoutItem(view: $0) }),
            contentInset: contentInset,
            contentItem: QLayoutItem(view: contentView),
            detailInset: detailInset,
            detailItem: QLayoutItem(view: detailView)
        )
    }
    
}

extension QContentDetailCellComposition {
    
    class Layout : IQDynamicLayout {
        
        var delegate: IQLayoutDelegate?
        var parentView: IQView?
        var backgroundItem: IQLayoutItem?
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
                self.contentItem,
                self.detailItem
            ])
            return items
        }
        var size: QSize

        init(
            backgroundItem: IQLayoutItem?,
            contentInset: QInset,
            contentItem: IQLayoutItem,
            detailInset: QInset,
            detailItem: IQLayoutItem
        ) {
            self.backgroundItem = backgroundItem
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
                let contentSize = self.contentItem.size(bounds.size.apply(inset: self.contentInset))
                let contentDetail = bounds.split(
                    top: self.contentInset.top + contentSize.height + self.contentInset.bottom
                )
                self.contentItem.frame = contentDetail.top.apply(inset: self.contentInset)
                self.detailItem.frame = contentDetail.bottom.apply(inset: self.detailInset)
            } else {
                size = QSize()
            }
            self.size = size
        }
        
        func size(_ available: QSize) -> QSize {
            let contentSize = self.contentItem.size(available.apply(inset: self.contentInset))
            let contentBounds = contentSize.apply(inset: -self.contentInset)
            let detailSize = self.detailItem.size(available.apply(inset: self.detailInset))
            let detailBounds = detailSize.apply(inset: -self.detailInset)
            return QSize(
                width: max(contentBounds.width, detailBounds.width),
                height: contentBounds.height + detailBounds.height
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
