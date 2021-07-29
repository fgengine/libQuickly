//
//  libQuicklyPermission
//

import Foundation

public enum QPermissionStatus {
    case notSupported
    case notDetermined
    case authorized
    case denied
}

public protocol IQPermission : AnyObject {
    
    var status: QPermissionStatus { get }
    
    func add(observer: IQPermissionObserver)
    func remove(observer: IQPermissionObserver)
    
    func request()
    
}

public protocol IQPermissionObserver : AnyObject {
    
    func didReqiest(_ permission: IQPermission)
    
}
