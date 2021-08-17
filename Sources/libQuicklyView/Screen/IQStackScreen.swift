//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQStackScreen : IQScreen {
}

public extension IQStackScreen {
    
    @inlinable
    var stackContainer: IQStackContainer? {
        return self.container as? IQStackContainer
    }
    
}
