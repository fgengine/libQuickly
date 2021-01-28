//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQDialogContainer : IQContainer, IQContainerParentable {
    
    #if os(iOS)
    var interactiveLimit: QFloat { set get }
    var interactiveVelocity: QFloat { set get }
    #endif
    var containers: [IQDialogContentContainer] { get }
    var previousContainer: IQDialogContentContainer? { get }
    var currentContainer: IQDialogContentContainer? { get }
    
    func present(container: IQDialogContentContainer, animated: Bool, completion: (() -> Void)?)
    func dismiss(container: IQDialogContentContainer, animated: Bool, completion: (() -> Void)?)
    
}

public extension IQDialogContainer {
    
    func present(container: IQDialogContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.present(container: container, animated: animated, completion: completion)
    }
    
    func dismiss(container: IQDialogContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.dismiss(container: container, animated: animated, completion: completion)
    }
    
}

public protocol IQDialogContentContainer : IQContainer {
    
    var dialogContainer: IQDialogContainer? { set get }
    
}

public extension IQDialogContentContainer where Self : IQContainerParentable {
    
    var dialogContainer: IQDialogContainer? {
        set(value) { self.parentContainer = value }
        get { return self.parentContainer as? IQDialogContainer }
    }
    
}
