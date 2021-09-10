//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQScreenDialogable : AnyObject {
    
    var dialogWidth: QDialogContentContainerSize { get }
    var dialogHeight: QDialogContentContainerSize { get }
    var dialogAlignment: QDialogContentContainerAlignment { get }
    
}

public extension IQScreenDialogable {
    
    var dialogWidth: QDialogContentContainerSize {
        return .fit
    }
    
    var dialogHeight: QDialogContentContainerSize {
        return .fit
    }
    
    var dialogAlignment: QDialogContentContainerAlignment {
        return .center
    }
    
}

public extension IQScreenDialogable where Self : IQScreen {
    
    @inlinable
    var dialogContentContainer: IQDialogContentContainer? {
        guard let contentContainer = self.container as? IQDialogContentContainer else { return nil }
        return contentContainer
    }
    
    @inlinable
    var dialogContainer: IQDialogContainer? {
        return self.dialogContentContainer?.dialogContainer
    }
    
    @inlinable
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.dialogContentContainer?.dismiss(animated: animated, completion: completion)
    }
    
}
