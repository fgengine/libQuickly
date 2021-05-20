//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQAnimationEase {
    
    func perform(_ x: Float) -> Float
    
}

public protocol IQAnimationTask {
    
    var isRunning: Bool { get }
    var isCompletion: Bool { get }
    var isCanceled: Bool { get }
    
    func cancel()
    
}
