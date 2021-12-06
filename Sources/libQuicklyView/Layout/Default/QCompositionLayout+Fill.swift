//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct Fill {
        
        public var mode: Mode
        public var entity: IQCompositionLayoutEntity
        
        public init(
            mode: Mode,
            entity: IQCompositionLayoutEntity
        ) {
            self.mode = mode
            self.entity = entity
        }
        
    }
    
}

public extension QCompositionLayout.Fill {
    
    enum Mode {
        case horizontal
        case vertical
        case both
    }
    
}

extension QCompositionLayout.Fill : IQCompositionLayoutEntity {
    
    public func invalidate(item: QLayoutItem) {
        self.entity.invalidate(item: item)
    }
    
    @discardableResult
    public func layout(bounds: QRect) -> QSize {
        switch self.mode {
        case .horizontal:
            let size = self.entity.size(available: bounds.size)
            return self.entity.layout(
                bounds: QRect(
                    x: bounds.x,
                    y: bounds.y,
                    width: bounds.width,
                    height: size.height
                )
            )
        case .vertical:
            let size = self.entity.size(available: bounds.size)
            return self.entity.layout(
                bounds: QRect(
                    x: bounds.x,
                    y: bounds.y,
                    width: size.width,
                    height: bounds.height
                )
            )
        case .both:
            return self.entity.layout(bounds: bounds)
        }
    }
    
    public func size(available: QSize) -> QSize {
        switch self.mode {
        case .horizontal:
            let size = self.entity.size(available: available)
            return QSize(
                width: available.width,
                height: size.height
            )
        case .vertical:
            let size = self.entity.size(available: available)
            return QSize(
                width: size.width,
                height: available.height
            )
        case .both:
            return available
        }
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return self.entity.items(bounds: bounds)
    }
    
}
