//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQScreenPageable : AnyObject {
    
    associatedtype PageItemView : IQView & IQViewSelectable
    
    var pageItemView: PageItemView { get }
    
}

public extension IQScreenPageable {
}
