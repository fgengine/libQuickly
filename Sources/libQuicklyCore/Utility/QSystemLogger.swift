//
//  libQuicklyCore
//

import Foundation

public class QSystemLogger {
    
    private let _name: String
    
    public init(
        name: String
    ) {
        self._name = name
    }
    
}

extension QSystemLogger : IQLogger {
    
    public func send(category: String, text: String) {
        NSLog("[\(self._name)] [\(category)]: \(text)")
    }
    
}
