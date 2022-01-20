//
//  libQuicklyModule
//

import Foundation

public protocol IQModuleManager {
    
    var modules: [IQModule] { get }
    
}

public extension IQModuleManager {
    
    func callToAction() -> IQModuleCallToAction? {
        for module in self.modules {
            if let callToAction = module.activeCallToAction {
                return callToAction
            }
        }
        return nil
    }
    
    func showCallToActionIfNeeded() {
        guard let callToAction = self.callToAction() else { return }
        callToAction.show()
    }
    
}
