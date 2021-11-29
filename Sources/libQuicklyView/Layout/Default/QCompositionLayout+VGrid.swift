//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct VGrid {
        
        public var columns: Int
        public var spacing: QPoint
        public var entities: [IQCompositionLayoutEntity]
        
        public init(
            columns: Int,
            spacing: QPoint = .zero,
            entities: [IQCompositionLayoutEntity]
        ) {
            self.columns = max(1, columns)
            self.spacing = spacing
            self.entities = entities
        }
        
    }
    
}

private extension QCompositionLayout.VGrid {
    
    struct Pass {
        
        var rows: [PassRow]
        var bounding: QSize
        
    }
    
    struct PassRow {
        
        var items: [PassItem]
        var size: Float
        
    }
    
    struct PassItem {
        
        var entity: IQCompositionLayoutEntity
        var size: QSize
        
    }
    
}

extension QCompositionLayout.VGrid : IQCompositionLayoutEntity {
    
    public var items: [QLayoutItem] {
        var items: [QLayoutItem] = []
        for entity in self.entities {
            items.append(contentsOf: entity.items)
        }
        return items
    }
    
    @discardableResult
    public func layout(bounds: QRect) -> QSize {
        let pass = self._pass(available: QSize(
            width: bounds.width,
            height: .infinity
        ))
        self._layout(bounds: bounds, pass: pass)
        return pass.bounding
    }
    
    public func size(available: QSize) -> QSize {
        let pass = self._pass(available: QSize(
            width: available.width,
            height: .infinity
        ))
        return pass.bounding
    }
    
}

private extension QCompositionLayout.VGrid {
    
    @inline(__always)
    func _width(available: QSize) -> Float {
        if self.columns > 1 {
            return (available.width - (self.spacing.x * Float(self.columns - 1))) / Float(self.columns)
        }
        return available.width
    }
    
    @inline(__always)
    func _height(items: [PassItem]) -> Float {
        var height: Float = 0
        for item in items {
            height = max(height, item.size.height)
        }
        return height
    }
    
    @inline(__always)
    func _pass(available: QSize) -> Pass {
        var pass = Pass(rows: [], bounding: .zero)
        var row = PassRow(items: [], size: 0)
        let width = self._width(available: available)
        for entity in self.entities {
            let size = entity.size(available: QSize(
                width: width,
                height: available.height
            ))
            if size.height > 0 {
                let item = PassItem(entity: entity, size: size)
                row.items.append(item)
                row.size = max(row.size, size.height)
            }
            if row.items.count >= self.columns {
                pass.rows.append(row)
                pass.bounding.height += row.size + self.spacing.y
                row = PassRow(items: [], size: 0)
            }
        }
        if row.items.count > 0 {
            pass.bounding.height += row.size + self.spacing.y
            pass.rows.append(row)
        }
        if pass.bounding.height > 0 {
            pass.bounding.width = available.width
            pass.bounding.height -= self.spacing.y
        }
        return pass
    }
    
    @inline(__always)
    func _layout(bounds: QRect, pass: Pass) {
        var originY = bounds.y
        for row in pass.rows {
            var originX = bounds.x
            for item in row.items {
                item.entity.layout(bounds: QRect(
                    x: originX,
                    y: originY,
                    width: item.size.width,
                    height: item.size.height
                ))
                originX += item.size.width + self.spacing.x
            }
            originY += row.size + self.spacing.y
        }
    }
    
}
