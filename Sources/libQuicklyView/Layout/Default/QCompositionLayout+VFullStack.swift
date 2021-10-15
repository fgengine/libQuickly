//
//  libQuicklyView
//

import Foundation
import libQuicklyCore
import SwiftUI

public extension QCompositionLayout {
    
    struct VFullStack {
        
        public var alignment: Alignment
        public var spacing: Float
        public var entities: [IQCompositionLayoutEntity]
        
        public init(
            alignment: Alignment,
            spacing: Float,
            entities: [IQCompositionLayoutEntity]
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.entities = entities
        }
        
    }
    
}

public extension QCompositionLayout.VFullStack {
    
    enum Alignment {
        case left
        case center
        case right
    }
    
}

extension QCompositionLayout.VFullStack : IQCompositionLayoutEntity {
    
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
        }
        return QSize(
            width: pass.bounding,
            height: bounds.width
        )
    }
    
    public func size(available: QSize) -> QSize {
        let pass = self._sizePass(available: available)
        return QSize(
            width: pass.bounding,
            height: available.width
        )
    }
    
}

private extension QCompositionLayout.VFullStack {
    
    struct Pass {
        
        var sizes: [Float]
        var bounding: Float
        
    }
    
}

private extension QCompositionLayout.VFullStack {
    
    @inline(__always)
    func _entitySize(available: QSize, pass: Pass) -> Float {
        let count = pass.sizes.count(where: { $0 > 0 })
        if count > 1 {
            return (available.height - (self.spacing * Float(count - 1))) / Float(count)
        }
        return available.height
    }
    
    @inline(__always)
    func _sizePass(available: QSize) -> Pass {
        var pass = Pass(
            sizes: [],
            bounding: .zero
        )
        for entity in self.entities {
            let size = entity.size(available: available)
            pass.sizes.append(size.height)
            if size.height > 0 {
                pass.bounding = max(pass.bounding, size.width)
            }
        }
        return pass
    }
    
    @inline(__always)
    func _layoutLeft(bounds: QRect, pass: Pass) {
        let entitySize = self._entitySize(available: bounds.size, pass: pass)
        var origin = bounds.topLeft
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            guard size > 0 else { continue }
            entity.layout(bounds: QRect(topLeft: origin, width: size, height: entitySize))
            origin.y += entitySize + self.spacing
        }
    }
    
    @inline(__always)
    func _layoutCenter(bounds: QRect, pass: Pass) {
        let entitySize = self._entitySize(available: bounds.size, pass: pass)
        var origin = bounds.left
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            guard size > 0 else { continue }
            entity.layout(bounds: QRect(top: origin, width: size, height: entitySize))
            origin.y += entitySize + self.spacing
        }
    }
    
    @inline(__always)
    func _layoutRight(bounds: QRect, pass: Pass) {
        let entitySize = self._entitySize(available: bounds.size, pass: pass)
        var origin = bounds.bottomLeft
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            guard size > 0 else { continue }
            entity.layout(bounds: QRect(topRight: origin, width: size, height: entitySize))
            origin.y += entitySize + self.spacing
        }
    }
    
}
