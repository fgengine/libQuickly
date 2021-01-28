//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQLayoutDelegate : AnyObject {
    
    func setNeedUpdate(_ layout: IQLayout)
    func updateIfNeeded(_ layout: IQLayout)
    
}

public protocol IQLayout : AnyObject {
    
    var delegate: IQLayoutDelegate? { set get }
    var parentView: IQView? { set get }
    
    func setNeedUpdate(_ isResized: Bool)
    func updateIfNeeded()

    func layout(bounds: QRect) -> QSize
    
    func size(_ available: QSize) -> QSize
    
    func items(bounds: QRect) -> [IQLayoutItem]
    
}

public extension IQLayout {
    
    func setNeedUpdate(_ isResized: Bool = false) {
        if isResized == true {
            self.parentView?.parentLayout?.setNeedUpdate()
        }
        self.delegate?.setNeedUpdate(self)
    }
    
    func updateIfNeeded() {
        self.delegate?.updateIfNeeded(self)
    }
    
    func visible(items: [IQLayoutItem], for bounds: QRect) -> [IQLayoutItem] {
        guard let firstIndex = items.firstIndex(where: { return bounds.isIntersects(rect: $0.frame) }) else { return [] }
        var result: [IQLayoutItem] = [ items[firstIndex] ]
        let start = min(firstIndex + 1, items.count)
        let end = items.count
        for index in start..<end {
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
