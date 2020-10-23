//
//  libQuicklyView
//

import Foundation

public struct QContentCellComposition< BackgroundView: IQView, ContentView: IQView > : IQCellComposition {
    
    public private(set) var backgroundView: BackgroundView?
    public var contentInset: QInset {
        set(value) {
            self._layout.contentInset = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.contentInset }
    }
    public private(set) var contentView: ContentView
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
        contentView: ContentView
    ) {
        self.backgroundView = backgroundView
        self.contentView = contentView
        self._layout = Layout(
            backgroundItem: backgroundView.flatMap({ QLayoutItem(view: $0) }),
            contentInset: contentInset,
            contentItem: QLayoutItem(view: contentView)
        )
    }
    
}

extension QContentCellComposition {
    
    class Layout : IQDynamicLayout {
        
        var delegate: IQLayoutDelegate?
        var parentView: IQView?
        var backgroundItem: IQLayoutItem?
        var contentInset: QInset
        var contentItem: IQLayoutItem
        var items: [IQLayoutItem] {
            var items: [IQLayoutItem] = []
            if let item = self.backgroundItem {
                items.append(item)
            }
            items.append(self.contentItem)
            return items
        }
        var size: QSize

        init(
            backgroundItem: IQLayoutItem?,
            contentInset: QInset,
            contentItem: IQLayoutItem
        ) {
            self.backgroundItem = backgroundItem
            self.contentInset = contentInset
            self.contentItem = contentItem
            self.size = QSize()
        }
        
        func layout() {
            var size: QSize
            if let bounds = self.delegate?.bounds(self) {
                size = bounds.size
                if let item = self.backgroundItem {
                    item.frame = bounds
                }
                self.contentItem.frame = bounds.apply(inset: self.contentInset)
            } else {
                size = QSize()
            }
            self.size = size
        }
        
        func size(_ available: QSize) -> QSize {
            let contentSize = self.contentItem.size(available.apply(inset: self.contentInset))
            let contentBounds = contentSize.apply(inset: -self.contentInset)
            return contentBounds
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
