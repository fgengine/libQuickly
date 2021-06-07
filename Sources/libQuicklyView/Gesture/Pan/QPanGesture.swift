//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

public final class QPanGesture : NSObject, IQPanGesture {
    
    public var native: QNativeGesture {
        return self._native
    }
    public private(set) var isEnabled: Bool {
        set(value) { self._native.isEnabled = value }
        get { return self._native.isEnabled }
    }
    
    private var _native: UIPanGestureRecognizer
    private var _onShouldBegin: (() -> Bool)?
    private var _onShouldSimultaneously: ((_ otherGesture: QNativeGesture) -> Bool)?
    private var _onShouldRequireFailure: ((_ otherGesture: QNativeGesture) -> Bool)?
    private var _onShouldBeRequiredToFailBy: ((_ otherGesture: QNativeGesture) -> Bool)?
    private var _onBegin: (() -> Void)?
    private var _onChange: (() -> Void)?
    private var _onCancel: (() -> Void)?
    private var _onEnd: (() -> Void)?
    
    public override init(
    ) {
        let native = UIPanGestureRecognizer()
        self._native = native
        super.init()
        self._native.delegate = self
        self._native.addTarget(self, action: #selector(self._handle))
    }
    
    public init(
        screenEdge: ScreenEdge
    ) {
        let native = UIScreenEdgePanGestureRecognizer()
        switch screenEdge {
        case .top: native.edges = [ .top ]
        case .left: native.edges = [ .left ]
        case .right: native.edges = [ .right ]
        case .bottom: native.edges = [ .bottom ]
        }
        self._native = native
        super.init()
        self._native.delegate = self
        self._native.addTarget(self, action: #selector(self._handle))
    }
    
    public func require(toFail gesture: QNativeGesture) {
        self.native.require(toFail: gesture)
    }
    
    public func translation(in view: IQView) -> QPoint {
        return QPoint(self._native.translation(in: view.native))
    }
    
    public func velocity(in view: IQView) -> QPoint {
        return QPoint(self._native.velocity(in: view.native))
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

public extension QPanGesture {
    
    enum ScreenEdge {
        case top
        case left
        case right
        case bottom
    }
    
}

private extension QPanGesture {
    
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

extension QPanGesture : UIGestureRecognizerDelegate {
    
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
