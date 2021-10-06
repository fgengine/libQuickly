//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct Item : IQCompositionLayoutEntity {
        
        public let inset: QInset
        public let useSize: UseSize
        public let alignment: Alignment
        public let item: QLayoutItem
        
        public init(
            inset: QInset = .zero,
            useSize: UseSize = .content,
            alignment: Alignment = .center,
            item: QLayoutItem
        ) {
            self.inset = inset
            self.useSize = useSize
            self.alignment = alignment
            self.item = item
        }
        
        public init(
            inset: QInset = .zero,
            useSize: UseSize = .content,
            alignment: Alignment = .center,
            view: IQView
        ) {
            self.inset = inset
            self.useSize = useSize
            self.alignment = alignment
            self.item = QLayoutItem(view: view)
        }
        
        public func layout(bounds: QRect) -> QSize {
            let availableBounds = bounds.apply(inset: self.inset)
            let size = self.item.size(available: availableBounds.size)
            switch self.alignment {
            case .topLeft: self.item.frame = QRect(topLeft: availableBounds.topLeft, size: size)
            case .top: self.item.frame = QRect(top: availableBounds.top, size: size)
            case .topRight: self.item.frame = QRect(topRight: availableBounds.topRight, size: size)
            case .left: self.item.frame = QRect(left: availableBounds.left, size: size)
            case .center: self.item.frame = QRect(center: availableBounds.center, size: size)
            case .right: self.item.frame = QRect(right: availableBounds.right, size: size)
            case .bottomLeft: self.item.frame = QRect(bottomLeft: availableBounds.bottomLeft, size: size)
            case .bottom: self.item.frame = QRect(bottom: availableBounds.bottom, size: size)
            case .bottomRight: self.item.frame = QRect(bottomRight: availableBounds.bottomRight, size: size)
            }
            switch self.useSize {
            case .inherited: return bounds.size
            case .content: return size.apply(inset: -self.inset)
            }
        }
        
        public func size(available: QSize) -> QSize {
            switch self.useSize {
            case .inherited:
                return available
            case .content:
                let size = self.item.size(available: available.apply(inset: self.inset))
                return size.apply(inset: -self.inset)
            }
        }
        
        public func items(bounds: QRect) -> [QLayoutItem] {
            return [ self.item ]
        }
        
    }
    
}

public extension QCompositionLayout.Item {
    
    enum UseSize {
        case inherited
        case content
    }
    
    enum Alignment {
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
