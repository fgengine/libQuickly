//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQPageContainer : IQContainer, IQContainerParentable {
    
    #if os(iOS)
    var interactiveLimit: QFloat { set get }
    var interactiveVelocity: QFloat { set get }
    #endif
    var containers: [IQPageContentContainer] { get }
    var backwardContainer: IQPageContentContainer? { get }
    var currentContainer: IQPageContentContainer? { get }
    var forwardContainer: IQPageContentContainer? { get }
    
    func update(container: IQPageContentContainer, animated: Bool, completion: (() -> Void)?)
    
    func set(containers: [IQPageContentContainer], current: IQPageContentContainer?, animated: Bool, completion: (() -> Void)?)
    func set(current: IQPageContentContainer, animated: Bool, completion: (() -> Void)?)
    
}

public protocol IQPageContentContainer : IQContainer {
    
    var pageContainer: IQPageContainer? { set get }
    
    var pageBarSize: QFloat { get }
    var pageBarItemView: IQView & IQViewSelectable { get }
    
}

public extension IQPageContentContainer where Self : IQContainerParentable {
    
    var pageContainer: IQPageContainer? {
        set(value) { self.parentContainer = value }
        get { return self.parentContainer as? IQPageContainer }
    }
    
}
