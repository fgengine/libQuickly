//
//  libQuicklyPermission
//

import Foundation
#if os(iOS)
import UIKit
#endif
import UserNotifications
import libQuicklyObserver

public class QNotificationPermission : IQPermission {
    
    public var status: QPermissionStatus {
        if #available(iOS 10.0, *) {
            switch self._rawStatus() {
            case .authorized: return .authorized
            case .denied: return .denied
            case .notDetermined: return .notDetermined
            case .provisional: return .authorized
            case .ephemeral: return .authorized
            @unknown default: return .denied
            }
        } else {
            #if os(iOS)
            if UIApplication.shared.isRegisteredForRemoteNotifications == true {
                return .authorized
            }
            return .denied
            #else
            return .notSupported
            #endif
        }
    }
    
    private var _observer: QObserver< IQPermissionObserver >
    
    public init() {
        self._observer = QObserver()
    }
    
    public func add(observer: IQPermissionObserver) {
        self._observer.add(observer, priority: 0)
    }
    
    public func remove(observer: IQPermissionObserver) {
        self._observer.remove(observer)
    }
    
    public func request() {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(
                options: [ .badge, .alert, .sound ],
                completionHandler: { settings, error in
                }
            )
        } else {
            #if os(iOS)
            UIApplication.shared.registerForRemoteNotifications()
            #endif
        }
    }
    
}

private extension QNotificationPermission {
    
    @available(iOS 10.0, *)
    func _rawStatus() -> UNAuthorizationStatus {
        var result: UNNotificationSettings?
        let semaphore = DispatchSemaphore(value: 0)
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { setttings in
            result = setttings
            semaphore.signal()
        })
        semaphore.wait()
        return result!.authorizationStatus
    }
    
    func _didRequest() {
        self._observer.notify({ $0.didReqiest(self) })
    }
    
}
