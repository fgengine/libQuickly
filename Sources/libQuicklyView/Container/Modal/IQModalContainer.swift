//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQModalContainer : IQContainer, IQContainerParentable {
    
    #if os(iOS)
    var interactiveLimit: QFloat { set get }
    var interactiveVelocity: QFloat { set get }
    #endif
    var containers: [IQModalContentContainer] { get }
    var previousContainer: IQModalContentContainer? { get }
    var currentContainer: IQModalContentContainer? { get }
    
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

public protocol IQModalContentContainer : IQContainer {
    
    var modalContainer: IQModalContainer? { set get }
    
}

public extension IQModalContentContainer where Self : IQContainerParentable {
    
    var modalContainer: IQModalContainer? {
        set(value) { self.parentContainer = value }
        get { return self.parentContainer as? IQModalContainer }
    }
    
}
