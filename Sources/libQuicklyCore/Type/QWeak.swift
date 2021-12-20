//
//  libQuicklyCore
//

import Foundation

public struct QWeakObject< Value : AnyObject > {
    
    public weak var value: Value?
    
    public init(_ value: Value) {
        self.value = value
    }
    
}
