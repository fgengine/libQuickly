//
//  libQuicklyView
//

import Foundation

public class QVLayout : IQDynamicLayout {
    
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
            size = QSize(width: bounds.size.width, height: 0)
            if self.items.count > 0 {
                size.height += self.inset.top
                var origin = QPoint(
                    x: bounds.origin.x + self.inset.left,
                    y: bounds.origin.y + self.inset.top
                )
                let availableWidth = size.width - (self.inset.left + self.inset.right)
                for item in self.items {
                    let itemSize = item.size(QSize(width: availableWidth, height: .infinity))
                    item.frame = QRect(
                        x: origin.x,
                        y: origin.y,
                        width: availableWidth,
                        height: itemSize.height
                    )
                    size.width = max(availableWidth, itemSize.width)
                    size.height += itemSize.height + self.spacing
                    origin.y += itemSize.height + self.spacing
                }
                size.height -= self.spacing
                size.height += self.inset.bottom
                size.width += self.inset.left + self.inset.right
            }
        } else {
            size = QSize()
        }
        self.size = size
    }
    
    public func size(_ available: QSize) -> QSize {
        var size = QSize(width: 0, height: 0)
        if self.items.count > 0 {
            size.height += self.inset.top
            let availableWidth = size.width - (self.inset.left + self.inset.right)
            for item in self.items {
                let itemSize = item.size(QSize(width: availableWidth, height: .infinity))
                size.width = max(availableWidth, itemSize.width)
                size.height += itemSize.height + self.spacing
            }
            size.height -= self.spacing
            size.height += self.inset.bottom
            size.width += self.inset.left + self.inset.right
        }
        return size
    }
    
    public func insert(item: IQLayoutItem, at index: UInt) {
        guard self.items.contains(where: { return $0 === item }) == false else { return }
        self.items.insert(item, at: Int(index))
        self.setNeedUpdate()
    }
    
    public func delete(item: IQLayoutItem) {
        guard let index = self.items.firstIndex(where: { return $0 === item }) else { return }
        self.items.remove(at: Int(index))
        self.setNeedUpdate()
    }
    
}
