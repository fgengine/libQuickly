//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQPinchGesture : IQGesture {
    
    func velocity() -> QFloat
    
    func scale() -> QFloat
    
    @discardableResult
    func onBegin(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onChange(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onCancel(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onEnd(_ value: (() -> Void)?) -> Self
    
}
