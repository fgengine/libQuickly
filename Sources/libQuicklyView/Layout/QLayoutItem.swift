//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QLayoutItem {
    
    public var frame: QRect
    public private(set) var view: IQView
    public private(set) var isNeedForceUpdate: Bool
    
    public init(
        view: IQView
    ) {
        self.frame = .zero
        self.view = view
        self.isNeedForceUpdate = false
        
        self.view.item = self
    }
    
    deinit {
        self.view.item = nil
    }
    
}

public extension QLayoutItem {
    
    func setNeedForceUpdate() {
        self.isNeedForceUpdate = true
    }
    
    func resetNeedForceUpdate() {
        self.isNeedForceUpdate = false
    }
    
    @inlinable
    func size(_ available: QSize) -> QSize {
        return self.view.size(available)
    }
    
}
