//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQPushContainer : IQContainer, IQContainerParentable {
    
    var additionalInset: QInset { set get }
    var contentContainer: (IQContainer & IQContainerParentable)? { set get }
    var containers: [IQPushContentContainer] { get }
    var previousContainer: IQPushContentContainer? { get }
    var currentContainer: IQPushContentContainer? { get }
    var animationVelocity: Float { set get }
    #if os(iOS)
    var interactiveLimit: Float { set get }
    #endif
    
    func present(container: IQPushContentContainer, animated: Bool, completion: (() -> Void)?)
    func dismiss(container: IQPushContentContainer, animated: Bool, completion: (() -> Void)?)
    
}

public extension IQPushContainer {
    
    @inlinable
    func present(container: IQPushContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.present(container: container, animated: animated, completion: completion)
    }
    
    @inlinable
    func dismiss(container: IQPushContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.dismiss(container: container, animated: animated, completion: completion)
    }
    
}

public protocol IQPushContentContainer : IQContainer, IQContainerParentable {
    
    var pushContainer: IQPushContainer? { get }
    
    var pushDuration: TimeInterval? { get }
    
}

public extension IQPushContentContainer {
    
    @inlinable
    var pushContainer: IQPushContainer? {
        return self.parent as? IQPushContainer
    }
    
    @inlinable
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let pushContainer = self.pushContainer else {
            completion?()
            return
        }
        pushContainer.dismiss(container: self, animated: animated, completion: completion)
    }
    
}
