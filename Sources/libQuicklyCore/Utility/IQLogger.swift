//
//  libQuicklyCore
//

import Foundation

public protocol IQLogger : AnyObject {
    
    func send(category: String, text: String)
    
}

public extension IQLogger {
    
    func send< Sender : AnyObject >(module object: Sender, text: String) {
        self.send(category: String(describing: object), text: text)
    }
    
    func send< Sender : AnyObject >(class object: Sender, text: String) {
        self.send(category: String(describing: type(of: object)), text: text)
    }
    
}
