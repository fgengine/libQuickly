//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQScreenGroupable : AnyObject {
    
    associatedtype GroupItemView : IQBarItemView
    
    var groupItemView: GroupItemView { get }
    
}

public extension IQScreenGroupable where Self : IQScreen {
    
    @inlinable
    var groupContentContainer: IQGroupContentContainer? {
        guard let contentContainer = self.container as? IQGroupContentContainer else { return nil }
        return contentContainer
    }
    
    @inlinable
    var groupContainer: IQGroupContainer? {
        return self.groupContentContainer?.groupContainer
    }
    
}
