//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct ZStack : IQCompositionLayoutEntity {
        
        public var entities: [IQCompositionLayoutEntity]
        
        public init(
            entities: [IQCompositionLayoutEntity]
        ) {
            self.entities = entities
        }
        
        public func layout(bounds: QRect) -> QSize {
            var maxSize = QSize.zero
            for entity in self.entities {
                let size = entity.layout(
                    bounds: QRect(
                        topLeft: bounds.topLeft,
                        size: entity.size(available: bounds.size)
                    )
                )
                maxSize = maxSize.max(size)
            }
            return maxSize
        }
        
        public func size(available: QSize) -> QSize {
            var maxSize = QSize.zero
            for entity in self.entities {
                let size = entity.size(available: available)
                maxSize = maxSize.max(size)
            }
            return maxSize
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
