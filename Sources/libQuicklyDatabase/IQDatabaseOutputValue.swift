//
//  libQuicklyDatabase
//

import Foundation
import libQuicklyCore

public protocol IQDatabaseOutputValue {
    
    static func value(statement: QDatabase.Statement, at index: Int) throws -> Self
    
}

extension Bool : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> Bool {
        return statement.value(at: index)
    }
    
}

extension Int8 : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> Int8 {
        return Int8(statement.value(at: index) as Int64)
    }
    
}

extension UInt8 : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> UInt8 {
        return UInt8(statement.value(at: index) as Int64)
    }
    
}

extension Int16 : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> Int16 {
        return Int16(statement.value(at: index) as Int64)
    }
    
}

extension UInt16 : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> UInt16 {
        return UInt16(statement.value(at: index) as Int64)
    }
    
}

extension Int32 : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> Int32 {
        return Int32(statement.value(at: index) as Int64)
    }
    
}

extension UInt32 : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> UInt32 {
        return UInt32(statement.value(at: index) as Int64)
    }
    
}

extension Int64 : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> Int64 {
        return statement.value(at: index)
    }
    
}

extension UInt64 : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> UInt64 {
        return UInt64(statement.value(at: index) as Int64)
    }
    
}

extension Int : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> Int {
        return Int(statement.value(at: index) as Int64)
    }
    
}

extension UInt : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> UInt {
        return UInt(statement.value(at: index) as Int64)
    }
    
}

extension Float : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> Float {
        return Float(statement.value(at: index) as Double)
    }
    
}

extension Double : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> Double {
        return statement.value(at: index)
    }
    
}

extension Decimal : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> Decimal {
        return statement.value(at: index)
    }
    
}

extension String : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> String {
        return statement.value(at: index)
    }
    
}

extension URL : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> URL {
        let string = statement.value(at: index) as String
        guard let url = URL(string: string) else {
            throw QDatabase.Statement.Error.cast(index: index)
        }
        return url
    }
    
}

extension Date : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> Date {
        return Date(timeIntervalSince1970: TimeInterval(statement.value(at: index) as Double))
    }
    
}

extension Data : IQDatabaseOutputValue {
    
    public static func value(statement: QDatabase.Statement, at index: Int) throws -> Data {
        return statement.value(at: index)
    }
    
}
