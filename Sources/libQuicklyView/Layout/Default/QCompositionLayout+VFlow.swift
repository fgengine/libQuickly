//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct VFlow {
        
        public var alignment: Alignment
        public var entitySpacing: Float
        public var lineSpacing: Float
        public var entities: [IQCompositionLayoutEntity]

        public init(
            alignment: Alignment = .center,
            entitySpacing: Float,
            lineSpacing: Float,
            entities: [IQCompositionLayoutEntity]
        ) {
            self.entities = entities
            self.alignment = alignment
            self.entitySpacing = entitySpacing
            self.lineSpacing = lineSpacing
        }
        
    }
    
}

public extension QCompositionLayout.VFlow {
    
    enum Alignment {
        case left
        case center
        case right
    }
    
}

extension QCompositionLayout.VFlow : IQCompositionLayoutEntity {
    
    public var items: [QLayoutItem] {
        var items: [QLayoutItem] = []
        for entity in self.entities {
            items.append(contentsOf: entity.items)
        }
        return items
    }
    
    @discardableResult
    public func layout(bounds: QRect) -> QSize {
        let itemRange = Range(
            uncheckedBounds: (
                lower: bounds.x,
                upper: bounds.x + bounds.width
            )
        )
        var itemsSize: QSize = .zero
        var items: [Item] = []
        var line: Float = 0
        for entity in self.entities {
            let item = Item(
                entity: entity,
                size: entity.size(available: bounds.size)
            )
            if item.size.width > 0 {
                let newItems = items + [ item ]
                let newItemsSize = self._size(newItems)
                if newItemsSize.width >= bounds.width {
                    let layoutSize = self._layout(items, itemsSize, itemRange, line)
                    line += layoutSize.height + self.lineSpacing
                    itemsSize = item.size
                    items = [ item ]
                } else {
                    itemsSize = newItemsSize
                    items = newItems
                }
            }
        }
        if items.count > 0 {
            let layoutSize = self._layout(items, itemsSize, itemRange, line)
            line += layoutSize.height + self.lineSpacing
        }
        if line > 0 {
            line -= self.lineSpacing
        }
        return QSize(
            width: bounds.width,
            height: line
        )
    }
    
    public func size(available: QSize) -> QSize {
        var itemsSize: QSize = .zero
        var items: [Item] = []
        var line: Float = 0
        for entity in self.entities {
            let item = Item(
                entity: entity,
                size: entity.size(available: available)
            )
            if item.size.width > 0 {
                let newItems = items + [ item ]
                let newItemsSize = self._size(newItems)
                if newItemsSize.width >= available.width {
                    line += itemsSize.height + self.lineSpacing
                    itemsSize = item.size
                    items = [ item ]
                } else {
                    itemsSize = newItemsSize
                    items = newItems
                }
            }
        }
        if items.count > 0 {
            line += itemsSize.height + self.lineSpacing
        }
        if line > 0 {
            line -= self.lineSpacing
        }
        return QSize(
            width: available.width,
            height: line
        )
    }
    
}

private extension QCompositionLayout.VFlow {
    
    struct Item {
        
        let entity: IQCompositionLayoutEntity
        let size: QSize
        
    }
    
}

private extension QCompositionLayout.VFlow {
    
    @inline(__always)
    func _layout(_ items: [Item], _ itemsSize: QSize, _ bounds: Range< Float >, _ line: Float) -> QSize {
        var size: QSize = .zero
        switch self.alignment {
        case .left:
            var offset = bounds.lowerBound
            for item in items {
                guard item.size.width > 0 else { continue }
                let itemSize = item.entity.layout(
                    bounds: QRect(
                        topLeft: QPoint(
                            x: offset,
                            y: line
                        ),
                        size: item.size
                    )
                )
                size.width += itemSize.width + self.entitySpacing
                size.height = max(size.height, itemSize.height)
                offset += item.size.width + self.entitySpacing
            }
        case .center:
            var offset = bounds.lowerBound
            let center = bounds.lowerBound + ((bounds.upperBound - bounds.lowerBound) / 2)
            let itemsCenter = itemsSize.width / 2
            for item in items {
                guard item.size.width > 0 else { continue }
                let itemSize = item.entity.layout(
                    bounds: QRect(
                        topLeft: QPoint(
                            x: (center - itemsCenter) + offset,
                            y: line
                        ),
                        size: item.size
                    )
                )
                size.width += itemSize.width + self.entitySpacing
                size.height = max(size.height, itemSize.height)
                offset += item.size.width + self.entitySpacing
            }
        case .right:
            var offset = bounds.upperBound
            for item in items.reversed() {
                guard item.size.width > 0 else { continue }
                let itemSize = item.entity.layout(
                    bounds: QRect(
                        topRight: QPoint(
                            x: offset,
                            y: line
                        ),
                        size: item.size
                    )
                )
                size.width += itemSize.width + self.entitySpacing
                size.height = max(size.height, itemSize.height)
                offset -= item.size.width + self.entitySpacing
            }
        }
        if size.width > 0 {
            size.width -= self.entitySpacing
        }
        return size
    }
    
    @inline(__always)
    func _size(_ items: [Item]) -> QSize {
        var size: QSize = .zero
        for item in items {
            size.width += item.size.width + self.entitySpacing
            size.height = max(size.height, item.size.height)
        }
        if size.width > 0 {
            size.width -= self.entitySpacing
        }
        return size
    }

}
