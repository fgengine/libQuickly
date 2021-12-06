//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct HSplitStack {
        
        public var alignment: Alignment
        public var spacing: Float
        public var entities: [IQCompositionLayoutEntity]
        
        public init(
            alignment: Alignment = .fill,
            spacing: Float = 0,
            entities: [IQCompositionLayoutEntity]
        ) {
            self.alignment = alignment
            self.spacing = spacing
            self.entities = entities
        }
        
    }
    
}

public extension QCompositionLayout.HSplitStack {
    
    enum Alignment {
        case top
        case center
        case bottom
        case fill
    }
    
}

extension QCompositionLayout.HSplitStack : IQCompositionLayoutEntity {
    
    public func invalidate(item: QLayoutItem) {
        for entity in self.entities {
            entity.invalidate(item: item)
        }
    }
    
    @discardableResult
    public func layout(bounds: QRect) -> QSize {
        let pass = self._sizePass(available: bounds.size)
        switch self.alignment {
        case .top: self._layoutTop(bounds: bounds, pass: pass)
        case .center: self._layoutCenter(bounds: bounds, pass: pass)
        case .bottom: self._layoutBottom(bounds: bounds, pass: pass)
        case .fill: self._layoutFill(bounds: bounds, pass: pass)
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

private extension QCompositionLayout.HSplitStack {
    
    struct Pass {
        
        var sizes: [QSize]
        var bounding: QSize
        
    }
    
}

private extension QCompositionLayout.HSplitStack {
    
    @inline(__always)
    func _availableSize(available: QSize, entities: Int) -> QSize {
        if entities > 1 {
            return QSize(
                width: (available.width - (self.spacing * Float(entities - 1))) / Float(entities),
                height: available.height
            )
        } else if entities > 0 {
            return QSize(
                width: available.width / Float(entities),
                height: available.height
            )
        }
        return .zero
    }
    
    @inline(__always)
    func _sizePass(available: QSize) -> Pass {
        var pass = Pass(
            sizes: Array(
                repeating: .zero,
                count: self.entities.count
            ),
            bounding: .zero
        )
        if self.entities.isEmpty == false {
            var entityAvailableSize = self._availableSize(
                available: available,
                entities: pass.sizes.count
            )
            for (index, entity) in self.entities.enumerated() {
                pass.sizes[index] = entity.size(available: entityAvailableSize)
            }
            let numberOfValid = pass.sizes.count(where: { $0.width > 0 })
            if numberOfValid < self.entities.count {
                entityAvailableSize = self._availableSize(
                    available: available,
                    entities: numberOfValid
                )
                for (index, entity) in self.entities.enumerated() {
                    let size = pass.sizes[index]
                    guard size.width > 0 else { continue }
                    pass.sizes[index] = entity.size(available: entityAvailableSize)
                }
            }
            pass.bounding.width = available.width
            for (index, size) in pass.sizes.enumerated() {
                guard size.width > 0 else { continue }
                if size.width > 0 {
                    pass.sizes[index] = QSize(width: entityAvailableSize.width, height: size.height)
                    pass.bounding.height = max(pass.bounding.height, size.height)
                }
            }
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
