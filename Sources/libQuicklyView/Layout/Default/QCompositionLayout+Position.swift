//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct Position : IQCompositionLayoutEntity {
        
        public var mode: Mode
        public var entity: IQCompositionLayoutEntity
        
        public init(
            mode: Mode,
            entity: IQCompositionLayoutEntity
        ) {
            self.mode = mode
            self.entity = entity
        }
        
        @discardableResult
        public func layout(bounds: QRect) -> QSize {
            let size = self.entity.size(available: bounds.size)
            switch self.mode {
            case .topLeft: return self.entity.layout(bounds: QRect(topLeft: bounds.topLeft, size: size))
            case .top: return self.entity.layout(bounds: QRect(top: bounds.top, size: size))
            case .topRight: return self.entity.layout(bounds: QRect(topRight: bounds.topRight, size: size))
            case .left: return self.entity.layout(bounds: QRect(left: bounds.left, size: size))
            case .center: return self.entity.layout(bounds: QRect(center: bounds.center, size: size))
            case .right: return self.entity.layout(bounds: QRect(right: bounds.right, size: size))
            case .bottomLeft: return self.entity.layout(bounds: QRect(bottomLeft: bounds.bottomLeft, size: size))
            case .bottom: return self.entity.layout(bounds: QRect(bottom: bounds.bottom, size: size))
            case .bottomRight: return self.entity.layout(bounds: QRect(bottomRight: bounds.bottomRight, size: size))
            }
        }
        
        public func size(available: QSize) -> QSize {
            return self.entity.size(available: available)
        }
        
        public func items(bounds: QRect) -> [QLayoutItem] {
            return self.entity.items(bounds: bounds)
        }
        
    }
    
}

public extension QCompositionLayout.Position {
    
    enum Mode {
        case topLeft
        case top
        case topRight
        case left
        case center
        case right
        case bottomLeft
        case bottom
        case bottomRight
    }
    
}
