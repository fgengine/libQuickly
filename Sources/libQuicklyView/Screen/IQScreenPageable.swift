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
    
    @inlinable
    func updatePage(animated: Bool, completion: (() -> Void)? = nil) {
        guard let contentContainer = self.pageContentContainer else {
            completion?()
            return
        }
        guard let container = contentContainer.pageContainer else {
            completion?()
            return
        }
        container.update(container: contentContainer, animated: animated, completion: completion)
    }
    
}
