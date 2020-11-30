//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQStackContainer : IQContainer, IQContainerParentable {
    
    #if os(iOS)
    var interactiveLimit: QFloat { set get }
    var interactiveVelocity: QFloat { set get }
    #endif
    var containers: [IQStackContentContainer] { get }
    var rootContainer: IQStackContentContainer? { get }
    var currentContainer: IQStackContentContainer? { get }
    
    func update(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?)
    
    func set(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?)
    func set(containers: [IQStackContentContainer], animated: Bool, completion: (() -> Void)?)
    func push(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?)
    func push(containers: [IQStackContentContainer], animated: Bool, completion: (() -> Void)?)
    func pop(animated: Bool, completion: (() -> Void)?)
    func popTo(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?)
    func popToRoot(animated: Bool, completion: (() -> Void)?)
    
}

public protocol IQStackContentContainer : IQContainer {
    
    var stackContainer: IQStackContainer? { set get }
    
    var stackBarSize: QFloat { get }
    var stackBarVisibility: QFloat { get }
    var stackBarHidden: Bool { get }
    var stackBarItemView: IQView { get }
    
}

public extension IQStackContentContainer where Self : IQContainerParentable {
    
    var stackContainer: IQStackContainer? {
        set(value) { self.parentContainer = value }
        get { return self.parentContainer as? IQStackContainer }
    }
    
}
