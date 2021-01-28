//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQScreenStackable : AnyObject {
    
    associatedtype StackBar : IQStackBarView
    
    var stackBarView: StackBar { get }
    var stackBarSize: QFloat { get }
    var stackBarVisibility: QFloat { get }
    var stackBarHidden: Bool { get }
    
}

public extension IQScreenStackable {
    
    var stackBarSize: QFloat {
        return 50
    }
    
    var stackBarVisibility: QFloat {
        return 1
    }
    
    var stackBarHidden: Bool {
        return false
    }
    
}
