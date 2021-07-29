//
//  libQuicklyCore
//

import Foundation

public extension Float {
    
    @inlinable
    func apply(_ dimension: QDimensionBehaviour) -> Self {
        return dimension.value(self)
    }
    
}
