//
//  libQuicklyDatabase
//

import Foundation
import libQuicklyCore

public protocol IQDatabaseExpressable {
    
    func inputValues() -> [IQDatabaseInputValue]
    func queryExpression() -> String
    
}
