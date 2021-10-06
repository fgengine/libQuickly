//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQLayoutDelegate : AnyObject {
    
    @discardableResult
    func setNeedUpdate(_ layout: IQLayout) -> Bool
    
    func updateIfNeeded(_ layout: IQLayout)
    
}

public protocol IQLayout : AnyObject {
    
    var delegate: IQLayoutDelegate? { set get }
    var view: IQView? { set get }
    
    func setNeedUpdate()
    func updateIfNeeded()
    
    func invalidate(item: QLayoutItem)

    func layout(bounds: QRect) -> QSize
    
    func size(available: QSize) -> QSize
    
    func items(bounds: QRect) -> [QLayoutItem]
    
}

public extension IQLayout {
    
    @inlinable
    func setNeedForceUpdate(item: QLayoutItem? = nil) {
        if let item = item {
            self.invalidate(item: item)
        }
        let forceParent: Bool
        if let delegate = self.delegate {
            forceParent = delegate.setNeedUpdate(self)
        } else {
            forceParent = true
        }
        if forceParent == true {
            if let view = self.view, let item = view.item {
                if let layout = view.layout {
                    layout.setNeedForceUpdate(item: item)
                } else {
                    item.setNeedForceUpdate()
                }
            }
        }
    }
    
    @inlinable
    func setNeedUpdate() {
        self.delegate?.setNeedUpdate(self)
    }
    
    @inlinable
    func updateIfNeeded() {
        self.delegate?.updateIfNeeded(self)
    }
    
    @inlinable
    func invalidate(item: QLayoutItem) {
    }
    
    @inlinable
    func visible(items: [QLayoutItem], for bounds: QRect) -> [QLayoutItem] {
        guard let firstIndex = items.firstIndex(where: { return bounds.isIntersects(rect: $0.frame) }) else { return [] }
        var result: [QLayoutItem] = [ items[firstIndex] ]
        let start = min(firstIndex + 1, items.count)
        let end = items.count
        for index in start ..< end {
            let item = items[index]
            if bounds.isIntersects(rect: item.frame) == true {
                result.append(item)
            } else {
                break
            }
        }
        return result
    }
    
}
