//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQScreenPushable : AnyObject {
    
    var pushDuration: QFloat? { get }
    
}

public extension IQScreenPushable {
    
    var pushDuration: QFloat? {
        return 3
    }
    
}

public extension IQScreenPushable where Self : IQScreen {
    
    @inlinable
    var pushContentContainer: IQPushContentContainer? {
        guard let contentContainer = self.container as? IQPushContentContainer else { return nil }
        return contentContainer
    }
    
    @inlinable
    var pushContainer: IQPushContainer? {
        return self.pushContentContainer?.pushContainer
    }
    
}
