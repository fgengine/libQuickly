//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public struct QStackLayoutHelper {
    
    public typealias CacheClosure = (_ index: Int, _ item: QLayoutItem) -> QSize
    
    static func layout(
        bounds: QRect,
        direction: Direction,
        origin: Origin,
        alignment: Alignment = .fill,
        inset: QInset,
        spacing: QFloat,
        minSpacing: QFloat? = nil,
        maxSpacing: QFloat? = nil,
        minSize: QFloat? = nil,
        maxSize: QFloat? = nil,
        items: [QLayoutItem],
        sizeCache: inout [Int : QSize]
    ) -> QSize {
        switch direction {
        case .horizontal:
            guard items.count > 0 else { return QSize(width: 0, height: bounds.size.height) }
            let size = self._passSize(
                available: QSize(width: .infinity, height: bounds.size.height - inset.vertical),
                items: items,
                sizeCache: &sizeCache
            )
            var pass = Pass(
                inset: inset.horizontal,
                spacings: items.count > 1 ? spacing * QFloat(items.count - 1) : 0,
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
            var sizes = sizeCache
            pass = self._layoutPassSize(
                pass: pass,
                available: bounds.size.width,
                inset: inset.horizontal,
                spacing: spacing,
                itemsCount: items.count,
                minSize: minSize,
                maxSize: maxSize,
                sizeCache: &sizes,
                keyPath: \.width
            )
            switch origin {
            case .forward:
                switch alignment {
                case .leading:
                    return self._hForwardLeadingLayout(
                        size: size,
                        pass: pass,
                        bounds: bounds,
                        inset: inset,
                        spacing: spacing,
                        items: items,
                        sizeCache: sizes
                    )
                case .center:
                    return self._hForwardCenterLayout(
                        size: size,
                        pass: pass,
                        bounds: bounds,
                        inset: inset,
                        spacing: spacing,
                        items: items,
                        sizeCache: sizes
                    )
                case .trailing:
                    return self._hForwardTrailingLayout(
                        size: size,
                        pass: pass,
                        bounds: bounds,
                        inset: inset,
                        spacing: spacing,
                        items: items,
                        sizeCache: sizes
                    )
                case .fill:
                    return self._hForwardFillLayout(
                        size: size,
                        pass: pass,
                        bounds: bounds,
                        inset: inset,
                        spacing: spacing,
                        items: items,
                        sizeCache: sizes
                    )
                }
            case .backward:
                switch alignment {
                case .leading:
                    return self._hBackwardLeadingLayout(
                        size: size,
                        pass: pass,
                        bounds: bounds,
                        inset: inset,
                        spacing: spacing,
                        items: items,
                        sizeCache: sizes
                    )
                case .center:
                    return self._hBackwardCenterLayout(
                        size: size,
                        pass: pass,
                        bounds: bounds,
                        inset: inset,
                        spacing: spacing,
                        items: items,
                        sizeCache: sizes
                    )
                case .trailing:
                    return self._hBackwardTrailingLayout(
                        size: size,
                        pass: pass,
                        bounds: bounds,
                        inset: inset,
                        spacing: spacing,
                        items: items,
                        sizeCache: sizes
                    )
                case .fill:
                    return self._hBackwardFillLayout(
                        size: size,
                        pass: pass,
                        bounds: bounds,
                        inset: inset,
                        spacing: spacing,
                        items: items,
                        sizeCache: sizes
                    )
                }
            }
        case .vertical:
            guard items.count > 0 else { return QSize(width: bounds.size.width, height: 0) }
            let size = self._passSize(
                available: QSize(width: bounds.size.width - inset.horizontal, height: .infinity),
                items: items,
                sizeCache: &sizeCache
            )
            var pass = Pass(
                inset: inset.vertical,
                spacings: items.count > 1 ? spacing * QFloat(items.count - 1) : 0,
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
            var sizes = sizeCache
            pass = self._layoutPassSize(
                pass: pass,
                available: bounds.size.height,
                inset: inset.vertical,
                spacing: spacing,
                itemsCount: items.count,
                minSize: minSize,
                maxSize: maxSize,
                sizeCache: &sizes,
                keyPath: \.height
            )
            switch origin {
            case .forward:
                switch alignment {
                case .leading:
                    return self._vForwardLeadingLayout(
                        size: size,
                        pass: pass,
                        bounds: bounds,
                        inset: inset,
                        spacing: spacing,
                        items: items,
                        sizeCache: sizes
                    )
                case .center:
                    return self._vForwardCenterLayout(
                        size: size,
                        pass: pass,
                        bounds: bounds,
                        inset: inset,
                        spacing: spacing,
                        items: items,
                        sizeCache: sizes
                    )
                case .trailing:
                    return self._vForwardTrailingLayout(
                        size: size,
                        pass: pass,
                        bounds: bounds,
                        inset: inset,
                        spacing: spacing,
                        items: items,
                        sizeCache: sizes
                    )
                case .fill:
                    return self._vForwardFillLayout(
                        size: size,
                        pass: pass,
                        bounds: bounds,
                        inset: inset,
                        spacing: spacing,
                        items: items,
                        sizeCache: sizes
                    )
                }
            case .backward:
                switch alignment {
                case .leading:
                    return self._vBackwardLeadingLayout(
                        size: size,
                        pass: pass,
                        bounds: bounds,
                        inset: inset,
                        spacing: spacing,
                        items: items,
                        sizeCache: sizes
                    )
                case .center:
                    return self._vBackwardCenterLayout(
                        size: size,
                        pass: pass,
                        bounds: bounds,
                        inset: inset,
                        spacing: spacing,
                        items: items,
                        sizeCache: sizes
                    )
                case .trailing:
                    return self._vBackwardTrailingLayout(
                        size: size,
                        pass: pass,
                        bounds: bounds,
                        inset: inset,
                        spacing: spacing,
                        items: items,
                        sizeCache: sizes
                    )
                case .fill:
                    return self._vBackwardFillLayout(
                        size: size,
                        pass: pass,
                        bounds: bounds,
                        inset: inset,
                        spacing: spacing,
                        items: items,
                        sizeCache: sizes
                    )
                }
            }
        }
    }
    
    static func size(
        available: QSize,
        direction: Direction,
        alignment: Alignment = .fill,
        inset: QInset,
        spacing: QFloat,
        minSpacing: QFloat? = nil,
        maxSpacing: QFloat? = nil,
        minSize: QFloat? = nil,
        maxSize: QFloat? = nil,
        items: [QLayoutItem]
    ) -> QSize {
        switch direction {
        case .horizontal:
            guard items.count > 0 else { return QSize(width: available.width, height: 0) }
            var sizeCache: [Int : QSize] = Dictionary(minimumCapacity: items.count)
            let size = self._passSize(
                available: QSize(width: .infinity, height: available.height - inset.vertical),
                items: items,
                sizeCache: &sizeCache
            )
            var pass = Pass(
                inset: inset.horizontal,
                spacings: items.count > 1 ? spacing * QFloat(items.count - 1) : 0,
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
                maxSize: maxSize,
                sizeCache: sizeCache,
                keyPath: \.width
            )
            let height: QFloat
            switch alignment {
            case .leading, .center, .trailing: height = size.max.height + inset.vertical
            case .fill: height = available.height
            }
            return QSize(width: pass.full, height: height)
        case .vertical:
            guard items.count > 0 else { return QSize(width: available.width, height: 0) }
            var sizeCache: [Int : QSize] = Dictionary(minimumCapacity: items.count)
            let size = self._passSize(
                available: QSize(width: available.width - inset.horizontal, height: .infinity),
                items: items,
                sizeCache: &sizeCache
            )
            var pass = Pass(
                inset: inset.vertical,
                spacings: items.count > 1 ? spacing * QFloat(items.count - 1) : 0,
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
                maxSize: maxSize,
                sizeCache: sizeCache,
                keyPath: \.height
            )
            let width: QFloat
            switch alignment {
            case .leading, .center, .trailing: width = size.max.width + inset.horizontal
            case .fill: width = available.width
            }
            return QSize(width: width, height: pass.full)
        }
    }
    
}

public extension QStackLayoutHelper {
    
    enum Direction {
        case horizontal
        case vertical
    }
    
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
    
}

private extension QStackLayoutHelper {
    
    struct SizePass {
        
        let full: QSize
        let max: QSize
        
    }
    
    struct Pass {
        
        let full: QFloat
        let spacings: QFloat
        let items: QFloat
        
        init(
            full: QFloat,
            spacings: QFloat,
            items: QFloat
        ) {
            self.full = full
            self.spacings = spacings
            self.items = items
        }

        init(
            inset: QFloat,
            spacings: QFloat,
            items: QFloat
        ) {
            self.full = (items + spacings) + inset
            self.spacings = spacings
            self.items = items
        }

    }
    
}

private extension QStackLayoutHelper {
    
    @inline(__always)
    static func _hForwardLeadingLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: QFloat,
        items: [QLayoutItem],
        sizeCache: [Int : QSize]
    ) -> QSize {
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: bounds.origin.y + inset.top
        )
        for index in 0..<items.count {
            guard let size = sizeCache[index] else { continue }
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
        spacing: QFloat,
        items: [QLayoutItem],
        sizeCache: [Int : QSize]
    ) -> QSize {
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: (bounds.origin.y + (bounds.size.height / 2)) + inset.top
        )
        for index in 0..<items.count {
            guard let size = sizeCache[index] else { continue }
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
        spacing: QFloat,
        items: [QLayoutItem],
        sizeCache: [Int : QSize]
    ) -> QSize {
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: (bounds.origin.y + bounds.size.height) - inset.bottom
        )
        for index in 0..<items.count {
            guard let size = sizeCache[index] else { continue }
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
        spacing: QFloat,
        items: [QLayoutItem],
        sizeCache: [Int : QSize]
    ) -> QSize {
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: bounds.origin.y + inset.top
        )
        let height = bounds.size.height - inset.vertical
        for index in 0..<items.count {
            guard let size = sizeCache[index] else { continue }
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

private extension QStackLayoutHelper {
    
    @inline(__always)
    static func _hBackwardLeadingLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: QFloat,
        items: [QLayoutItem],
        sizeCache: [Int : QSize]
    ) -> QSize {
        var origin = QPoint(
            x: (bounds.origin.x + bounds.size.width) - inset.right,
            y: bounds.origin.y + inset.top
        )
        for index in 0..<items.count {
            guard let size = sizeCache[index] else { continue }
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
        spacing: QFloat,
        items: [QLayoutItem],
        sizeCache: [Int : QSize]
    ) -> QSize {
        var origin = QPoint(
            x: (bounds.origin.x + bounds.size.width) - inset.right,
            y: (bounds.origin.y + (bounds.size.height / 2)) + inset.top
        )
        for index in 0..<items.count {
            guard let size = sizeCache[index] else { continue }
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
        spacing: QFloat,
        items: [QLayoutItem],
        sizeCache: [Int : QSize]
    ) -> QSize {
        var origin = QPoint(
            x: (bounds.origin.x + bounds.size.width) - inset.right,
            y: (bounds.origin.y + bounds.size.height) + inset.bottom
        )
        for index in 0..<items.count {
            guard let size = sizeCache[index] else { continue }
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
        spacing: QFloat,
        items: [QLayoutItem],
        sizeCache: [Int : QSize]
    ) -> QSize {
        var origin = QPoint(
            x: (bounds.origin.x + bounds.size.width) - inset.right,
            y: bounds.origin.y + inset.top
        )
        let height = bounds.size.height - inset.vertical
        for index in 0..<items.count {
            guard let size = sizeCache[index] else { continue }
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

private extension QStackLayoutHelper {
    
    @inline(__always)
    static func _vForwardLeadingLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: QFloat,
        items: [QLayoutItem],
        sizeCache: [Int : QSize]
    ) -> QSize {
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: bounds.origin.y + inset.top
        )
        for index in 0..<items.count {
            guard let size = sizeCache[index] else { continue }
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
        spacing: QFloat,
        items: [QLayoutItem],
        sizeCache: [Int : QSize]
    ) -> QSize {
        var origin = QPoint(
            x: (bounds.origin.x + (bounds.size.width / 2)) + inset.left,
            y: bounds.origin.y + inset.top
        )
        for index in 0..<items.count {
            guard let size = sizeCache[index] else { continue }
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
        spacing: QFloat,
        items: [QLayoutItem],
        sizeCache: [Int : QSize]
    ) -> QSize {
        var origin = QPoint(
            x: (bounds.origin.x + bounds.size.width) - inset.right,
            y: bounds.origin.y + inset.top
        )
        for index in 0..<items.count {
            guard let size = sizeCache[index] else { continue }
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
        spacing: QFloat,
        items: [QLayoutItem],
        sizeCache: [Int : QSize]
    ) -> QSize {
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: bounds.origin.y + inset.top
        )
        let width = bounds.size.width - inset.horizontal
        for index in 0..<items.count {
            guard let size = sizeCache[index] else { continue }
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

private extension QStackLayoutHelper {
    
    @inline(__always)
    static func _vBackwardLeadingLayout(
        size: SizePass,
        pass: Pass,
        bounds: QRect,
        inset: QInset,
        spacing: QFloat,
        items: [QLayoutItem],
        sizeCache: [Int : QSize]
    ) -> QSize {
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: (bounds.origin.y + bounds.size.height) - inset.bottom
        )
        for index in 0..<items.count {
            guard let size = sizeCache[index] else { continue }
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
        spacing: QFloat,
        items: [QLayoutItem],
        sizeCache: [Int : QSize]
    ) -> QSize {
        var origin = QPoint(
            x: (bounds.origin.x + (bounds.size.width / 2)) + inset.left,
            y: (bounds.origin.y + bounds.size.height) - inset.bottom
        )
        for index in 0..<items.count {
            guard let size = sizeCache[index] else { continue }
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
        spacing: QFloat,
        items: [QLayoutItem],
        sizeCache: [Int : QSize]
    ) -> QSize {
        var origin = QPoint(
            x: (bounds.origin.x + bounds.size.width) - inset.right,
            y: (bounds.origin.y + bounds.size.height) - inset.bottom
        )
        for index in 0..<items.count {
            guard let size = sizeCache[index] else { continue }
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
        spacing: QFloat,
        items: [QLayoutItem],
        sizeCache: [Int : QSize]
    ) -> QSize {
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: (bounds.origin.y + bounds.size.height) - inset.bottom
        )
        let width = bounds.size.width - inset.horizontal
        for index in 0..<items.count {
            guard let size = sizeCache[index] else { continue }
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

private extension QStackLayoutHelper {
    
    @inline(__always)
    static func _layoutPassSpacing(
        pass: Pass,
        available: QFloat,
        inset: QFloat,
        spacing: inout QFloat,
        itemsCount: Int,
        minSpacing: QFloat?,
        maxSpacing: QFloat?
    ) -> Pass {
        let newFull: QFloat
        let newSpacings: QFloat
        if let maxSpacing = maxSpacing, pass.full < available {
            newSpacings = maxSpacing * QFloat(itemsCount - 1)
            newFull = (pass.items + pass.spacings) + inset
            if newFull > available {
                spacing = (newFull - pass.full) / QFloat(itemsCount - 1)
            } else {
                spacing = maxSpacing
            }
        } else if let minSpacing = minSpacing, pass.full > available {
            newSpacings = minSpacing * QFloat(itemsCount - 1)
            newFull = (pass.items + pass.spacings) + inset
            if newFull < available {
                spacing = (newFull - pass.full) / QFloat(itemsCount - 1)
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
        available: QFloat,
        inset: QFloat,
        itemsCount: Int,
        minSpacing: QFloat?,
        maxSpacing: QFloat?
    ) -> Pass {
        let newFull: QFloat
        let newSpacings: QFloat
        if let maxSpacing = maxSpacing, pass.full < available {
            newSpacings = maxSpacing * QFloat(itemsCount - 1)
            newFull = min(available, (pass.items + newSpacings) + inset)
        } else if let minSpacing = minSpacing, pass.full > available {
            newSpacings = minSpacing * QFloat(itemsCount - 1)
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

private extension QStackLayoutHelper {
    
    @inline(__always)
    static func _layoutPassSize(
        pass: Pass,
        available: QFloat,
        inset: QFloat,
        spacing: QFloat,
        itemsCount: Int,
        minSize: QFloat?,
        maxSize: QFloat?,
        sizeCache: inout [Int : QSize],
        keyPath: WritableKeyPath< QSize, QFloat >
    ) -> Pass {
        var newFull: QFloat
        var newItems: QFloat
        if let maxSize = maxSize, pass.full < available {
            let itemSize = min((available - inset - pass.spacings) / QFloat(itemsCount), maxSize)
            newItems = itemSize * QFloat(itemsCount)
            newFull = (newItems + pass.spacings) + inset
            for cacheItem in sizeCache {
                var size = cacheItem.value
                size[keyPath: keyPath] = itemSize
                sizeCache[cacheItem.key] = size
            }
        } else if let minSize = minSize, pass.full > available {
            let itemSize = max((available - inset - pass.spacings) / QFloat(itemsCount), minSize)
            newItems = itemSize * QFloat(itemsCount)
            newFull = (newItems + pass.spacings) + inset
            for cacheItem in sizeCache {
                var size = cacheItem.value
                size[keyPath: keyPath] = itemSize
                sizeCache[cacheItem.key] = size
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
        available: QFloat,
        inset: QFloat,
        itemsCount: Int,
        minSize: QFloat?,
        maxSize: QFloat?,
        sizeCache: [Int : QSize],
        keyPath: KeyPath< QSize, QFloat >
    ) -> Pass {
        var newFull: QFloat
        var newItems: QFloat
        if let maxSize = maxSize, pass.full < available {
            let itemSize = min((available - inset - pass.spacings) / QFloat(itemsCount), maxSize)
            newItems = itemSize * QFloat(itemsCount)
            newFull = (newItems + pass.spacings) + inset
        } else if let minSize = minSize, pass.full > available {
            let itemSize = max((available - inset - pass.spacings) / QFloat(itemsCount), minSize)
            newItems = itemSize * QFloat(itemsCount)
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

private extension QStackLayoutHelper {
    
    @inline(__always)
    static func _passSize(
        available: QSize,
        items: [QLayoutItem],
        sizeCache: inout [Int : QSize]
    ) -> SizePass {
        var rf = QSize()
        var rm = QSize()
        for index in 0..<items.count {
            let size: QSize
            if let cacheSize = sizeCache[index] {
                size = cacheSize
            } else {
                size = items[index].size(available)
                sizeCache[index] = size
            }
            rf.width += size.width
            rf.height += size.height
            rm.width = max(rm.width, size.width)
            rm.height = max(rm.height, size.height)
        }
        return SizePass(
            full: rf,
            max: rm
        )
    }
    
}
