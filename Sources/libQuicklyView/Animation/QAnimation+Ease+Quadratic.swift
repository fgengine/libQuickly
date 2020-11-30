//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QAnimation.Ease {

    struct QuadraticIn : IQAnimationEase {
        
        public init() {
        }

        public func perform(_ x: QFloat) -> QFloat {
            return x * x
        }

    }

    struct QuadraticOut : IQAnimationEase {
        
        public init() {
        }

        public func perform(_ x: QFloat) -> QFloat {
            return -(x * (x - 2))
        }

    }

    struct QuadraticInOut : IQAnimationEase {
        
        public init() {
        }

        public func perform(_ x: QFloat) -> QFloat {
            if x < 1 / 2 {
                return 2 * x * x
            } else {
                return (-2 * x * x) + (4 * x) - 1
            }
        }

    }

}
