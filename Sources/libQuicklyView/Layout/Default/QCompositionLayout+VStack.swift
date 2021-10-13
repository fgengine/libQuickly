//
//  libQuicklyView
//

import Foundation
import libQuicklyCore
import SwiftUI

public extension QCompositionLayout {
    
    struct VStack : IQCompositionLayoutEntity {
        
        public var alignment: Alignment
        public var entities: [IQCompositionLayoutEntity]
        
        public init(
            alignment: Alignment,
            entities: [IQCompositionLayoutEntity]
        ) {
            self.alignment = alignment
            self.entities = entities
        }
        
        @discardableResult
        public func layout(bounds: QRect) -> QSize {
            let pass = self._sizePass(available: bounds.size)
            switch self.alignment {
            case .left: self._layoutLeft(bounds: bounds, pass: pass)
            case .center: self._layoutCenter(bounds: bounds, pass: pass)
            case .right: self._layoutRight(bounds: bounds, pass: pass)
            }
            return pass.bounding
        }
        
        public func size(available: QSize) -> QSize {
            let pass = self._sizePass(available: available)
            return pass.bounding
        }
        
        public func items(bounds: QRect) -> [QLayoutItem] {
            var items: [QLayoutItem] = []
            for entity in self.entities {
                items.append(contentsOf: entity.items(bounds: bounds))
            }
            return items
        }
        
    }
    
}

public extension QCompositionLayout.VStack {
    
    enum Alignment {
        case left
        case center
        case right
    }
    
}

private extension QCompositionLayout.VStack {
    
    struct Pass {
        
        var sizes: [QSize]
        var bounding: QSize
        
    }
    
}

private extension QCompositionLayout.VStack {
    
    @inline(__always)
    func _sizePass(available: QSize) -> Pass {
        var pass = Pass(
            sizes: [],
            bounding: .zero
        )
        for entity in self.entities {
            let size = entity.size(available: available)
            pass.sizes.append(size)
            if size.height > 0 {
                pass.bounding.width = max(pass.bounding.width, size.width)
                pass.bounding.height += size.height
            }
        }
        return pass
    }
    
    @inline(__always)
    func _layoutLeft(bounds: QRect, pass: Pass) {
        var origin = bounds.topLeft
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            entity.layout(bounds: QRect(topLeft: origin, size: size))
            origin.y += size.height
        }
    }
    
    @inline(__always)
    func _layoutCenter(bounds: QRect, pass: Pass) {
        var origin = bounds.top
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            entity.layout(bounds: QRect(top: origin, size: size))
            origin.y += size.height
        }
    }
    
    @inline(__always)
    func _layoutRight(bounds: QRect, pass: Pass) {
        var origin = bounds.topRight
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            entity.layout(bounds: QRect(topRight: origin, size: size))
            origin.y += size.height
        }
    }
    
}
