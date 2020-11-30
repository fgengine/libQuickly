//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQGroupContainer : IQContainer, IQContainerParentable {
    
    var containers: [IQGroupContentContainer] { get }
    var currentContainer: IQGroupContentContainer? { get }
    
    func set(containers: [IQGroupContentContainer], currentContainer: IQGroupContentContainer?, animated: Bool, completion: (() -> Void)?)
    func set(currentContainer: IQGroupContentContainer, animated: Bool, completion: (() -> Void)?)
    
}

public protocol IQGroupContentContainer : IQContainer {
    
    var groupContainer: IQGroupContainer? { set get }
    
    var groupBarSize: QFloat { get }
    var groupBarItem: IQView & IQViewSelectable { get }
    
}

public extension IQGroupContentContainer where Self : IQContainerParentable {
    
    var groupContainer: IQGroupContainer? {
        set(value) { self.parentContainer = value }
        get { return self.parentContainer as? IQGroupContainer }
    }
    
}
