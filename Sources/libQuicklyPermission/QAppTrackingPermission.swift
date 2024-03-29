//
//  libQuicklyPermission
//

import Foundation
#if os(iOS)
import UIKit
#endif
import AppTrackingTransparency
import libQuicklyObserver

public class QAppTrackingPermission : IQPermission {
    
    public var status: QPermissionStatus {
        if #available(iOS 14.5, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .notDetermined: return .notDetermined
            case .restricted: return .denied
            case .denied: return .denied
            case .authorized: return .authorized
            @unknown default: return .denied
            }
        } else {
            return .notSupported
        }
    }
    
    private var _observer: QObserver< IQPermissionObserver >
    private var _resignSource: Any?
    private var _resignState: QPermissionStatus?
    #if os(iOS)
    private var _becomeActiveObserver: NSObjectProtocol?
    private var _resignActiveObserver: NSObjectProtocol?
    #endif
    
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
        #endif
    }
    
    deinit {
        #if os(iOS)
        if let observer = self._becomeActiveObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        if let observer = self._resignActiveObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        #endif
    }

    public func add(observer: IQPermissionObserver, priority: QObserverPriority) {
        self._observer.add(observer, priority: priority)
    }
    
    public func remove(observer: IQPermissionObserver) {
        self._observer.remove(observer)
    }
    
    public func request(source: Any) {
        if #available(iOS 14.5, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .notDetermined:
                self._willRequest(source: source)
                ATTrackingManager.requestTrackingAuthorization(
                    completionHandler: { [weak self] status in
                        DispatchQueue.main.async(execute: {
                            self?._didRequest(source: source)
                        })
                    }
                )
            case .denied:
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                if UIApplication.shared.canOpenURL(url) == true {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    self._resignSource = source
                    self._didRedirectToSettings(source: source)
                }
            default:
                break
            }
        }
    }
    
}

#if os(iOS)

private extension QAppTrackingPermission {
    
    func _didBecomeActive(_ notification: Notification) {
        guard let resignState = self._resignState else { return }
        if resignState != self.status {
            self._didRequest(source: self._resignSource)
        }
        self._resignSource = nil
        self._resignState = nil
    }
    
    func _didResignActive(_ notification: Notification) {
        switch self.status {
        case .authorized: self._resignState = .authorized
        case .denied: self._resignState = .denied
        default: self._resignState = nil
        }
    }
    
}

#endif

private extension QAppTrackingPermission {
    
    func _didRedirectToSettings(source: Any) {
        self._observer.notify({ $0.didRedirectToSettings(self, source: source) })
    }
    
    func _willRequest(source: Any?) {
        self._observer.notify({ $0.willRequest(self, source: source) })
    }
    
    func _didRequest(source: Any?) {
        self._observer.notify({ $0.didRequest(self, source: source) })
    }
    
}
