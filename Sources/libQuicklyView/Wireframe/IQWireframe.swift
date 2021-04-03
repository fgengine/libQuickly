//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQWireframe {
    
    associatedtype Container : IQContainer
    
    var container: Container { get }
    
}
