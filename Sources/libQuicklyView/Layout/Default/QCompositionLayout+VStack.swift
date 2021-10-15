//
//  libQuicklyView
//

import Foundation
import libQuicklyCore
import SwiftUI

public extension QCompositionLayout {
    
    struct VStack {
        
        public var alignment: Alignment
        public var spacing: Float
        public var entities: [IQCompositionLayoutEntity]
        
        public init(
            alignment: Alignment,
            spacing: Float = 0,
            entities: [IQCompositionLayoutEntity]
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.entities = entities
        }
        
    }
    
}

public extension QCompositionLayout.VStack {
    
    enum Alignment {
        case left
        case center
        case right
        case fill
    }
    
}

private extension QCompositionLayout.VStack {
    
    struct Pass {
        
        var sizes: [QSize]
        var bounding: QSize
        
    }
    
}

extension QCompositionLayout.VStack : IQCompositionLayoutEntity {
    
    public var items: [QLayoutItem] {
        var items: [QLayoutItem] = []
        for entity in self.entities {
            items.append(contentsOf: entity.items)
        }
        return items
    }
    
    @discardableResult
    public func layout(bounds: QRect) -> QSize {
        let pass = self._sizePass(available: bounds.size)
        switch self.alignment {
        case .left: self._layoutLeft(bounds: bounds, pass: pass)
        case .center: self._layoutCenter(bounds: bounds, pass: pass)
        case .right: self._layoutRight(bounds: bounds, pass: pass)
        case .fill: self._layoutFill(bounds: bounds, pass: pass)
        }
        return pass.bounding
    }
    
    public func size(available: QSize) -> QSize {
        let pass = self._sizePass(available: available)
        return pass.bounding
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
                pass.bounding.height += size.height + self.spacing
            }
        }
        if pass.bounding.height > 0 {
            pass.bounding.height -= self.spacing
        }
        return pass
    }
    
    @inline(__always)
    func _layoutLeft(bounds: QRect, pass: Pass) {
        var origin = bounds.topLeft
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            guard size.height > 0 else { continue }
            entity.layout(bounds: QRect(topLeft: origin, size: size))
            origin.y += size.height + self.spacing
        }
    }
    
    @inline(__always)
    func _layoutCenter(bounds: QRect, pass: Pass) {
        var origin = bounds.top
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            guard size.height > 0 else { continue }
            entity.layout(bounds: QRect(top: origin, size: size))
            origin.y += size.height + self.spacing
        }
    }
    
    @inline(__always)
    func _layoutRight(bounds: QRect, pass: Pass) {
        var origin = bounds.topRight
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            guard size.height > 0 else { continue }
            entity.layout(bounds: QRect(topRight: origin, size: size))
            origin.y += size.height + self.spacing
        }
    }
    
    @inline(__always)
    func _layoutFill(bounds: QRect, pass: Pass) {
        var origin = bounds.topLeft
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            guard size.height > 0 else { continue }
            entity.layout(bounds: QRect(topLeft: origin, width: bounds.width, height: size.height))
            origin.y += size.height + self.spacing
        }
    }
    
}
