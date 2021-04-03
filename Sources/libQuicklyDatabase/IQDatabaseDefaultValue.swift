//
//  libQuicklyDatabase
//

import Foundation
import libQuicklyCore

public protocol IQDatabaseDefaultValue {
    
    func queryDefaultValue() -> String
    
}

public extension QDatabase {
    
    struct DefaultValueEmptyData : IQDatabaseDefaultValue {
        
        public func queryDefaultValue() -> String {
            return "EMPTY_BLOB()"
        }
        
    }
    
}

extension Bool : IQDatabaseDefaultValue {
    
    public func queryDefaultValue() -> String {
        return (self == true) ? "1" : "0"
    }
    
}

extension Int8 : IQDatabaseDefaultValue {
    
    public func queryDefaultValue() -> String {
        return "\(self)"
    }
    
}

extension UInt8 : IQDatabaseDefaultValue {
    
    public func queryDefaultValue() -> String {
        return "\(self)"
    }
    
}

extension Int16 : IQDatabaseDefaultValue {
    
    public func queryDefaultValue() -> String {
        return "\(self)"
    }
    
}

extension UInt16 : IQDatabaseDefaultValue {
    
    public func queryDefaultValue() -> String {
        return "\(self)"
    }
    
}

extension Int32 : IQDatabaseDefaultValue {
    
    public func queryDefaultValue() -> String {
        return "\(self)"
    }
    
}

extension UInt32 : IQDatabaseDefaultValue {
    
    public func queryDefaultValue() -> String {
        return "\(self)"
    }
    
}

extension Int64 : IQDatabaseDefaultValue {
    
    public func queryDefaultValue() -> String {
        return "\(self)"
    }
    
}

extension UInt64 : IQDatabaseDefaultValue {
    
    public func queryDefaultValue() -> String {
        return "\(self)"
    }
    
}

extension Int : IQDatabaseDefaultValue {
    
    public func queryDefaultValue() -> String {
        return "\(self)"
    }
    
}

extension UInt : IQDatabaseDefaultValue {
    
    public func queryDefaultValue() -> String {
        return "\(self)"
    }
    
}

extension Float : IQDatabaseDefaultValue {
    
    public func queryDefaultValue() -> String {
        return "\(self)"
    }
    
}

extension Double : IQDatabaseDefaultValue {
    
    public func queryDefaultValue() -> String {
        return "\(self)"
    }
    
}

extension String : IQDatabaseDefaultValue {
    
    public func queryDefaultValue() -> String {
        return "\"\(self)\""
    }
    
}

extension URL : IQDatabaseDefaultValue {
    
    public func queryDefaultValue() -> String {
        return self.absoluteString.queryDefaultValue()
    }
    
}

extension Date : IQDatabaseDefaultValue {
    
    public func queryDefaultValue() -> String {
        return "\"\(Int64(self.timeIntervalSince1970))\""
    }
    
}
