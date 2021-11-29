//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct Overlay {
        
        public var content: IQCompositionLayoutEntity
        public var overlay: IQCompositionLayoutEntity
        
        public init(
            content: IQCompositionLayoutEntity,
            overlay: IQCompositionLayoutEntity
        ) {
            self.content = content
            self.overlay = overlay
        }
        
    }
    
}

extension QCompositionLayout.Overlay : IQCompositionLayoutEntity {
    
    public var items: [QLayoutItem] {
        let items = self.content.items
        if items.isEmpty == true {
            return []
        }
        return items + self.overlay.items
    }
    
    @discardableResult
    public func layout(bounds: QRect) -> QSize {
        let size = self.content.layout(bounds: bounds)
        if size.isZero == true {
            return size
        }
        self.overlay.layout(bounds: bounds)
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
