//
//  libQuicklyLog
//

import Foundation

public protocol IQLogTarget : AnyObject {
    
    var enabled: Bool { set get }
    
    func log(level: QLog.Level, category: String, message: String)
    
}
