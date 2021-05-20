//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQDialogContainer : IQContainer, IQContainerParentable {
    
    var contentContainer: IQContainer & IQContainerParentable { set get }
    var containers: [IQDialogContentContainer] { get }
    var previousContainer: IQDialogContentContainer? { get }
    var currentContainer: IQDialogContentContainer? { get }
    var animationVelocity: Float { set get }
    #if os(iOS)
    var interactiveLimit: Float { set get }
    #endif
    
    func present(container: IQDialogContentContainer, animated: Bool, completion: (() -> Void)?)
    func dismiss(container: IQDialogContentContainer, animated: Bool, completion: (() -> Void)?)
    
}

public extension IQDialogContainer {
    
    @inlinable
    func present(container: IQDialogContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.present(container: container, animated: animated, completion: completion)
    }
    
    @inlinable
    func dismiss(container: IQDialogContentContainer, animated: Bool = true, completion: (() -> Void)? = nil) {
        self.dismiss(container: container, animated: animated, completion: completion)
    }
    
}

public enum QDialogContentContainerSize : Equatable {
    case fill(before: Float, after: Float)
    case fixed(value: Float)
    case fit
}

public enum QDialogContentContainerAlignment {
    case topLeft
    case top
    case topRight
    case centerLeft
    case center
    case centerRight
    case bottomLeft
    case bottom
    case bottomRight
}

public protocol IQDialogContentContainer : IQContainer, IQContainerParentable {
    
    var dialogContainer: IQDialogContainer? { get }
    
    var dialogWidth: QDialogContentContainerSize { get }
    var dialogHeight: QDialogContentContainerSize { get }
    var dialogAlignment: QDialogContentContainerAlignment { get }
    
}

public extension IQDialogContentContainer where Self : IQContainerParentable {
    
    @inlinable
    var dialogContainer: IQDialogContainer? {
        return self.parent as? IQDialogContainer
    }
    
    @inlinable
    func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let dialogContainer = self.dialogContainer else {
            completion?()
            return
        }
        dialogContainer.dismiss(container: self, animated: animated, completion: completion)
    }
    
}
