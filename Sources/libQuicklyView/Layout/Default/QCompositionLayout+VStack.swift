//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct VStack : IQCompositionLayoutEntity {
        
        public var entities: [IQCompositionLayoutEntity]
        
        public init(
            _ entities: [IQCompositionLayoutEntity]
        ) {
            self.entities = entities
        }
        
        @discardableResult
        public func layout(bounds: QRect) -> QSize {
            var origin = QSize.zero
            for entity in self.entities {
                let size = entity.layout(
                    bounds: QRect(
                        x: bounds.x,
                        y: bounds.y + origin.height,
                        size: entity.size(available: bounds.size)
                    )
                )
                if size.height > 0 {
                    origin.width = max(origin.width, size.width)
                    origin.height += size.height
                }
            }
            return QSize(
                width: origin.width,
                height: origin.height
            )
        }
        
        public func size(available: QSize) -> QSize {
            var origin = QSize.zero
            for entity in self.entities {
                let size = entity.size(available: available)
                if size.height > 0 {
                    origin.width = max(origin.width, size.width)
                    origin.height += size.height
                }
            }
            return QSize(
                width: origin.width,
                height: origin.height
            )
        }
        
        public func items(bounds: QRect) -> [QLayoutItem] {
            var items: [QLayoutItem] = []
            for entity in self.entities {
                items.append(contentsOf: entity.items(bounds: bounds))
            }
            return items
        }
        
    }
    
}
