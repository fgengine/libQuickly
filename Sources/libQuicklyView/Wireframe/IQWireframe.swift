//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQWireframe : AnyObject {
    
    associatedtype Container : IQContainer
    
    var container: Container { get }
    
}
