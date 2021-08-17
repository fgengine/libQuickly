//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyObserver

public protocol IQAppStateObserver : AnyObject {
    
    func didBecomeActive(_ appState: QAppState)
    func didResignActive(_ appState: QAppState)
    func didEnterForeground(_ appState: QAppState)
    func didEnterBackground(_ appState: QAppState)
    func didMemoryWarning(_ appState: QAppState)
    
}

public extension IQAppStateObserver {
    
    func didBecomeActive(_ appState: QAppState) {
    }
    
    func didResignActive(_ appState: QAppState) {
    }
    
    func didEnterForeground(_ appState: QAppState) {
    }
    
    func didEnterBackground(_ appState: QAppState) {
    }
    
    func didMemoryWarning(_ appState: QAppState) {
    }
    
}

public class QAppState {
    
    private var _active: Bool?
    private let _observer: QObserver< IQAppStateObserver >
    
    private var _becomeActiveObserver: NSObjectProtocol?
    private var _resignActiveObserver: NSObjectProtocol?
    private var _enterForegroundObserver: NSObjectProtocol?
    private var _enterBackgroundObserver: NSObjectProtocol?
    private var _memoryWarningObserver: NSObjectProtocol?
    
    public init() {
        self._observer = QObserver()
        #if os(iOS)
        self._becomeActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { [unowned self] in self._didBecomeActive($0) }
        )
        self._resignActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { [unowned self] in self._didResignActive($0) }
        )
        self._enterForegroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { [unowned self] in self._didEnterForeground($0) }
        )
        self._enterBackgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { [unowned self] in self._didEnterBackground($0) }
        )
        self._memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { [unowned self] in self._didMemoryWarning($0) }
        )
        #endif
    }
    
    deinit {
        if let observer = self._becomeActiveObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self._resignActiveObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self._enterForegroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self._enterBackgroundObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self._memoryWarningObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    public func add(observer: IQAppStateObserver, priority: QObserverPriority) {
        self._observer.add(observer, priority: priority)
    }
    
    public func remove(observer: IQAppStateObserver) {
        self._observer.remove(observer)
    }
    
}

public extension QAppState {
    
    func _didBecomeActive(_ notification: Notification) {
        guard self._active == false else { return }
        self._active = true
        self._observer.notify({ $0.didBecomeActive(self) })
    }
    
    func _didResignActive(_ notification: Notification) {
        self._active = false
        self._observer.notify({ $0.didResignActive(self) })
    }
    
    func _didEnterForeground(_ notification: Notification) {
        self._observer.notify({ $0.didEnterForeground(self) })
    }
    
    func _didEnterBackground(_ notification: Notification) {
        self._observer.notify({ $0.didEnterBackground(self) })
    }
    
    func _didMemoryWarning(_ notification: Notification) {
        self._observer.notify({ $0.didMemoryWarning(self) })
    }
    
}
