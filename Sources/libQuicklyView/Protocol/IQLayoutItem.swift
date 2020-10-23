//
//  libQuicklyView
//

import Foundation

public protocol IQLayoutItem : AnyObject {
    
    var frame: QRect { set get }
    var view: IQView { get }

}

public extension IQLayoutItem {
    
    @inlinable
    func size(_ available: QSize) -> QSize {
        return self.view.size(available)
    }
    
}
