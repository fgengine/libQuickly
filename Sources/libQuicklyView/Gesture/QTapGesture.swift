//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

public class QTapGesture : NSObject, IQGesture {
    
    public typealias ShouldClosure = (_ tapGesture: QTapGesture) -> Bool
    public typealias CompareClosure = (_ tapGesture: QTapGesture, _ otherGesture: IQGesture) -> Bool
    public typealias Closure = (_ tapGesture: QTapGesture) -> Void
    
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
    public var onTriggered: Closure?
    
    private var _native: UITapGestureRecognizer!
    
    public init(
        onShouldBegin: ShouldClosure? = nil,
        onShouldSimultaneously: CompareClosure? = nil,
        onShouldRequireFailure: CompareClosure? = nil,
        onShouldBeRequiredToFailBy: CompareClosure? = nil,
        onTriggered: Closure? = nil
    ) {
        self.onShouldBegin = onShouldBegin
        self.onShouldSimultaneously = onShouldSimultaneously
        self.onShouldRequireFailure = onShouldRequireFailure
        self.onShouldBeRequiredToFailBy = onShouldBeRequiredToFailBy
        self.onTriggered = onTriggered
        super.init()
        self._native = UITapGestureRecognizer()
        self._native.delegate = self
        self._native.addTarget(self, action: #selector(self._handle))
    }
    
    public func location(in view: IQView) -> QPoint {
        return QPoint(self._native.location(in: view.native))
    }
    
}

private extension QTapGesture {
    
    @objc
    func _handle() {
        self.onTriggered?(self)
    }
    
}

extension QTapGesture : UIGestureRecognizerDelegate {
    
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
