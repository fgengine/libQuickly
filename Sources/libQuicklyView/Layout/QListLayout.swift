//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QListLayout : IQLayout {
    
    public weak var delegate: IQLayoutDelegate?
    public weak var parentView: IQView?
    public private(set) var mode: Mode
    public var inset: QInset
    public var spacing: QFloat
    public private(set) var items: [IQLayoutItem]
    public private(set) var size: QSize

    public init(
        mode: Mode,
        inset: QInset = QInset(),
        spacing: QFloat = 0,
        items: [IQLayoutItem]
    ) {
        self.mode = mode
        self.inset = inset
        self.spacing = spacing
        self.items = items
        self.size = QSize()
    }

    public convenience init(
        mode: Mode,
        inset: QInset = QInset(),
        spacing: QFloat = 0,
        views: [IQView]
    ) {
        self.init(
            mode: mode,
            inset: inset,
            spacing: spacing,
            items: views.compactMap({ return QLayoutItem(view: $0) })
        )
    }
    
    public func layout() {
        var size: QSize
        if let bounds = self.delegate?.bounds(self) {
            switch self.mode {
            case .horizontal:
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
            case .vertical:
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
            }
        } else {
            size = QSize()
        }
        self.size = size
    }
    
    public func size(_ available: QSize) -> QSize {
        var size = QSize(width: 0, height: 0)
        if self.items.count > 0 {
            switch self.mode {
            case .horizontal:
                size.width += self.inset.left
                let availableHeight = size.height - (self.inset.top + self.inset.bottom)
                for item in self.items {
                    let itemSize = item.size(QSize(width: .infinity, height: availableHeight))
                    size.width += itemSize.width + self.spacing
                    size.height = max(availableHeight, itemSize.height)
                }
                size.width -= self.spacing
                size.width += self.inset.right
                size.height += self.inset.top + self.inset.bottom
            case .vertical:
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
        }
        return size
    }
    
}

public extension QListLayout {
    
    enum Mode {
        case horizontal
        case vertical
    }
    
}
