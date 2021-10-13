//
//  libQuicklyView
//

import Foundation
import libQuicklyCore
import SwiftUI

public extension QCompositionLayout {
    
    struct HStack : IQCompositionLayoutEntity {
        
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
            case .top: self._layoutTop(bounds: bounds, pass: pass)
            case .center: self._layoutCenter(bounds: bounds, pass: pass)
            case .bottom: self._layoutBottom(bounds: bounds, pass: pass)
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

public extension QCompositionLayout.HStack {
    
    enum Alignment {
        case top
        case center
        case bottom
    }
    
}

private extension QCompositionLayout.HStack {
    
    struct Pass {
        
        var sizes: [QSize]
        var bounding: QSize
        
    }
    
}

private extension QCompositionLayout.HStack {
    
    @inline(__always)
    func _sizePass(available: QSize) -> Pass {
        var pass = Pass(
            sizes: [],
            bounding: .zero
        )
        for entity in self.entities {
            let size = entity.size(available: available)
            pass.sizes.append(size)
            if size.width > 0 {
                pass.bounding.width += size.width
                pass.bounding.height = max(pass.bounding.height, size.height)
            }
        }
        return pass
    }
    
    @inline(__always)
    func _layoutTop(bounds: QRect, pass: Pass) {
        var origin = bounds.topLeft
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            entity.layout(bounds: QRect(topLeft: origin, size: size))
            origin.x += size.width
        }
    }
    
    @inline(__always)
    func _layoutCenter(bounds: QRect, pass: Pass) {
        var origin = bounds.left
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            entity.layout(bounds: QRect(left: origin, size: size))
            origin.x += size.width
        }
    }
    
    @inline(__always)
    func _layoutBottom(bounds: QRect, pass: Pass) {
        var origin = bounds.bottomLeft
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            entity.layout(bounds: QRect(bottomLeft: origin, size: size))
            origin.x += size.width
        }
    }
    
}
