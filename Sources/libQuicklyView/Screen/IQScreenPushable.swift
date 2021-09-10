//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQScreenPushable : AnyObject {
    
    var pushDuration: TimeInterval? { get }
    
}

public extension IQScreenPushable {
    
    var pushDuration: TimeInterval? {
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
    
    @inlinable
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.pushContentContainer?.dismiss(animated: animated, completion: completion)
    }
    
}
