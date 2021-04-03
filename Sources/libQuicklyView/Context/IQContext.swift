//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQContext {
}

public protocol IQContextable {
    
    associatedtype Context
    
    var context: Context { get }
    
}
