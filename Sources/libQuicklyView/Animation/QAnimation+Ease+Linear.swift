//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QAnimation.Ease {

    struct Linear : IQAnimationEase {
        
        public init() {
        }

        public func perform(_ x: Float) -> Float {
            return x
        }

    }

}
