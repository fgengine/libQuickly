//
//  libQuicklyModule
//

import Foundation
import libQuicklyCore

public protocol IQModule : AnyObject {
    
    var features: [IQModuleFeature] { get }
    var callToActions: [IQModuleCallToAction] { get }
    
}

public extension IQModule {
    
    var activeCallToAction: IQModuleCallToAction? {
        return self._callToAction(self.callToActions)
    }
    
    func showCallToActionIfNeeded() {
        guard let callToAction = self.activeCallToAction else { return }
        callToAction.show()
    }
    
}

private extension IQModule {
    
    @inline(__always)
    func _callToAction(_ list: [IQModuleCallToAction]) -> IQModuleCallToAction? {
        for element in list {
            let dependency = self._callToAction(element.dependencies)
            if element.canShow == true {
                return dependency ?? element
            } else if let dependency = dependency {
                return dependency
            }
        }
        return nil
    }
    
}
