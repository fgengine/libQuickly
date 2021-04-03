//
//  libQuicklyView
//

import Foundation

public struct QReuseItem< Reusable: IQReusable > {
    
    @inlinable
    public var isLoaded: Bool {
        return self.content != nil
    }
    
    public var content: Reusable.Content?
    
    @inlinable
    public mutating func load(owner: Reusable.Owner) {
        self.content = QReuseCache.shared.get(Reusable.self, owner: owner)
    }
    
    @inlinable
    public mutating func unload(owner: Reusable.Owner) {
        if let content = self.content {
            self.content = nil
            QReuseCache.shared.set(Reusable.self, owner: owner, content: content)
        }
    }
    
}
