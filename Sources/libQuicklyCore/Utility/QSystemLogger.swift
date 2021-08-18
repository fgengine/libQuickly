//
//  libQuicklyCore
//

import Foundation
import os.log

public class QSystemLogger {
    
    public let name: String
    
    public init(
        name: String
    ) {
        self.name = name
    }
    
}

extension QSystemLogger : IQLogger {
    
    public func send(category: String, text: String) {
        if #available(iOS 10.0, *) {
            os_log("[%{public}s] [%{public}s]: %{public}s", self.name, category, text)
        } else {
            NSLog("[%s] [%s]: %s", self.name, category, text)
        }
    }
    
}
