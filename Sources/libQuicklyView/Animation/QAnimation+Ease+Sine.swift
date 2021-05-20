//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QAnimation.Ease {

    struct SineIn : IQAnimationEase {
        
        public init() {
        }

        public func perform(_ x: Float) -> Float {
            return (sin((x - 1) * .pi / 2) ) + 1
        }

    }

    struct SineOut : IQAnimationEase {
        
        public init() {
        }

        public func perform(_ x: Float) -> Float {
            return sin(x * .pi / 2)
        }

    }

    struct SineInOut : IQAnimationEase {
        
        public init() {
        }

        public func perform(_ x: Float) -> Float {
            return 1 / 2 * (1 - cos(x * .pi))
        }

    }

}
