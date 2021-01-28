//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQPushContainer : IQContainer, IQContainerParentable {
    
    #if os(iOS)
    var interactiveLimit: QFloat { set get }
    var interactiveVelocity: QFloat { set get }
    #endif
    var containers: [IQPushContentContainer] { get }
    var previousContainer: IQPushContentContainer? { get }
    var currentContainer: IQPushContentContainer? { get }
    
    func present(container: IQPushContentContainer, animated: Bool, completion: (() -> Void)?)
    func dismiss(container: IQPushContentContainer, animated: Bool, completion: (() -> Void)?)
    
}

public extension IQPushContainer {
    
    func present(container: IQPushContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.present(container: container, animated: animated, completion: completion)
    }
    
    func dismiss(container: IQPushContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.dismiss(container: container, animated: animated, completion: completion)
    }
    
}

public protocol IQPushContentContainer : IQContainer {
    
    var pushContainer: IQPushContainer? { set get }
    
}

public extension IQPushContentContainer where Self : IQContainerParentable {
    
    var pushContainer: IQPushContainer? {
        set(value) { self.parentContainer = value }
        get { return self.parentContainer as? IQPushContainer }
    }
    
}
