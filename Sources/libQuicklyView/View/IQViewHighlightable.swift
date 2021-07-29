//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQViewHighlightable : IQViewStyleable {
    
    var isHighlighted: Bool { set get }
    
    @discardableResult
    func highlight(_ value: Bool) -> Self
    
}
