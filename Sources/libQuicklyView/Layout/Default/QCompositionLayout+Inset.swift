//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct Inset {
        
        public let inset: QInset
        public var entity: IQCompositionLayoutEntity
        
        public init(
            inset: QInset,
            entity: IQCompositionLayoutEntity
        ) {
            self.inset = inset
            self.entity = entity
        }
        
    }
    
}

extension QCompositionLayout.Inset : IQCompositionLayoutEntity {
    
    public func invalidate(item: QLayoutItem) {
        self.entity.invalidate(item: item)
    }
    
    @discardableResult
    public func layout(bounds: QRect) -> QSize {
        let size = self.entity.layout(
            bounds: bounds.apply(inset: self.inset)
        )
        if size.isZero == true {
            return size
        }
        return size.apply(inset: -self.inset)
    }
    
    public func size(available: QSize) -> QSize {
        let size = self.entity.size(
            available: available.apply(inset: self.inset)
        )
        if size.isZero == true {
            return size
        }
        return size.apply(inset: -self.inset)
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return self.entity.items(bounds: bounds)
    }
    
}
