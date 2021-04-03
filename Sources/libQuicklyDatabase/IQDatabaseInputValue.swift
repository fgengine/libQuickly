//
//  libQuicklyDatabase
//

import Foundation
import libQuicklyCore

public protocol IQDatabaseInputValue {
    
    func bindTo(statement: QDatabase.Statement, at index: Int) throws
    
}

extension QDatabase.Statement {
    
    func bind< Type : Sequence >(_ bindables: Type) throws where Type.Iterator.Element == IQDatabaseInputValue {
        var index = 1
        for bindable in bindables {
            try bindable.bindTo(statement: self, at: index)
            index += 1
        }
    }
    
}

extension Bool : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try statement.bind(at: index, value: self)
    }
    
}

extension Int8 : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try statement.bind(at: index, value: Int64(self))
    }
    
}

extension UInt8 : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try statement.bind(at: index, value: Int64(self))
    }
    
}

extension Int16 : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try statement.bind(at: index, value: Int64(self))
    }
    
}

extension UInt16 : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try statement.bind(at: index, value: Int64(self))
    }
    
}

extension Int32 : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try statement.bind(at: index, value: Int64(self))
    }
    
}

extension UInt32 : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try statement.bind(at: index, value: Int64(self))
    }
    
}

extension Int64 : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try statement.bind(at: index, value: self)
    }
    
}

extension UInt64 : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try statement.bind(at: index, value: Int64(self))
    }
    
}

extension Int : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try statement.bind(at: index, value: Int64(self))
    }
    
}

extension UInt : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try statement.bind(at: index, value: Int64(self))
    }
    
}

extension Float : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try statement.bind(at: index, value: Double(self))
    }
    
}

extension Double : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try statement.bind(at: index, value: self)
    }
    
}

extension Decimal : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try statement.bind(at: index, value: self)
    }
    
}

extension String : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try statement.bind(at: index, value: self)
    }
    
}

extension URL : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try self.absoluteString.bindTo(statement: statement, at: index)
    }
    
}

extension Date : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try statement.bind(at: index, value: Double(self.timeIntervalSince1970))
    }
    
}

extension Data : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        try statement.bind(at: index, value: self)
    }
    
}

extension Optional : IQDatabaseInputValue where Wrapped : IQDatabaseInputValue {
    
    public func bindTo(statement: QDatabase.Statement, at index: Int) throws {
        switch self {
        case .none: try statement.bindNull(at: index)
        case .some(let wrapped): try wrapped.bindTo(statement: statement, at: index)
        }
    }
    
}
