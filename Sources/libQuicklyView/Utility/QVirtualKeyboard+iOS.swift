//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore
import libQuicklyObserver

public protocol IQVirtualKeyboardObserver {

    func willShow(virtualKeyboard: QVirtualKeyboard, info: QVirtualKeyboard.Info)
    func didShow(virtualKeyboard: QVirtualKeyboard, info: QVirtualKeyboard.Info)

    func willHide(virtualKeyboard: QVirtualKeyboard, info: QVirtualKeyboard.Info)
    func didHide(virtualKeyboard: QVirtualKeyboard, info: QVirtualKeyboard.Info)

}

public final class QVirtualKeyboard {

    private var _observer: QObserver< IQVirtualKeyboardObserver >

    public init() {
        self._observer = QObserver< IQVirtualKeyboardObserver >()
        NotificationCenter.default.addObserver(self, selector: #selector(self._willShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self._didShow(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self._willHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self._didHide(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }

    public func add(observer: IQVirtualKeyboardObserver, priority: QObserverPriority) {
        self._observer.add(observer, priority: priority)
    }

    public func remove(observer: IQVirtualKeyboardObserver) {
        self._observer.remove(observer)
    }
    
}

public extension QVirtualKeyboard {
    
    struct Info {

        public let beginFrame: QRect
        public let endFrame: QRect
        public let duration: TimeInterval

        init?(_ userInfo: [ AnyHashable: Any ]) {
            guard let beginFrameValue = userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue else { return nil }
            guard let endFrameValue = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return nil }
            guard let durationValue = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else { return nil }
            self.beginFrame = QRect(beginFrameValue.cgRectValue)
            self.endFrame = QRect(endFrameValue.cgRectValue)
            self.duration = TimeInterval(durationValue.doubleValue)
        }

    }

}

extension QVirtualKeyboard {
    
    @objc
    private func _willShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let info = Info(userInfo) else { return }
        self._observer.notify({ $0.willShow(virtualKeyboard: self, info: info) })
    }

    @objc
    private func _didShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let info = Info(userInfo) else { return }
        self._observer.notify({ $0.didShow(virtualKeyboard: self, info: info) })
    }

    @objc
    private func _willHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let info = Info(userInfo) else { return }
        self._observer.notify({ $0.willHide(virtualKeyboard: self, info: info) })
    }

    @objc
    private func _didHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let info = Info(userInfo) else { return }
        self._observer.notify({ $0.didHide(virtualKeyboard: self, info: info) })
    }

}

#endif
