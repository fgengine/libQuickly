//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQModalContainer : IQContainer, IQContainerParentable {
    
    var contentContainer: IQContainer & IQContainerParentable { set get }
    var containers: [IQModalContentContainer] { get }
    var previousContainer: IQModalContentContainer? { get }
    var currentContainer: IQModalContentContainer? { get }
    var animationVelocity: Float { set get }
    #if os(iOS)
    var interactiveLimit: Float { set get }
    #endif
    
    func present(container: IQModalContentContainer, animated: Bool, completion: (() -> Void)?)
    func dismiss(container: IQModalContentContainer, animated: Bool, completion: (() -> Void)?)
    
}

public extension IQModalContainer {
    
    func present(container: IQModalContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.present(container: container, animated: animated, completion: completion)
    }
    
    func dismiss(container: IQModalContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.dismiss(container: container, animated: animated, completion: completion)
    }
    
}

public protocol IQModalContentContainer : IQContainer, IQContainerParentable {
    
    var modalContainer: IQModalContainer? { get }
    
}

public extension IQModalContentContainer {
    
    @inlinable
    var modalContainer: IQModalContainer? {
        return self.parent as? IQModalContainer
    }
    
    @inlinable
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let modalContainer = self.modalContainer else {
            completion?()
            return
        }
        modalContainer.dismiss(container: self, animated: animated, completion: completion)
    }
    
}
