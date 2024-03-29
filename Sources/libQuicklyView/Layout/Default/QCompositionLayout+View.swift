//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct View {
        
        public let item: QLayoutItem
        
        public init(
            _ item: QLayoutItem
        ) {
            self.item = item
        }
        
        public init(
            _ view: IQView
        ) {
            self.item = QLayoutItem(view: view)
        }
        
    }
    
}

extension QCompositionLayout.View : IQCompositionLayoutEntity {
    
    public func invalidate(item: QLayoutItem) {
    }
    
    @discardableResult
    public func layout(bounds: QRect) -> QSize {
        self.item.frame = bounds
        return bounds.size
    }
    
    public func size(available: QSize) -> QSize {
        return self.item.size(available: available)
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        guard self.item.isHidden == false else { return [] }
        return [ self.item ]
    }
    
}
