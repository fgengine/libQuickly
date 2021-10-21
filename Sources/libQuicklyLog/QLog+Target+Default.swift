//
//  libQuicklyLog
//

import Foundation

public extension QLog.Target {
    
    class Default : IQLogTarget {
        
        public var enabled: Bool
        
        public init(
            enabled: Bool = true
        ) {
            self.enabled = enabled
        }
        
        public func log(level: QLog.Level, category: String, message: String) {
            guard self.enabled == true else { return }
            switch level {
            case .debug: print("[\(category)]: \(message)")
            case .info, .error: NSLog("[\(category)]: \(message)")
            }
        }
        
    }
    
}
