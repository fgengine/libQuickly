//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct ZStack {
        
        public var size: Size
        public var entities: [IQCompositionLayoutEntity]
        
        public init(
            _ entities: [IQCompositionLayoutEntity]
        ) {
            self.size = []
            self.entities = entities
        }
        
        public init(
            size: Size = [],
            entities: [IQCompositionLayoutEntity]
        ) {
            self.size = size
            self.entities = entities
        }
        
    }
    
}

public extension QCompositionLayout.ZStack {
    
    struct Size : OptionSet {
        
        public var rawValue: UInt
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        public static let horizontal = Size(rawValue: 1 << 0)
        public static let vertical = Size(rawValue: 1 << 1)
        
    }
    
}

extension QCompositionLayout.ZStack : IQCompositionLayoutEntity {
    
    public func invalidate(item: QLayoutItem) {
        for entity in self.entities {
            entity.invalidate(item: item)
        }
    }
    
    @discardableResult
    public func layout(bounds: QRect) -> QSize {
        var maxSize = QSize.zero
        if self.size.contains(.horizontal) == true {
            maxSize.width = bounds.width
        }
        if self.size.contains(.vertical) == true {
            maxSize.height = bounds.height
        }
        for entity in self.entities {
            let size = entity.size(available: bounds.size)
            maxSize = maxSize.max(size)
        }
        for entity in self.entities {
            entity.layout(
                bounds: QRect(
                    topLeft: bounds.topLeft,
                    size: maxSize
                )
            )
        }
        return maxSize
    }
    
    public func size(available: QSize) -> QSize {
        var maxSize = QSize.zero
        if self.size.contains(.horizontal) == true {
            maxSize.width = available.width
        }
        if self.size.contains(.vertical) == true {
            maxSize.height = available.height
        }
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
