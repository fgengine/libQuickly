//
//  libQuicklyPermission
//

import Foundation
import AppTrackingTransparency
import libQuicklyObserver

public class QAppTrackingPermission : IQPermission {
    
    public var status: QPermissionStatus {
        if #available(iOS 14.5, *) {
            switch ATTrackingManager.trackingAuthorizationStatus {
            case .notDetermined: return .notDetermined
            case .restricted: return .authorized
            case .denied: return .denied
            case .authorized: return .authorized
            @unknown default: return .denied
            }
        } else {
            return .notSupported
        }
    }
    
    private var _observer: QObserver< IQPermissionObserver >
    
    public init() {
        self._observer = QObserver()
    }
    
    public func add(observer: IQPermissionObserver, priority: QObserverPriority) {
        self._observer.add(observer, priority: priority)
    }
    
    public func remove(observer: IQPermissionObserver) {
        self._observer.remove(observer)
    }
    
    public func request() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(
                completionHandler: { [weak self] status in
                    DispatchQueue.main.async(execute: {
                        self?._didRequest()
                    })
                }
            )
        }
    }
    
}

private extension QAppTrackingPermission {
    
    func _didRequest() {
        self._observer.notify({ $0.didReqiest(self) })
    }
    
}
