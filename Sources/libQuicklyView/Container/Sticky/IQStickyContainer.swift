//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQStickyContainer : IQContainer, IQContainerParentable {
    
    var contentContainer: IQStickyContentContainer? { set get }
    var accessoryContainer: IQStickyAccessoryContainer? { set get }
    
}

public protocol IQStickyContentContainer : IQContainer {
    
    var stickyContainer: IQStickyContainer? { set get }
    
}

public extension IQStickyContentContainer where Self : IQContainerParentable {
    
    var stickyContainer: IQStickyContainer? {
        set(value) { self.parentContainer = value }
        get { return self.parentContainer as? IQStickyContainer }
    }
    
}

public protocol IQStickyAccessoryContainer : IQContainer {
    
    var stickyContainer: IQStickyContainer? { set get }
    var stickySize: QFloat { get }
    
}

public extension IQStickyAccessoryContainer where Self : IQContainerParentable {
    
    var stickyContainer: IQStickyContainer? {
        set(value) { self.parentContainer = value }
        get { return self.parentContainer as? IQStickyContainer }
    }
    
}
