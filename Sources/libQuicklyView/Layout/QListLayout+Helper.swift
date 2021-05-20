//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QListLayout {
    
    struct Helper {
        
        static func layout(
            bounds: QRect,
            direction: Direction,
            origin: Origin,
            alignment: Alignment = .fill,
            inset: QInset,
            spacing: Float,
            minSpacing: Float? = nil,
            maxSpacing: Float? = nil,
            minSize: Float? = nil,
            maxSize: Float? = nil,
            operations: [Operation] = [],
            items: [QLayoutItem],
            cache: inout [QSize?]
        ) -> QSize {
            switch direction {
            case .horizontal:
                guard items.count > 0 else { return QSize(width: 0, height: bounds.size.height) }
                var size = self._passSize(
                    available: QSize(width: .infinity, height: bounds.size.height - inset.vertical),
                    items: items,
                    operations: operations,
                    cache: &cache,
                    keyPath: \.width
                )
                var pass = Pass(
                    inset: inset.horizontal,
                    spacings: items.count > 1 ? spacing * Float(items.count - 1) : 0,
                    items: size.full.width
                )
                var spacing = spacing
                if items.count > 1 {
                    pass = self._layoutPassSpacing(
                        pass: pass,
                        available: bounds.size.width,
                        inset: inset.horizontal,
                        spacing: &spacing,
                        itemsCount: items.count,
                        minSpacing: minSpacing,
                        maxSpacing: maxSpacing
                    )
                }
                pass = self._layoutPassSize(
                    pass: pass,
                    available: bounds.size.width,
                    inset: inset.horizontal,
                    spacing: spacing,
                    itemsCount: items.count,
                    minSize: minSize,
                    maxSize: maxSize,
                    sizes: &size.sizes,
                    keyPath: \.width
                )
                switch origin {
                case .forward:
                    switch alignment {
                    case .leading: return self._hForwardLeadingLayout(size: size, pass: pass, bounds: bounds, inset: inset, spacing: spacing, items: items, sizes: size.sizes)
                    case .center: return self._hForwardCenterLayout(size: size, pass: pass, bounds: bounds, inset: inset, spacing: spacing, items: items, sizes: size.sizes)
                    case .trailing: return self._hForwardTrailingLayout(size: size, pass: pass, bounds: bounds, inset: inset, spacing: spacing, items: items, sizes: size.sizes)
                    case .fill: return self._hForwardFillLayout(size: size, pass: pass, bounds: bounds, inset: inset, spacing: spacing, items: items, sizes: size.sizes)
                    }
                case .backward:
                    switch alignment {
                    case .leading: return self._hBackwardLeadingLayout(size: size, pass: pass, bounds: bounds, inset: inset, spacing: spacing, items: items, sizes: size.sizes)
                    case .center: return self._hBackwardCenterLayout(size: size, pass: pass, bounds: bounds, inset: inset, spacing: spacing, items: items, sizes: size.sizes)
                    case .trailing: return self._hBackwardTrailingLayout(size: size, pass: pass, bounds: bounds, inset: inset, spacing: spacing, items: items, sizes: size.sizes)
                    case .fill: return self._hBackwardFillLayout(size: size, pass: pass, bounds: bounds, inset: inset, spacing: spacing, items: items, sizes: size.sizes)
                    }
                }
            case .vertical:
                guard items.count > 0 else { return QSize(width: bounds.size.width, height: 0) }
                var size = self._passSize(
                    available: QSize(width: bounds.size.width - inset.horizontal, height: .infinity),
                    items: items,
                    operations: operations,
                    cache: &cache,
                    keyPath: \.height
                )
                var pass = Pass(
                    inset: inset.vertical,
                    spacings: items.count > 1 ? spacing * Float(items.count - 1) : 0,
                    items: size.full.height
                )
                var spacing = spacing
                if items.count > 1 {
                    pass = self._layoutPassSpacing(
                        pass: pass,
                        available: bounds.size.height,
                        inset: inset.vertical,
                        spacing: &spacing,
                        itemsCount: items.count,
                        minSpacing: minSpacing,
                        maxSpacing: maxSpacing
                    )
                }
                pass = self._layoutPassSize(
                    pass: pass,
                    available: bounds.size.height,
                    inset: inset.vertical,
                    spacing: spacing,
                    itemsCount: items.count,
                    minSize: minSize,
                    maxSize: maxSize,
                    sizes: &size.sizes,
                    keyPath: \.height
                )
                switch origin {
                case .forward:
                    switch alignment {
                    case .leading: return self._vForwardLeadingLayout(size: size, pass: pass, bounds: bounds, inset: inset, spacing: spacing, items: items, sizes: size.sizes)
                    case .center: return self._vForwardCenterLayout(size: size, pass: pass, bounds: bounds, inset: inset, spacing: spacing, items: items, sizes: size.sizes)
                    case .trailing: return self._vForwardTrailingLayout(size: size, pass: pass, bounds: bounds, inset: inset, spacing: spacing, items: items, sizes: size.sizes)
                    case .fill: return self._vForwardFillLayout(size: size, pass: pass, bounds: bounds, inset: inset, spacing: spacing, items: items, sizes: size.sizes)
                    }
                case .backward:
                    switch alignment {
                    case .leading: return self._vBackwardLeadingLayout(size: size, pass: pass, bounds: bounds, inset: inset, spacing: spacing, items: items, sizes: size.sizes)
                    case .center: return self._vBackwardCenterLayout(size: size, pass: pass, bounds: bounds, inset: inset, spacing: spacing, items: items, sizes: size.sizes)
                    case .trailing: return self._vBackwardTrailingLayout(size: size, pass: pass, bounds: bounds, inset: inset, spacing: spacing, items: items, sizes: size.sizes)
                    case .fill: return self._vBackwardFillLayout(size: size, pass: pass, bounds: bounds, inset: inset, spacing: spacing, items: items, sizes: size.sizes)
                    }
                }
            }
        }
        
        static func size(
            available: QSize,
            direction: Direction,
            alignment: Alignment = .fill,
            inset: QInset,
            spacing: Float,
            minSpacing: Float? = nil,
            maxSpacing: Float? = nil,
            minSize: Float? = nil,
            maxSize: Float? = nil,
            items: [QLayoutItem],
            operations: [Operation] = []
        ) -> QSize {
            switch direction {
            case .horizontal:
                guard items.count > 0 else { return QSize(width: available.width, height: 0) }
                var cache = Array< QSize? >(repeating: nil, count: items.count)
                let size = self._passSize(
                    available: QSize(width: .infinity, height: available.height - inset.vertical),
                    items: items,
                    operations: operations,
                    cache: &cache,
                    keyPath: \.width
                )
                var pass = Pass(
                    inset: inset.horizontal,
                    spacings: items.count > 1 ? spacing * Float(items.count - 1) : 0,
                    items: size.full.width
                )
                if items.count > 1 {
                    pass = self._boundsPassSpacing(
                        pass: pass,
                        available: available.width,
                        inset: inset.horizontal,
                        itemsCount: items.count,
                        minSpacing: minSpacing,
                        maxSpacing: maxSpacing
                    )
                }
                pass = self._boundsPassSize(
                    pass: pass,
                    available: available.width,
                    inset: inset.horizontal,
                    itemsCount: items.count,
                    minSize: minSize,
                    maxSize: maxSize
                )
                let height: Float
                switch alignment {
                case .leading, .center, .trailing: height = size.max.height + inset.vertical
                case .fill: height = available.height
                }
                return QSize(width: pass.full, height: height)
            case .vertical:
                guard items.count > 0 else { return QSize(width: available.width, height: 0) }
                var cache = Array< QSize? >(repeating: nil, count: items.count)
                let size = self._passSize(
                    available: QSize(width: available.width - inset.horizontal, height: .infinity),
                    items: items,
                    operations: operations,
                    cache: &cache,
                    keyPath: \.height
                )
                var pass = Pass(
                    inset: inset.vertical,
                    spacings: items.count > 1 ? spacing * Float(items.count - 1) : 0,
                    items: size.full.height
                )
                if items.count > 1 {
                    pass = self._boundsPassSpacing(
                        pass: pass,
                        available: available.height,
                        inset: inset.vertical,
                        itemsCount: items.count,
                        minSpacing: minSpacing,
                        maxSpacing: maxSpacing
                    )
                }
                pass = self._boundsPassSize(
                    pass: pass,
                    available: available.height,
                    inset: inset.vertical,
                    itemsCount: items.count,
                    minSize: minSize,
                    maxSize: maxSize
                )
                let width: Float
                switch alignment {
                case .leading, .center, .trailing: width = size.max.width + inset.horizontal
                case .fill: width = available.width
                }
                return QSize(width: width, height: pass.full)
            }
        }
        
    }
    
}

public extension QListLayout.Helper {
    
    enum Origin {
        case forward
        case backward
    }
    
    enum Alignment {
        case leading
        case center
        case trailing
        case fill
    }
    
    enum OperationType {
        case insert
        case delete
    }
    
    class Operation {
        
        public var type: OperationType
        public var indices: Set< Int >
        public var progress: Float
        
        public init(
            type: OperationType,
            indices: Set< Int >,
            progress: Float
        ) {
            self.type = type
            self.indices = indices
            self.progress = progress
        }

    }
    
}

extension QListLayout.Helper.Operation : Equatable {
    
    public static func == (lhs: QListLayout.Helper.Operation, rhs: QListLayout.Helper.Operation) -> Bool {
        return lhs.type == rhs.type && lhs.indices == rhs.indices
    }
    
}

private extension QListLayout.Helper {
    
    struct SizePass {
        
        var full: QSize
        var max: QSize
        var sizes: [QSize]
        
    }
    
    struct Pass {
        
        var full: Float
        var spacings: Float
        var items: Float
        
        init(
            full: Float,
            spacings: Float,
            items: Float
        ) {
            self.full = full
            self.spacings = spacings
            self.items = items
        }

        init(
            inset: Float,
            spacings: Float,
            items: Float
        ) {
            self.full = (items + spacings) + inset
            self.spacings = spacings
            self.items = items
        }

    }
    
}

private extension QListLayout.Helper.Operation {
    
    @inline(__always)
    func _process(itemSize: QSize, keyPath: WritableKeyPath< QSize, Float >) -> QSize {
        var result = itemSize
        switch self.type {
        case .insert: result[keyPath: keyPath] = result[keyPath: keyPath] * self.progress
        case .delete: result[keyPath: keyPath] = result[keyPath: keyPath] * (1 - self.progress)
        }
        return result
    }
    
}

private extension QListLayout.Helper {
    
    @inline(__always)
    static func _hForwardLeadingLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: Float,
        items: [QLayoutItem],
        sizes: [QSize?]
    ) -> QSize {
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: bounds.origin.y + inset.top
        )
        for index in 0 ..< items.count {
            guard let size = sizes[index] else { continue }
            let item = items[index]
            item.frame = QRect(topLeft: origin, size: size)
            origin.x += size.width + spacing
        }
        return QSize(
            width: pass.full,
            height: size.max.height + inset.vertical
        )
    }
    
    @inline(__always)
    static func _hForwardCenterLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: Float,
        items: [QLayoutItem],
        sizes: [QSize?]
    ) -> QSize {
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: (bounds.origin.y + (bounds.size.height / 2)) + inset.top
        )
        for index in 0 ..< items.count {
            guard let size = sizes[index] else { continue }
            let item = items[index]
            item.frame = QRect(left: origin, size: size)
            origin.x += size.width + spacing
        }
        return QSize(
            width: pass.full,
            height: size.max.height + inset.vertical
        )
    }
    
    @inline(__always)
    static func _hForwardTrailingLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: Float,
        items: [QLayoutItem],
        sizes: [QSize?]
    ) -> QSize {
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: (bounds.origin.y + bounds.size.height) - inset.bottom
        )
        for index in 0 ..< items.count {
            guard let size = sizes[index] else { continue }
            let item = items[index]
            item.frame = QRect(bottomLeft: origin, size: size)
            origin.x += size.width + spacing
        }
        return QSize(
            width: pass.full,
            height: size.max.height + inset.vertical
        )
    }
    
    @inline(__always)
    static func _hForwardFillLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: Float,
        items: [QLayoutItem],
        sizes: [QSize?]
    ) -> QSize {
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: bounds.origin.y + inset.top
        )
        let height = bounds.size.height - inset.vertical
        for index in 0 ..< items.count {
            guard let size = sizes[index] else { continue }
            let item = items[index]
            item.frame = QRect(x: origin.x, y: origin.y, width: size.width, height: height)
            origin.x += size.width + spacing
        }
        return QSize(
            width: pass.full,
            height: bounds.size.height
        )
    }
    
}

private extension QListLayout.Helper {
    
    @inline(__always)
    static func _hBackwardLeadingLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: Float,
        items: [QLayoutItem],
        sizes: [QSize?]
    ) -> QSize {
        var origin = QPoint(
            x: (bounds.origin.x + bounds.size.width) - inset.right,
            y: bounds.origin.y + inset.top
        )
        for index in 0..<items.count {
            guard let size = sizes[index] else { continue }
            let item = items[index]
            item.frame = QRect(topRight: origin, size: size)
            origin.x -= size.width + spacing
        }
        return QSize(
            width: size.max.width + inset.horizontal,
            height: pass.full
        )
    }
    
    @inline(__always)
    static func _hBackwardCenterLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: Float,
        items: [QLayoutItem],
        sizes: [QSize?]
    ) -> QSize {
        var origin = QPoint(
            x: (bounds.origin.x + bounds.size.width) - inset.right,
            y: (bounds.origin.y + (bounds.size.height / 2)) + inset.top
        )
        for index in 0..<items.count {
            guard let size = sizes[index] else { continue }
            let item = items[index]
            item.frame = QRect(right: origin, size: size)
            origin.x -= size.width + spacing
        }
        return QSize(
            width: size.max.width + inset.horizontal,
            height: pass.full
        )
    }
    
    @inline(__always)
    static func _hBackwardTrailingLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: Float,
        items: [QLayoutItem],
        sizes: [QSize?]
    ) -> QSize {
        var origin = QPoint(
            x: (bounds.origin.x + bounds.size.width) - inset.right,
            y: (bounds.origin.y + bounds.size.height) + inset.bottom
        )
        for index in 0 ..< items.count {
            guard let size = sizes[index] else { continue }
            let item = items[index]
            item.frame = QRect(bottomRight: origin, size: size)
            origin.x -= size.width + spacing
        }
        return QSize(
            width: size.max.width + inset.horizontal,
            height: pass.full
        )
    }
    
    @inline(__always)
    static func _hBackwardFillLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: Float,
        items: [QLayoutItem],
        sizes: [QSize?]
    ) -> QSize {
        var origin = QPoint(
            x: (bounds.origin.x + bounds.size.width) - inset.right,
            y: bounds.origin.y + inset.top
        )
        let height = bounds.size.height - inset.vertical
        for index in 0 ..< items.count {
            guard let size = sizes[index] else { continue }
            let item = items[index]
            item.frame = QRect(x: origin.x - size.width, y: origin.y, width: size.width, height: height)
            origin.x -= size.width + spacing
        }
        return QSize(
            width: size.max.width + inset.horizontal,
            height: bounds.size.height
        )
    }
    
}

private extension QListLayout.Helper {
    
    @inline(__always)
    static func _vForwardLeadingLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: Float,
        items: [QLayoutItem],
        sizes: [QSize?]
    ) -> QSize {
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: bounds.origin.y + inset.top
        )
        for index in 0 ..< items.count {
            guard let size = sizes[index] else { continue }
            let item = items[index]
            item.frame = QRect(topLeft: origin, size: size)
            origin.y += size.height + spacing
        }
        return QSize(
            width: size.max.width + inset.horizontal,
            height: pass.full
        )
    }
    
    @inline(__always)
    static func _vForwardCenterLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: Float,
        items: [QLayoutItem],
        sizes: [QSize?]
    ) -> QSize {
        var origin = QPoint(
            x: (bounds.origin.x + (bounds.size.width / 2)) + inset.left,
            y: bounds.origin.y + inset.top
        )
        for index in 0 ..< items.count {
            guard let size = sizes[index] else { continue }
            let item = items[index]
            item.frame = QRect(top: origin, size: size)
            origin.y += size.height + spacing
        }
        return QSize(
            width: size.max.width + inset.horizontal,
            height: pass.full
        )
    }
    
    @inline(__always)
    static func _vForwardTrailingLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: Float,
        items: [QLayoutItem],
        sizes: [QSize?]
    ) -> QSize {
        var origin = QPoint(
            x: (bounds.origin.x + bounds.size.width) - inset.right,
            y: bounds.origin.y + inset.top
        )
        for index in 0 ..< items.count {
            guard let size = sizes[index] else { continue }
            let item = items[index]
            item.frame = QRect(topRight: origin, size: size)
            origin.y += size.height + spacing
        }
        return QSize(
            width: size.max.width + inset.horizontal,
            height: pass.full
        )
    }
    
    @inline(__always)
    static func _vForwardFillLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: Float,
        items: [QLayoutItem],
        sizes: [QSize?]
    ) -> QSize {
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: bounds.origin.y + inset.top
        )
        let width = bounds.size.width - inset.horizontal
        for index in 0 ..< items.count {
            guard let size = sizes[index] else { continue }
            let item = items[index]
            item.frame = QRect(x: origin.x, y: origin.y, width: width, height: size.height)
            origin.y += size.height + spacing
        }
        return QSize(
            width: bounds.size.width,
            height: pass.full
        )
    }
    
}

private extension QListLayout.Helper {
    
    @inline(__always)
    static func _vBackwardLeadingLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: Float,
        items: [QLayoutItem],
        sizes: [QSize?]
    ) -> QSize {
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: (bounds.origin.y + bounds.size.height) - inset.bottom
        )
        for index in 0 ..< items.count {
            guard let size = sizes[index] else { continue }
            let item = items[index]
            item.frame = QRect(bottomLeft: origin, size: size)
            origin.y -= size.height + spacing
        }
        return QSize(
            width: size.max.width + inset.horizontal,
            height: pass.full
        )
    }
    
    @inline(__always)
    static func _vBackwardCenterLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: Float,
        items: [QLayoutItem],
        sizes: [QSize?]
    ) -> QSize {
        var origin = QPoint(
            x: (bounds.origin.x + (bounds.size.width / 2)) + inset.left,
            y: (bounds.origin.y + bounds.size.height) - inset.bottom
        )
        for index in 0 ..< items.count {
            guard let size = sizes[index] else { continue }
            let item = items[index]
            item.frame = QRect(bottom: origin, size: size)
            origin.y -= size.height + spacing
        }
        return QSize(
            width: size.max.width + inset.horizontal,
            height: pass.full
        )
    }
    
    @inline(__always)
    static func _vBackwardTrailingLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: Float,
        items: [QLayoutItem],
        sizes: [QSize?]
    ) -> QSize {
        var origin = QPoint(
            x: (bounds.origin.x + bounds.size.width) - inset.right,
            y: (bounds.origin.y + bounds.size.height) - inset.bottom
        )
        for index in 0 ..< items.count {
            guard let size = sizes[index] else { continue }
            let item = items[index]
            item.frame = QRect(bottomRight: origin, size: size)
            origin.y -= size.height + spacing
        }
        return QSize(
            width: size.max.width + inset.horizontal,
            height: pass.full
        )
    }
    
    @inline(__always)
    static func _vBackwardFillLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: Float,
        items: [QLayoutItem],
        sizes: [QSize?]
    ) -> QSize {
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: (bounds.origin.y + bounds.size.height) - inset.bottom
        )
        let width = bounds.size.width - inset.horizontal
        for index in 0 ..< items.count {
            guard let size = sizes[index] else { continue }
            let item = items[index]
            item.frame = QRect(x: origin.x, y: origin.y - size.height, width: width, height: size.height)
            origin.y -= size.height + spacing
        }
        return QSize(
            width: bounds.size.width,
            height: pass.full
        )
    }
    
}

private extension QListLayout.Helper {
    
    @inline(__always)
    static func _layoutPassSpacing(
        pass: Pass,
        available: Float,
        inset: Float,
        spacing: inout Float,
        itemsCount: Int,
        minSpacing: Float?,
        maxSpacing: Float?
    ) -> Pass {
        let newFull: Float
        let newSpacings: Float
        if let maxSpacing = maxSpacing, pass.full < available {
            newSpacings = maxSpacing * Float(itemsCount - 1)
            newFull = (pass.items + pass.spacings) + inset
            if newFull > available {
                spacing = (newFull - pass.full) / Float(itemsCount - 1)
            } else {
                spacing = maxSpacing
            }
        } else if let minSpacing = minSpacing, pass.full > available {
            newSpacings = minSpacing * Float(itemsCount - 1)
            newFull = (pass.items + pass.spacings) + inset
            if newFull < available {
                spacing = (newFull - pass.full) / Float(itemsCount - 1)
            } else {
                spacing = minSpacing
            }
        } else {
            newFull = pass.full
            newSpacings = pass.spacings
        }
        return Pass(
            full: newFull,
            spacings: newSpacings,
            items: pass.items
        )
    }
    
    @inline(__always)
    static func _boundsPassSpacing(
        pass: Pass,
        available: Float,
        inset: Float,
        itemsCount: Int,
        minSpacing: Float?,
        maxSpacing: Float?
    ) -> Pass {
        let newFull: Float
        let newSpacings: Float
        if let maxSpacing = maxSpacing, pass.full < available {
            newSpacings = maxSpacing * Float(itemsCount - 1)
            newFull = min(available, (pass.items + newSpacings) + inset)
        } else if let minSpacing = minSpacing, pass.full > available {
            newSpacings = minSpacing * Float(itemsCount - 1)
            newFull = max(available, (pass.items + newSpacings) + inset)
        } else {
            newFull = pass.full
            newSpacings = pass.spacings
        }
        return Pass(
            full: newFull,
            spacings: newSpacings,
            items: pass.items
        )
    }
    
}

private extension QListLayout.Helper {
    
    @inline(__always)
    static func _layoutPassSize(
        pass: Pass,
        available: Float,
        inset: Float,
        spacing: Float,
        itemsCount: Int,
        minSize: Float?,
        maxSize: Float?,
        sizes: inout [QSize],
        keyPath: WritableKeyPath< QSize, Float >
    ) -> Pass {
        var newFull: Float
        var newItems: Float
        if let maxSize = maxSize, pass.full < available {
            let itemSize = min((available - inset - pass.spacings) / Float(itemsCount), maxSize)
            newItems = itemSize * Float(itemsCount)
            newFull = (newItems + pass.spacings) + inset
            for (index, value) in sizes.enumerated() {
                var size = value
                size[keyPath: keyPath] = itemSize
                sizes[index] = size
            }
        } else if let minSize = minSize, pass.full > available {
            let itemSize = max((available - inset - pass.spacings) / Float(itemsCount), minSize)
            newItems = itemSize * Float(itemsCount)
            newFull = (newItems + pass.spacings) + inset
            for (index, value) in sizes.enumerated() {
                var size = value
                size[keyPath: keyPath] = itemSize
                sizes[index] = size
            }
        } else {
            newFull = pass.full
            newItems = pass.items
        }
        return Pass(
            full: newFull,
            spacings: pass.spacings,
            items: newItems
        )
    }
    
    @inline(__always)
    static func _boundsPassSize(
        pass: Pass,
        available: Float,
        inset: Float,
        itemsCount: Int,
        minSize: Float?,
        maxSize: Float?
    ) -> Pass {
        var newFull: Float
        var newItems: Float
        if let maxSize = maxSize, pass.full < available {
            let itemSize = min((available - inset - pass.spacings) / Float(itemsCount), maxSize)
            newItems = itemSize * Float(itemsCount)
            newFull = (newItems + pass.spacings) + inset
        } else if let minSize = minSize, pass.full > available {
            let itemSize = max((available - inset - pass.spacings) / Float(itemsCount), minSize)
            newItems = itemSize * Float(itemsCount)
            newFull = (newItems + pass.spacings) + inset
        } else {
            newFull = pass.full
            newItems = pass.items
        }
        return Pass(
            full: newFull,
            spacings: pass.spacings,
            items: newItems
        )
    }
    
}

private extension QListLayout.Helper {
    
    @inline(__always)
    static func _passSize(
        available: QSize,
        items: [QLayoutItem],
        operations: [Operation],
        cache: inout [QSize?],
        keyPath: WritableKeyPath< QSize, Float >
    ) -> SizePass {
        var fillSize = QSize()
        var maxSize = QSize()
        var sizes = Array< QSize >()
        for index in 0 ..< items.count {
            var itemSize: QSize
            if let cacheSize = cache[index] {
                itemSize = cacheSize
            } else {
                itemSize = items[index].size(available)
                cache[index] = itemSize
            }
            if let operation = operations.first(where: { $0.indices.contains(index) }) {
                itemSize = operation._process(itemSize: itemSize, keyPath: keyPath)
            }
            fillSize.width += itemSize.width
            fillSize.height += itemSize.height
            maxSize.width = max(maxSize.width, itemSize.width)
            maxSize.height = max(maxSize.height, itemSize.height)
            sizes.append(itemSize)
        }
        return SizePass(
            full: fillSize,
            max: maxSize,
            sizes: sizes
        )
    }
    
}
