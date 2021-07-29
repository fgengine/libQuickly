//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQLayoutDelegate : AnyObject {
    
    func setNeedUpdate(_ layout: IQLayout, force: Bool)
    func updateIfNeeded(_ layout: IQLayout)
    
}

public protocol IQLayout : AnyObject {
    
    var delegate: IQLayoutDelegate? { set get }
    var view: IQView? { set get }
    
    func setNeedUpdate()
    func updateIfNeeded()
    
    func invalidate(item: QLayoutItem)
    func invalidate()

    func layout(bounds: QRect) -> QSize
    
    func size(_ available: QSize) -> QSize
    
    func items(bounds: QRect) -> [QLayoutItem]
    
}

public extension IQLayout {
    
    @inlinable
    func setNeedForceUpdate(item: QLayoutItem) {
        self.invalidate(item: item)
        self.delegate?.setNeedUpdate(self, force: true)
    }
    
    @inlinable
    func setNeedForceUpdate() {
        self.invalidate()
        self.delegate?.setNeedUpdate(self, force: true)
    }
    
    @inlinable
    func setNeedUpdate() {
        self.delegate?.setNeedUpdate(self, force: false)
    }
    
    @inlinable
    func updateIfNeeded() {
        self.delegate?.updateIfNeeded(self)
    }
    
    @inlinable
    func invalidate(item: QLayoutItem) {
    }
    
    @inlinable
    func invalidate() {
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
