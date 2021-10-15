//
//  libQuicklyView
//

import Foundation
import libQuicklyCore
import SwiftUI

public extension QCompositionLayout {
    
    struct HFullStack {
        
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

public extension QCompositionLayout.HFullStack {
    
    enum Alignment {
        case top
        case center
        case bottom
    }
    
}

extension QCompositionLayout.HFullStack : IQCompositionLayoutEntity {
    
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
        case .top: self._layoutTop(bounds: bounds, pass: pass)
        case .center: self._layoutCenter(bounds: bounds, pass: pass)
        case .bottom: self._layoutBottom(bounds: bounds, pass: pass)
        }
        return QSize(
            width: bounds.width,
            height: pass.bounding
        )
    }
    
    public func size(available: QSize) -> QSize {
        let pass = self._sizePass(available: available)
        return QSize(
            width: available.width,
            height: pass.bounding
        )
    }
    
}

private extension QCompositionLayout.HFullStack {
    
    struct Pass {
        
        var sizes: [Float]
        var bounding: Float
        
    }
    
}

private extension QCompositionLayout.HFullStack {
    
    @inline(__always)
    func _entitySize(available: QSize, pass: Pass) -> Float {
        let count = pass.sizes.count(where: { $0 > 0 })
        if self.entities.count > 1 {
            return (available.width - (self.spacing * Float(count - 1))) / Float(count)
        }
        return available.width
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
            if size.width > 0 {
                pass.bounding = max(pass.bounding, size.height)
            }
        }
        return pass
    }
    
    @inline(__always)
    func _layoutTop(bounds: QRect, pass: Pass) {
        let entitySize = self._entitySize(available: bounds.size, pass: pass)
        var origin = bounds.topLeft
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            entity.layout(bounds: QRect(topLeft: origin, width: entitySize, height: size))
            origin.x += entitySize + self.spacing
        }
    }
    
    @inline(__always)
    func _layoutCenter(bounds: QRect, pass: Pass) {
        let entitySize = self._entitySize(available: bounds.size, pass: pass)
        var origin = bounds.left
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            guard size > 0 else { continue }
            entity.layout(bounds: QRect(left: origin, width: entitySize, height: size))
            origin.x += entitySize + self.spacing
        }
    }
    
    @inline(__always)
    func _layoutBottom(bounds: QRect, pass: Pass) {
        let entitySize = self._entitySize(available: bounds.size, pass: pass)
        var origin = bounds.bottomLeft
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            guard size > 0 else { continue }
            entity.layout(bounds: QRect(bottomLeft: origin, width: entitySize, height: size))
            origin.x += entitySize + self.spacing
        }
    }
    
}
