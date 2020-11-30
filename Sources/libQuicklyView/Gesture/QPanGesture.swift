//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

public class QPanGesture : NSObject, IQGesture {
    
    public typealias ShouldClosure = (_ panGesture: QPanGesture) -> Bool
    public typealias CompareClosure = (_ panGesture: QPanGesture, _ otherGesture: IQGesture) -> Bool
    public typealias Closure = (_ panGesture: QPanGesture) -> Void
    
    public var isEnabled: Bool {
        set(value) { self._native.isEnabled = value }
        get { return self._native.isEnabled }
    }
    public var native: QNativeGesture {
        return self._native
    }
    public var onShouldBegin: ShouldClosure?
    public var onShouldSimultaneously: CompareClosure?
    public var onShouldRequireFailure: CompareClosure?
    public var onShouldBeRequiredToFailBy: CompareClosure?
    public var onBegin: Closure?
    public var onChange: Closure?
    public var onCancel: Closure?
    public var onEnd: Closure?
    
    private var _native: UIPanGestureRecognizer!
    
    public init(
        onShouldBegin: ShouldClosure? = nil,
        onShouldSimultaneously: CompareClosure? = nil,
        onShouldRequireFailure: CompareClosure? = nil,
        onShouldBeRequiredToFailBy: CompareClosure? = nil,
        onBegin: Closure? = nil,
        onChange: Closure? = nil,
        onCancel: Closure? = nil,
        onEnd: Closure? = nil
    ) {
        self.onShouldBegin = onShouldBegin
        self.onShouldSimultaneously = onShouldSimultaneously
        self.onShouldRequireFailure = onShouldRequireFailure
        self.onShouldBeRequiredToFailBy = onShouldBeRequiredToFailBy
        self.onBegin = onBegin
        self.onChange = onChange
        self.onCancel = onCancel
        self.onEnd = onEnd
        super.init()
        self._native = UIPanGestureRecognizer()
        self._native.delegate = self
        self._native.addTarget(self, action: #selector(self._handle))
    }
    
    public func location(in view: IQView) -> QPoint {
        return QPoint(self._native.location(in: view.native))
    }
    
    public func velocity(in view: IQView) -> QPoint {
        return QPoint(self._native.velocity(in: view.native))
    }
    
}

private extension QPanGesture {
    
    @objc
    func _handle() {
        switch self._native.state {
        case .possible: break
        case .began: self.onBegin?(self)
        case .changed: self.onChange?(self)
        case .cancelled: self.onCancel?(self)
        case .ended, .failed: self.onEnd?(self)
        @unknown default: break
        }
    }
    
}

extension QPanGesture : UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.onShouldBegin?(self) ?? true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let otherGesture = otherGestureRecognizer.delegate as? IQGesture else { return false }
        return self.onShouldSimultaneously?(self, otherGesture) ?? false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let otherGesture = otherGestureRecognizer.delegate as? IQGesture else { return false }
        return self.onShouldRequireFailure?(self, otherGesture) ?? false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let otherGesture = otherGestureRecognizer.delegate as? IQGesture else { return false }
        return self.onShouldBeRequiredToFailBy?(self, otherGesture) ?? false
    }
    
}

#endif
