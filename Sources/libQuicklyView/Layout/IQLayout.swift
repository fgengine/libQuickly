//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQLayoutDelegate : AnyObject {
    
    func bounds(_ layout: IQLayout) -> QRect
    
    func setNeedUpdate(_ layout: IQLayout)
    func updateIfNeeded(_ layout: IQLayout)
    
}

public protocol IQLayout : AnyObject {
    
    var delegate: IQLayoutDelegate? { set get }
    var parentView: IQView? { set get }
    var items: [IQLayoutItem] { get }
    var size: QSize { get }
    var isValid: Bool { get }
    
    func setNeedUpdate()
    func updateIfNeeded()

    func layout()
    
    func size(_ available: QSize) -> QSize
    
    func items(bounds: QRect) -> [IQLayoutItem]
    
}

public extension IQLayout {
    
    var isValid: Bool {
        return self.size.width > 0 || self.size.height > 0
    }
    
    func setNeedUpdate() {
        self.delegate?.setNeedUpdate(self)
    }
    
    func updateIfNeeded() {
        self.delegate?.updateIfNeeded(self)
    }
    
    func items(bounds: QRect) -> [IQLayoutItem] {
        guard let firstIndex = self.items.firstIndex(where: { return bounds.isIntersects(rect: $0.frame) }) else { return [] }
        var result: [IQLayoutItem] = [ self.items[firstIndex] ]
        let start = min(firstIndex + 1, self.items.count)
        let end = self.items.count
        for index in start..<end {
            let item = self.items[index]
            if bounds.isIntersects(rect: item.frame) == true {
                result.append(item)
            } else {
                break
            }
        }
        return result
    }
    
}
