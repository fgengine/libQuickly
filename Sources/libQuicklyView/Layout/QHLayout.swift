//
//  libQuicklyView
//

import Foundation

public class QHLayout : IQDynamicLayout {
    
    public weak var delegate: IQLayoutDelegate?
    public weak var parentView: IQView?
    public var inset: QInset
    public var spacing: QFloat
    public private(set) var items: [IQLayoutItem]
    public private(set) var size: QSize

    public init(inset: QInset, spacing: QFloat, items: [IQLayoutItem]) {
        self.inset = inset
        self.spacing = spacing
        self.items = items
        self.size = QSize()
    }

    public init(inset: QInset, spacing: QFloat, views: [IQView]) {
        self.inset = inset
        self.spacing = spacing
        self.items = views.compactMap({ return QLayoutItem(view: $0) })
        self.size = QSize()
    }
    
    public func layout() {
        var size: QSize
        if let bounds = self.delegate?.bounds(self) {
            size = QSize(width: 0, height: bounds.size.height)
            if self.items.count > 0 {
                size.width += self.inset.left
                var origin = QPoint(
                    x: bounds.origin.x + self.inset.left,
                    y: bounds.origin.y + self.inset.top
                )
                let availableHeight = size.height - (self.inset.top + self.inset.bottom)
                for item in self.items {
                    let itemSize = item.size(QSize(width: .infinity, height: availableHeight))
                    item.frame = QRect(
                        x: origin.x + size.width,
                        y: origin.y,
                        width: itemSize.width,
                        height: availableHeight
                    )
                    size.width += itemSize.width + self.spacing
                    size.height = max(availableHeight, itemSize.height)
                    origin.x += itemSize.width + self.spacing
                }
                size.width -= self.spacing
                size.width += self.inset.right
                size.height += self.inset.top + self.inset.bottom
            }
        } else {
            size = QSize()
        }
        self.size = size
    }
    
    public func size(_ available: QSize) -> QSize {
        var size = QSize(width: 0, height: 0)
        if self.items.count > 0 {
            size.width += self.inset.left
            let availableHeight = size.height - (self.inset.top + self.inset.bottom)
            for item in self.items {
                let itemSize = item.size(QSize(width: .infinity, height: availableHeight))
                size.width += itemSize.width + self.spacing
                size.height = max(availableHeight, itemSize.height)
            }
            size.height -= self.spacing
            size.width += self.inset.right
            size.height += self.inset.top + self.inset.bottom
        }
        return size
    }
    
    public func insert(item: IQLayoutItem, at index: UInt) {
        guard self.items.contains(where: { return $0 === item }) == false else { return }
        self.items.insert(item, at: Int(index))
        self.layout()
        self.setNeedUpdate()
    }
    
    public func delete(item: IQLayoutItem) {
        guard let index = self.items.firstIndex(where: { return $0 === item }) else { return }
        self.items.remove(at: Int(index))
        self.layout()
        self.setNeedUpdate()
    }
    
}
