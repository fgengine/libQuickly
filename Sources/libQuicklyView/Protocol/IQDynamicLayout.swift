//
//  libQuicklyView
//

import Foundation

public protocol IQDynamicLayout : IQLayout {

    func items(bounds: QRect) -> [IQLayoutItem]
    
    func insert(item: IQLayoutItem, at index: UInt)
    func delete(item: IQLayoutItem)
    
}

public extension IQDynamicLayout {
    
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
