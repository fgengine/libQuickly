//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct None {
        
        public init() {
        }
        
    }
    
}

extension QCompositionLayout.None : IQCompositionLayoutEntity {
    
    public func invalidate(item: QLayoutItem) {
    }
    
    @discardableResult
    public func layout(bounds: QRect) -> QSize {
        return .zero
    }
    
    public func size(available: QSize) -> QSize {
        return .zero
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return []
    }
    
}
