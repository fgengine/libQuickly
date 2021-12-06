//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct Space {
        
        public var mode: Mode
        public var space: Float
        
        public init(
            mode: Mode,
            space: Float
        ) {
            self.mode = mode
            self.space = space
        }
        
    }
    
}

public extension QCompositionLayout.Space {
    
    enum Mode {
        case horizontal
        case vertical
    }
    
}

extension QCompositionLayout.Space : IQCompositionLayoutEntity {
    
    public func invalidate(item: QLayoutItem) {
    }
    
    @discardableResult
    public func layout(bounds: QRect) -> QSize {
        switch self.mode {
        case .horizontal: return QSize(width: self.space, height: 0)
        case .vertical: return QSize(width: 0, height: self.space)
        }
    }
    
    public func size(available: QSize) -> QSize {
        switch self.mode {
        case .horizontal: return QSize(width: self.space, height: 0)
        case .vertical: return QSize(width: 0, height: self.space)
        }
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return []
    }
    
}
