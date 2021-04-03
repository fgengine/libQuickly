//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQViewSelectable : IQViewStyleable {
    
    var isSelected: Bool { get }
    
    @discardableResult
    func select(_ value: Bool) -> Self
    
}
