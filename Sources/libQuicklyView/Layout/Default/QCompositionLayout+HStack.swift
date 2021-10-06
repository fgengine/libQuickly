//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct HStack : IQCompositionLayoutEntity {
        
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
                width: .infinity,
                height: bounds.height - self.inset.vertical
            )
            var origin = QSize.zero
            for entity in self.entities {
                let size = entity.layout(
                    bounds: QRect(
                        x: bounds.x + self.inset.left + origin.width,
                        y: bounds.y + self.inset.top,
                        size: entity.size(available: itemAvailable)
                    )
                )
                if size.width > 0 {
                    origin.width += size.width + self.spacing
                    origin.height = max(origin.height, size.height)
                }
            }
            if origin.width > 0 {
                origin.width -= self.spacing
            }
            return QSize(
                width: origin.width + self.inset.horizontal,
                height: origin.height + self.inset.vertical
            )
        }
        
        public func size(available: QSize) -> QSize {
            let itemAvailable = QSize(
                width: .infinity,
                height: available.height - self.inset.vertical
            )
            var origin = QSize.zero
            for entity in self.entities {
                let size = entity.size(available: itemAvailable)
                if size.width > 0 {
                    origin.width += size.width + self.spacing
                    origin.height = max(origin.height, size.height)
                }
            }
            if origin.width > 0 {
                origin.width -= self.spacing
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
