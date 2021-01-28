//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension Collection where Element == IQLayoutItem {
    
    func apply(offset: QPoint) {
        for item in self {
            item.frame = item.frame.offset(point: offset)
        }
    }
    
}

public extension Collection where Element == IQLayoutItem {
    
    func horizontalLayout(bounds: QRect, inset: QInset, spacing: QFloat) -> QSize {
        var result = QSize(width: 0, height: bounds.size.height)
        guard self.count > 0 else { return result }
        result.width += inset.left
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: bounds.origin.y + inset.top
        )
        let height = result.height - (inset.top + inset.bottom)
        for item in self {
            let size = item.size(QSize(width: .infinity, height: height))
            item.frame = QRect(
                x: origin.x + size.width,
                y: origin.y,
                width: size.width,
                height: height
            )
            result.width += result.width + spacing
            result.height = Swift.max(height, size.height)
            origin.x += size.width + spacing
        }
        result.width -= spacing
        result.width += inset.right
        result.height += inset.top + inset.bottom
        return result
    }
    
    func horizontalSize(available: QSize, inset: QInset, spacing: QFloat) -> QSize {
        var result = QSize(width: 0, height: 0)
        result.width += inset.left
        let height = available.height - (inset.top + inset.bottom)
        for item in self {
            let size = item.size(QSize(width: .infinity, height: height))
            result.width += size.width + spacing
            result.height = Swift.max(height, size.height)
        }
        result.width -= spacing
        result.width += inset.right
        result.height += inset.top + inset.bottom
        return result
    }
    
}

public extension Collection where Element == IQLayoutItem {
    
    func verticalLayout(bounds: QRect, inset: QInset, spacing: QFloat) -> QSize {
        var result = QSize(width: bounds.size.width, height: 0)
        guard self.count > 0 else { return result }
        result.height += inset.top
        var origin = QPoint(
            x: bounds.origin.x + inset.left,
            y: bounds.origin.y + inset.top
        )
        let width = result.width - (inset.left + inset.right)
        for item in self {
            let size = item.size(QSize(width: width, height: .infinity))
            item.frame = QRect(
                x: origin.x,
                y: origin.y,
                width: width,
                height: size.height
            )
            result.width = Swift.max(width, size.width)
            result.height += size.height + spacing
            origin.y += size.height + spacing
        }
        result.height -= spacing
        result.height += inset.bottom
        result.width += inset.left + inset.right
        return result
    }
    
    func verticalSize(available: QSize, inset: QInset, spacing: QFloat) -> QSize {
        var result = QSize(width: 0, height: 0)
        result.height += inset.top
        let width = available.width - (inset.left + inset.right)
        for item in self {
            let size = item.size(QSize(width: width, height: .infinity))
            result.width = Swift.max(width, size.width)
            result.height += size.height + spacing
        }
        result.height -= spacing
        result.height += inset.bottom
        result.width += inset.left + inset.right
        return result
    }
    
}
