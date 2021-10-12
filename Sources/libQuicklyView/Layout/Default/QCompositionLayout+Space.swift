//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct Space : IQCompositionLayoutEntity {
        
        public var mode: Mode
        public var space: Float
        
        public init(
            mode: Mode,
            space: Float
        ) {
            self.mode = mode
            self.space = space
        }
        
        @discardableResult
        public func layout(bounds: QRect) -> QSize {
            switch self.mode {
            case .horizontal: return QSize(width: self.space, height: bounds.height )
            case .vertical: return QSize(width: bounds.width, height: self.space)
            }
        }
        
        public func size(available: QSize) -> QSize {
            switch self.mode {
            case .horizontal: return QSize(width: self.space, height: available.height )
            case .vertical: return QSize(width: available.width, height: self.space)
            }
        }
        
        public func items(bounds: QRect) -> [QLayoutItem] {
            return []
        }
        
    }
    
}

public extension QCompositionLayout.Space {
    
    enum Mode {
        case horizontal
        case vertical
    }
    
}
