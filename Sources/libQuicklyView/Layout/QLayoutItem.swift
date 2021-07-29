//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QLayoutItem {
    
    public var frame: QRect
    public private(set) var view: IQView
    
    public init(
        view: IQView
    ) {
        self.frame = .zero
        self.view = view
        
        self.view.item = self
    }
    
    deinit {
        self.view.item = nil
    }
    
}

public extension QLayoutItem {
    
    @inlinable
    func size(_ available: QSize) -> QSize {
        return self.view.size(available)
    }
    
}
