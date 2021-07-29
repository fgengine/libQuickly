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
    func didMemoryWarning(_ appState: QAppState)
    
}

public class QAppState {
    
    private let _observer: QObserver< IQAppStateObserver >
    
    private var _becomeActiveObserver: NSObjectProtocol?
    private var _resignActiveObserver: NSObjectProtocol?
    private var _memoryWarningObserver: NSObjectProtocol?
    
    public init() {
        self._observer = QObserver()
        #if os(iOS)
        self._becomeActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { self._didBecomeActive($0) }
        )
        self._resignActiveObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { self._didResignActive($0) }
        )
        self._memoryWarningObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveMemoryWarningNotification,
            object: nil,
            queue: OperationQueue.main,
            using: { self._didMemoryWarning($0) }
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
        if let observer = self._memoryWarningObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    public func add(observer: IQAppStateObserver) {
        self._observer.add(observer, priority: 0)
    }
    
    public func remove(observer: IQAppStateObserver) {
        self._observer.remove(observer)
    }
    
}

public extension QAppState {
    
    func _didBecomeActive(_ notification: Notification) {
        self._observer.notify({ $0.didBecomeActive(self) })
    }
    
    func _didResignActive(_ notification: Notification) {
        self._observer.notify({ $0.didResignActive(self) })
    }
    
    func _didMemoryWarning(_ notification: Notification) {
        self._observer.notify({ $0.didMemoryWarning(self) })
    }
    
}
