//
//  libQuicklyDatabase
//

import Foundation
import libQuicklyCore

public extension QDatabase {
    
    struct LiteralExpression : IQDatabaseExpressable {
        
        public let value: IQDatabaseInputValue
        
        public init(_ value: IQDatabaseInputValue) {
            self.value = value
        }
        
        public func inputValues() -> [IQDatabaseInputValue] {
            return [ self.value ]
        }
        
        public func queryExpression() -> String {
            return "?"
        }
        
    }
    
}
