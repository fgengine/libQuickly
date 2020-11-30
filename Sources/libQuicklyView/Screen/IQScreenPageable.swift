//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQScreenPageable : AnyObject {
    
    associatedtype PageBarItem : IQView & IQViewSelectable
    
    var pageBarSize: QFloat { get }
    var pageBarItemView: PageBarItem { get }
    
}

public extension IQScreenPageable {
    
    var pageBarSize: QFloat {
        return 50
    }
    
}
