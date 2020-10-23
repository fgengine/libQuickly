//
//  libQuicklyView
//

import Foundation

public typealias QFloat = Float

public extension QFloat {
    
    @inlinable
    var degreesToRadians: QFloat {
        get { return self * .pi / 180 }
    }
    
    @inlinable
    var radiansToDegrees: QFloat {
        get { return self * 180 / .pi }
    }
    
    @inlinable
    func ceil() -> QFloat {
        return Foundation.ceil(self)
    }
    
    @inlinable
    func lerp(_ to: QFloat, progress: QFloat) -> QFloat {
        if abs(self - to) > QFloat.leastNonzeroMagnitude {
            return ((1 - progress) * self) + (progress * to)
        }
        return self
    }
    
    @inlinable
    func apply(_ dimension: QDimensionBehaviour) -> QFloat {
        let result: QFloat
        switch dimension {
        case .fixed(let value): result = max(0, value)
        case .percent(let value): result = max(0, self * value)
        case .fill: result = max(0, self)
        }
        return result
    }

}
