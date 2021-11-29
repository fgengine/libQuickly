//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct HStack {
        
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

public extension QCompositionLayout.HStack {
    
    enum Alignment {
        case top
        case center
        case bottom
        case fill
    }
    
}

extension QCompositionLayout.HStack : IQCompositionLayoutEntity {
    
    public var items: [QLayoutItem] {
        var items: [QLayoutItem] = []
        for entity in self.entities {
            items.append(contentsOf: entity.items)
        }
        return items
    }
    
    @discardableResult
    public func layout(bounds: QRect) -> QSize {
        let pass = self._sizePass(available: QSize(
            width: .infinity,
            height: bounds.height
        ))
        switch self.alignment {
        case .top: self._layoutTop(bounds: bounds, pass: pass)
        case .center: self._layoutCenter(bounds: bounds, pass: pass)
        case .bottom: self._layoutBottom(bounds: bounds, pass: pass)
        case .fill: self._layoutFill(bounds: bounds, pass: pass)
        }
        return pass.bounding
    }
    
    public func size(available: QSize) -> QSize {
        let pass = self._sizePass(available: QSize(
            width: .infinity,
            height: available.height
        ))
        return pass.bounding
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
                pass.bounding.width += size.width + self.spacing
                pass.bounding.height = max(pass.bounding.height, size.height)
            }
        }
        if pass.bounding.width > 0 {
            pass.bounding.width -= self.spacing
        }
        return pass
    }
    
    @inline(__always)
    func _layoutTop(bounds: QRect, pass: Pass) {
        var origin = bounds.topLeft
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            guard size.width > 0 else { continue }
            entity.layout(bounds: QRect(topLeft: origin, size: size))
            origin.x += size.width + self.spacing
        }
    }
    
    @inline(__always)
    func _layoutCenter(bounds: QRect, pass: Pass) {
        var origin = bounds.left
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            guard size.width > 0 else { continue }
            entity.layout(bounds: QRect(left: origin, size: size))
            origin.x += size.width + self.spacing
        }
    }
    
    @inline(__always)
    func _layoutBottom(bounds: QRect, pass: Pass) {
        var origin = bounds.bottomLeft
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            guard size.width > 0 else { continue }
            entity.layout(bounds: QRect(bottomLeft: origin, size: size))
            origin.x += size.width + self.spacing
        }
    }
    
    @inline(__always)
    func _layoutFill(bounds: QRect, pass: Pass) {
        var origin = bounds.topLeft
        for (index, entity) in self.entities.enumerated() {
            let size = pass.sizes[index]
            guard size.width > 0 else { continue }
            entity.layout(bounds: QRect(topLeft: origin, width: size.width, height: bounds.height))
            origin.x += size.width + self.spacing
        }
    }
    
}
