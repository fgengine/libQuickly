//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQPanGesture : IQGesture {
    
    func velocity(in view: IQView) -> QPoint
    
    @discardableResult
    func onBegin(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onChange(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onCancel(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onEnd(_ value: (() -> Void)?) -> Self
    
}
