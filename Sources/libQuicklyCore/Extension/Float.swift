//
//  libQuicklyCore
//

import Foundation

public extension Float {
    
    @inlinable
    func apply(_ dimension: QDimensionBehaviour) -> Self {
        let result: Self
        switch dimension {
        case .fixed(let value): result = max(0, value)
        case .percent(let value): result = max(0, self * value)
        case .fill: result = max(0, self)
        }
        return result
    }
    
}
