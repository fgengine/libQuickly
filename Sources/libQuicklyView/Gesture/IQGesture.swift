//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQGesture : AnyObject {
    
    var native: QNativeGesture { get }
    var isEnabled: Bool { get }
    
    func contains(in view: IQView) -> Bool
    
    func location(in view: IQView) -> QPoint
    
    @discardableResult
    func enabled(_ value: Bool) -> Self
    
    @discardableResult
    func onShouldBegin(_ value: (() -> Bool)?) -> Self
    
    @discardableResult
    func onShouldSimultaneously(_ value: ((_ otherGesture: QNativeGesture) -> Bool)?) -> Self
    
    @discardableResult
    func onShouldRequireFailure(_ value: ((_ otherGesture: QNativeGesture) -> Bool)?) -> Self
    
    @discardableResult
    func onShouldBeRequiredToFailBy(_ value: ((_ otherGesture: QNativeGesture) -> Bool)?) -> Self
    
}

public extension IQGesture {
    
    func contains(in view: IQView) -> Bool {
        let bounds = QRect(view.native.bounds)
        let location = QPoint(self.native.location(in: view.native))
        return bounds.isContains(point: location)
    }
    
}
