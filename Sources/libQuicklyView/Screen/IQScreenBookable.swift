//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQScreenBookable : AnyObject {
    
    associatedtype BookIdentifier
    
    var bookIdentifier: BookIdentifier { get }
    
}

public extension IQScreenBookable where Self : IQScreen {
    
    @inlinable
    var bookContentContainer: IQBookContentContainer? {
        guard let contentContainer = self.container as? IQBookContentContainer else { return nil }
        return contentContainer
    }
    
    @inlinable
    var bookContainer: IQBookContainer? {
        return self.bookContentContainer?.bookContainer
    }
    
}
