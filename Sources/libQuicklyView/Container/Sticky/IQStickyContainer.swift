//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQStickyContainer : IQContainer, IQContainerParentable {
    
    var contentContainer: IQStickyContentContainer { set get }
    var accessoryContainer: IQStickyAccessoryContainer { set get }
    
}

public protocol IQStickyContentContainer : IQContainer, IQContainerParentable {
    
    var stickyContainer: IQStickyContainer? { get }
    
}

public extension IQStickyContentContainer {
    
    @inlinable
    var stickyContainer: IQStickyContainer? {
        return self.parent as? IQStickyContainer
    }
    
}

public protocol IQStickyAccessoryContainer : IQStickyContentContainer {
    
    var stickySize: Float { get }
    
}

public extension IQStickyAccessoryContainer {
    
    var stickySize: Float? {
        return 96
    }
    
}
