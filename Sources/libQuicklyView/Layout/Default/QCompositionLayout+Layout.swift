//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct Layout {
        
        public let layout: IQLayout
        
        public init(
            _ layout: IQLayout
        ) {
            self.layout = layout
        }
        
    }
    
}

extension QCompositionLayout.Layout : IQCompositionLayoutEntity {
    
    public func invalidate(item: QLayoutItem) {
        self.layout.invalidate(item: item)
    }
    
    @discardableResult
    public func layout(bounds: QRect) -> QSize {
        return self.layout.layout(bounds: bounds)
    }
    
    public func size(available: QSize) -> QSize {
        return self.layout.size(available: available)
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return self.layout.items(bounds: bounds)
    }
    
}
