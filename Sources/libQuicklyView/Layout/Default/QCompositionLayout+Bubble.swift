//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct Bubble {
        
        public var content: IQCompositionLayoutEntity
        public var bubble: IQCompositionLayoutEntity
        
        public init(
            content: IQCompositionLayoutEntity,
            bubble: IQCompositionLayoutEntity
        ) {
            self.content = content
            self.bubble = bubble
        }
        
    }
    
}

extension QCompositionLayout.Bubble : IQCompositionLayoutEntity {
    
    public var items: [QLayoutItem] {
        let items = self.content.items
        if items.isEmpty == true {
            return []
        }
        return self.bubble.items + items
    }
    
    @discardableResult
    public func layout(bounds: QRect) -> QSize {
        let size = self.content.layout(bounds: bounds)
        if size.isZero == true {
            return size
        }
        self.bubble.layout(bounds: bounds)
        return size
    }
    
    public func size(available: QSize) -> QSize {
        let size = self.content.size(available: available)
        if size.isZero == true {
            return size
        }
        return size
    }
    
}
