//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQAnimationEase {
    
    func perform(_ x: QFloat) -> QFloat
    
}

public protocol IQAnimationBlock {
    
    var delay: QFloat { get }
    var duration: QFloat { get }
    var elapsed: QFloat { get }
    var ease: IQAnimationEase { get }
    var processing: (_ progress: QFloat) -> Void { get }
    var completion: () -> Void { get }
    
    func perform(_ delta: QFloat) -> QFloat
    
}
