//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQScreenPageable : AnyObject {
    
    associatedtype PageItemView : IQBarItemView
    
    var pageItemView: PageItemView { get }
    
}

public extension IQScreenPageable where Self : IQScreen {
    
    @inlinable
    var pageContentContainer: IQPageContentContainer? {
        guard let contentContainer = self.container as? IQPageContentContainer else { return nil }
        return contentContainer
    }
    
    @inlinable
    var pageContainer: IQPageContainer? {
        return self.pageContentContainer?.pageContainer
    }
    
}
