//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QAnimation.Ease {

    struct CubicIn : IQAnimationEase {
        
        public init() {
        }

        public func perform(_ x: Float) -> Float {
            return x * x * x
        }

    }

    struct CubicOut : IQAnimationEase {
        
        public init() {
        }

        public func perform(_ x: Float) -> Float {
            let p = x - 1
            return  p * p * p + 1
        }

    }

    struct CubicInOut : IQAnimationEase {
        
        public init() {
        }

        public func perform(_ x: Float) -> Float {
            if x < 1/2 {
                return 4 * x * x * x
            } else {
                let f = ((2 * x) - 2)
                return 1/2 * f * f * f + 1
            }
        }

    }

}
