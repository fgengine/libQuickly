//
//  libQuicklyView
//

import Foundation

public struct QReuseView< Reusable: IQReusable > {
    
    @inlinable
    public var isLoaded: Bool {
        return self.item != nil
    }
    
    public var item: Reusable.Item?
    
    @inlinable
    public mutating func load(view: Reusable.View) {
        self.item = QReuseCache.shared.get(Reusable.self, view: view)
    }
    
    @inlinable
    public mutating func unload(view: Reusable.View) {
        if let item = self.item {
            QReuseCache.shared.set(Reusable.self, view: view, item: item)
        }
        self.item = nil
    }
    
}
