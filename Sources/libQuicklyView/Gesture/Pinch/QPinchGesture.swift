//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

public final class QPinchGesture : NSObject, IQPinchGesture {
    
    public var native: QNativeGesture {
        return self._native
    }
    public var isEnabled: Bool {
        set(value) { self._native.isEnabled = value }
        get { return self._native.isEnabled }
    }
    public var cancelsTouchesInView: Bool {
        set(value) { self._native.cancelsTouchesInView = value }
        get { return self._native.cancelsTouchesInView }
    }
    public var delaysTouchesBegan: Bool {
        set(value) { self._native.delaysTouchesBegan = value }
        get { return self._native.delaysTouchesBegan }
    }
    public var delaysTouchesEnded: Bool {
        set(value) { self._native.delaysTouchesEnded = value }
        get { return self._native.delaysTouchesEnded }
    }
    @available(iOS 9.2, *)
    public var requiresExclusiveTouchType: Bool {
        set(value) { self._native.requiresExclusiveTouchType = value }
        get { return self._native.requiresExclusiveTouchType }
    }
    
    private var _native: UIPinchGestureRecognizer
    private var _onShouldBegin: (() -> Bool)?
    private var _onShouldSimultaneously: ((_ otherGesture: QNativeGesture) -> Bool)?
    private var _onShouldRequireFailure: ((_ otherGesture: QNativeGesture) -> Bool)?
    private var _onShouldBeRequiredToFailBy: ((_ otherGesture: QNativeGesture) -> Bool)?
    private var _onBegin: (() -> Void)?
    private var _onChange: (() -> Void)?
    private var _onCancel: (() -> Void)?
    private var _onEnd: (() -> Void)?
    
    public init(
        isEnabled: Bool = true,
        cancelsTouchesInView: Bool = true,
        delaysTouchesBegan: Bool = false,
        delaysTouchesEnded: Bool = true
    ) {
        self._native = UIPinchGestureRecognizer()
        self._native.isEnabled = isEnabled
        self._native.cancelsTouchesInView = cancelsTouchesInView
        self._native.delaysTouchesBegan = delaysTouchesBegan
        self._native.delaysTouchesEnded = delaysTouchesEnded
        super.init()
        self._native.delegate = self
        self._native.addTarget(self, action: #selector(self._handle))
    }
    
    @available(iOS 9.2, *)
    public init(
        isEnabled: Bool = true,
        cancelsTouchesInView: Bool = true,
        delaysTouchesBegan: Bool = false,
        delaysTouchesEnded: Bool = true,
        requiresExclusiveTouchType: Bool = true
    ) {
        self._native = UIPinchGestureRecognizer()
        self._native.isEnabled = isEnabled
        self._native.cancelsTouchesInView = cancelsTouchesInView
        self._native.delaysTouchesBegan = delaysTouchesBegan
        self._native.delaysTouchesEnded = delaysTouchesEnded
        self._native.requiresExclusiveTouchType = requiresExclusiveTouchType
        super.init()
        self._native.delegate = self
        self._native.addTarget(self, action: #selector(self._handle))
    }
    
    public func require(toFail gesture: QNativeGesture) {
        self.native.require(toFail: gesture)
    }
    
    public func velocity() -> Float {
        return Float(self._native.velocity)
    }
    
    public func scale() -> Float {
        return Float(self._native.scale)
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
    public func onBegin(_ value: (() -> Void)?) -> Self {
        self._onBegin = value
        return self
    }
    
    @discardableResult
    public func onChange(_ value: (() -> Void)?) -> Self {
        self._onChange = value
        return self
    }
    
    @discardableResult
    public func onCancel(_ value: (() -> Void)?) -> Self {
        self._onCancel = value
        return self
    }
    
    @discardableResult
    public func onEnd(_ value: (() -> Void)?) -> Self {
        self._onEnd = value
        return self
    }

}

private extension QPinchGesture {
    
    @objc
    func _handle() {
        switch self._native.state {
        case .possible: break
        case .began: self._onBegin?()
        case .changed: self._onChange?()
        case .cancelled: self._onCancel?()
        case .ended, .failed: self._onEnd?()
        @unknown default: break
        }
    }
    
}

extension QPinchGesture : UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIControl {
            return false
        }
        return true
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self._onShouldBegin?() ?? true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return self._onShouldSimultaneously?(otherGestureRecognizer) ?? false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let onShouldRequireFailure = self._onShouldRequireFailure {
            return onShouldRequireFailure(otherGestureRecognizer)
        }
        if let view = gestureRecognizer.view, let otherView = otherGestureRecognizer.view {
            return otherView.isDescendant(of: view)
        }
        return false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if let onShouldBeRequiredToFailBy = self._onShouldBeRequiredToFailBy {
            return onShouldBeRequiredToFailBy(otherGestureRecognizer)
        }
        if let view = gestureRecognizer.view, let otherView = otherGestureRecognizer.view {
            return view.isDescendant(of: otherView)
        }
        return false
    }
    
}

#endif
