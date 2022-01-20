//
//  libQuicklyModule
//

import Foundation
import libQuicklyCore
import libQuicklyPermission

public class QModulePermissionCondition : IQModuleCondition {
    
    public var state: Bool {
        return self._states.contains(self._permission.status)
    }
    
    private var _permission: IQPermission
    private var _states: [QPermissionStatus]
    
    public init(_ permission: IQPermission, states: [QPermissionStatus]) {
        self._permission = permission
        self._states = states
    }
    
}
