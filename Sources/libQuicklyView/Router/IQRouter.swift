//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQRouter : AnyObject {
}

public protocol IQRouterable {
    
    associatedtype Router = IQRouter
    
    var router: Router? { get }
    
}
