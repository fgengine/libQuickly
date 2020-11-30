//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QAnimation.Ease {
    
    struct BackIn : IQAnimationEase {
        
        public init() {
        }

        public func perform(_ x: QFloat) -> QFloat {
            return x * x * x - x * sin(x * .pi)
        }

    }

    struct BackOut : IQAnimationEase {
        
        public init() {
        }

        public func perform(_ x: QFloat) -> QFloat {
            let f = (1 - x)
            return 1 - (f * f * f - f * sin(f * .pi))
        }

    }

    struct BackInOut : IQAnimationEase {
        
        public init() {
        }

        public func perform(_ x: QFloat) -> QFloat {
            if x < 1 / 2 {
                let f = 2 * x
                return 1 / 2 * (f * f * f - f * sin(f * .pi))
            } else {
                let f = 1 - (2 * x - 1)
                let g = sin(f * .pi)
                let h = (f * f * f - f * g)
                return 1 / 2 * (1 - h) + 1 / 2
            }
        }

    }
    
}
