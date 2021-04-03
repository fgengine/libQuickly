//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQScreenModalable : AnyObject {
}

public extension IQScreenModalable where Self : IQScreen {
    
    @inlinable
    var modalContentContainer: IQModalContentContainer? {
        guard let contentContainer = self.container as? IQModalContentContainer else { return nil }
        return contentContainer
    }
    
    @inlinable
    var modalContainer: IQModalContainer? {
        return self.modalContentContainer?.modalContainer
    }
    
}
