//
//  libQuicklyModule
//

import Foundation

public class QModuleManager : IQModuleManager {
    
    public var modules: [IQModule]
    
    public init() {
        self.modules = []
    }
    
    public func register(module: IQModule) {
        guard self.modules.contains(where: { $0 === module }) else { return }
        self.modules.append(module)
    }
    
    public func unregister(module: IQModule) {
        guard let index = self.modules.firstIndex(where: { $0 === module }) else { return }
        self.modules.remove(at: index)
    }
    
}
