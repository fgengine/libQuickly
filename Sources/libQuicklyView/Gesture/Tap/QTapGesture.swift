//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

public final class QTapGesture : NSObject, IQTapGesture {
    
    public var native: QNativeGesture {
        return self._native
    }
    public private(set) var isEnabled: Bool {
        set(value) { self._native.isEnabled = value }
        get { return self._native.isEnabled }
    }
    public private(set) var numberOfTapsRequired: UInt {
        set(value) { self._native.numberOfTapsRequired = Int(value) }
        get { return UInt(self._native.numberOfTapsRequired) }
    }
    public private(set) var numberOfTouchesRequired: UInt {
        set(value) { self._native.numberOfTouchesRequired = Int(value) }
        get { return UInt(self._native.numberOfTouchesRequired) }
    }
    
    private var _native: UITapGestureRecognizer
    private var _onShouldBegin: (() -> Bool)?
    private var _onShouldSimultaneously: ((_ otherGesture: QNativeGesture) -> Bool)?
    private var _onShouldRequireFailure: ((_ otherGesture: QNativeGesture) -> Bool)?
    private var _onShouldBeRequiredToFailBy: ((_ otherGesture: QNativeGesture) -> Bool)?
    private var _onTriggered: (() -> Void)?
    
    public init(
        numberOfTapsRequired: UInt = 1,
        numberOfTouchesRequired: UInt = 1
    ) {
        self._native = UITapGestureRecognizer()
        self._native.numberOfTapsRequired = Int(numberOfTapsRequired)
        self._native.numberOfTouchesRequired = Int(numberOfTouchesRequired)
        super.init()
        self._native.delegate = self
        self._native.addTarget(self, action: #selector(self._handle))
    }
    
    public func require(toFail gesture: QNativeGesture) {
        self.native.require(toFail: gesture)
    }
    
    public func location(in view: IQView) -> QPoint {
        return QPoint(self._native.location(in: view.native))
    }
    
    @discardableResult
    public func enabled(_ value: Bool) -> Self {
        self.isEnabled = value
        return self
    }
    
    @discardableResult
    public func numberOfTapsRequired(_ value: UInt) -> Self {
        self.numberOfTapsRequired = value
        return self
    }
    
    @discardableResult
    public func numberOfTouchesRequired(_ value: UInt) -> Self {
        self.numberOfTouchesRequired = value
        return self
    }
    
    @discardableResult
    public func onShouldBegin(_ value: (() -> Bool)?) -> Self {
        self._onShouldBegin = value
        return self
    }
    
    @discardableResult
    public func onShouldSimultaneously(_ value: ((_ otherGesture: QNativeGesture) -> Bool)?) -> Self {
        self._onShouldSimultaneously = value
        return self
    }
    
    @discardableResult
    public func onShouldRequireFailure(_ value: ((_ otherGesture: QNativeGesture) -> Bool)?) -> Self {
        self._onShouldRequireFailure = value
        return self
    }
    
    @discardableResult
    public func onShouldBeRequiredToFailBy(_ value: ((_ otherGesture: QNativeGesture) -> Bool)?) -> Self {
        self._onShouldBeRequiredToFailBy = value
        return self
    }
    
    @discardableResult
    public func onTriggered(_ value: (() -> Void)?) -> Self {
        self._onTriggered = value
        return self
    }
    
}

private extension QTapGesture {
    
    @objc
    func _handle() {
        self._onTriggered?()
    }
    
}

extension QTapGesture : UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self._onShouldBegin?() ?? true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self._onShouldSimultaneously?(otherGestureRecognizer) ?? false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self._onShouldRequireFailure?(otherGestureRecognizer) ?? false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self._onShouldBeRequiredToFailBy?(otherGestureRecognizer) ?? false
    }
    
}

#endif
