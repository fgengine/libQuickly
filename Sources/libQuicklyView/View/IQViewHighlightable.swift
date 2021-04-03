//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQViewHighlightable : IQViewStyleable {
    
    var isHighlighted: Bool { get }
    
    @discardableResult
    func highlight(_ value: Bool) -> Self
    
}
