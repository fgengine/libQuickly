//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QAnimation.Ease {

    struct ExponencialIn : IQAnimationEase {
        
        public init() {
        }

        public func perform(_ x: Float) -> Float {
            return (x == 0) ? x : pow(2, 10 * (x - 1))
        }

    }

    struct ExponencialOut : IQAnimationEase {
        
        public init() {
        }

        public func perform(_ x: Float) -> Float {
            return (x == 1) ? x : 1 - pow(2, -10 * x)
        }

    }

    struct ExponencialInOut : IQAnimationEase {
        
        public init() {
        }

        public func perform(_ x: Float) -> Float {
            if x == 0 || x == 1 { return x }
            if x < 1 / 2 {
                return 1 / 2 * pow(2, (20 * x) - 10)
            } else {
                let h = pow(2, (-20 * x) + 10)
                return -1 / 2 * h + 1
            }
        }

    }

}
