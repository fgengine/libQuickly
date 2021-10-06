//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct VStack : IQCompositionLayoutEntity {
        
        public let inset: QInset
        public var entities: [IQCompositionLayoutEntity]
        public var spacing: Float
        
        public init(
            inset: QInset = .zero,
            entities: [IQCompositionLayoutEntity],
            spacing: Float = 0
        ) {
            self.inset = inset
            self.entities = entities
            self.spacing = spacing
        }
        
        public func layout(bounds: QRect) -> QSize {
            let itemAvailable = QSize(
                width: bounds.width - self.inset.horizontal,
                height: .infinity
            )
            var origin = QSize.zero
            for entity in self.entities {
                let size = entity.layout(
                    bounds: QRect(
                        x: bounds.x + self.inset.left,
                        y: bounds.y + self.inset.top + origin.height,
                        size: entity.size(available: itemAvailable)
                    )
                )
                if size.height > 0 {
                    origin.width = max(origin.width, size.width)
                    origin.height += size.height + self.spacing
                }
            }
            if origin.height > 0 {
                origin.height -= self.spacing
            }
            return QSize(
                width: origin.width + self.inset.horizontal,
                height: origin.height + self.inset.vertical
            )
        }
        
        public func size(available: QSize) -> QSize {
            let itemAvailable = QSize(
                width: available.width - self.inset.horizontal,
                height: .infinity
            )
            var origin = QSize.zero
            for entity in self.entities {
                let size = entity.size(available: itemAvailable)
                if size.height > 0 {
                    origin.width = max(origin.width, size.width)
                    origin.height += size.height + self.spacing
                }
            }
            if origin.height > 0 {
                origin.height -= self.spacing
            }
            return QSize(
                width: origin.width + self.inset.horizontal,
                height: origin.height + self.inset.vertical
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
