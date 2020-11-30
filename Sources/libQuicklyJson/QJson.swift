//
//  libQuicklyJson
//

import Foundation
import libQuicklyCore

public enum QJsonError : Error {
    case notJson
    case access
    case cast
}

public final class QJson {

    public private(set) var root: Any?

    public init() {
    }

    public init(root: Any) {
        self.root = root
    }

    public init(data: Data) throws {
        self.root = try JSONSerialization.jsonObject(with: data, options: [])
    }

    public convenience init(string: String, encoding: String.Encoding = String.Encoding.utf8) throws {
        guard let data = string.data(using: String.Encoding.utf8) else {
            throw QJsonError.notJson
        }
        try self.init(data: data)
    }
    
}

public extension QJson {
    
    func isDictionary() -> Bool {
        return self.root is NSDictionary
    }
    
    func dictionary() throws -> NSDictionary {
        guard let dictionary = self.root as? NSDictionary else { throw QJsonError.notJson }
        return dictionary
    }
    
    func isArray() -> Bool {
        return self.root is NSArray
    }
    
    func array() throws -> NSArray {
        guard let array = self.root as? NSArray else { throw QJsonError.notJson }
        return array
    }
    
    func clean() {
        self.root = nil
    }

    func saveAsData() throws -> Data {
        guard let root = self.root else {
            throw QJsonError.notJson
        }
        return try JSONSerialization.data(withJSONObject: root, options: [])
    }

    func saveAsString(encoding: String.Encoding = String.Encoding.utf8) throws -> String? {
        return String(data: try self.saveAsData(), encoding: encoding)
    }

    func set< Value: IQJsonValueEncodable >(value: Value, path: String? = nil) throws {
        try self._set(value: try value.toJsonValue(), path: path)
    }
    
    func set< Value: IQJsonEnumEncodable >(value: Value.RealValue, enum: Value.Type, path: String? = nil) throws where Value.RawValue: IQJsonValueEncodable {
        try self.set(value: Value(realValue: value).rawValue, path: path)
    }

    func set< Value: IQJsonValueEncodable >(value: [Value], mandatory: Bool, path: String? = nil) throws {
        var index: Int = 0
        let jsonArray = NSMutableArray()
        for item in value {
            if mandatory == true {
                let jsonItem = try item.toJsonValue()
                jsonArray.add(jsonItem)
            } else {
                if let jsonItem = try? item.toJsonValue() {
                    jsonArray.add(jsonItem)
                }
            }
            index += 1
        }
        try self._set(value: jsonArray, path: path)
    }
    
    func set< Value: IQJsonEnumEncodable >(value: [Value.RealValue], enum: Value.Type, mandatory: Bool, path: String? = nil) throws where Value.RawValue: IQJsonValueEncodable {
        let normalized = value.compactMap({ return Value(realValue: $0).rawValue })
        try self.set(value: normalized, mandatory: mandatory, path: path)
    }

    func set< Key: IQJsonValueEncodable, Value: IQJsonValueEncodable >(value: [Key: Value], mandatory: Bool, path: String? = nil) throws {
        var index: Int = 0
        let jsonDictionary = NSMutableDictionary()
        for item in value {
            guard let jsonKey = try item.key.toJsonValue() as? NSCopying else { throw QJsonError.cast }
            if mandatory == true {
                let jsonValue = try item.value.toJsonValue()
                jsonDictionary.setObject(jsonValue, forKey: jsonKey)
            } else {
                if let jsonValue = try? item.value.toJsonValue() {
                    jsonDictionary.setObject(jsonValue, forKey: jsonKey)
                }
            }
            index += 1
        }
        try self._set(value: jsonDictionary, path: path)
    }
    
    func set< Key: IQJsonEnumEncodable, Value: IQJsonValueEncodable >(value: [Key.RealValue: Value], keyEnum: Key.Type, mandatory: Bool, path: String? = nil) throws where Key.RawValue: IQJsonValueEncodable & Hashable {
        var normalized: [Key.RawValue: Value] = [:]
        for item in value {
            normalized[Key(realValue: item.key).rawValue] = item.value
        }
        try self.set(value: normalized, mandatory: mandatory, path: path)
    }
    
    func set< Key: IQJsonValueEncodable, Value: IQJsonEnumEncodable >(value: [Key: Value.RealValue], valueEnum: Value.Type, mandatory: Bool, path: String? = nil) throws where Value.RawValue: IQJsonValueEncodable {
        var normalized: [Key: Value.RawValue] = [:]
        for item in value {
            normalized[item.key] = Value(realValue: item.value).rawValue
        }
        try self.set(value: normalized, mandatory: mandatory, path: path)
    }
    
    func set< Key: IQJsonEnumEncodable, Value: IQJsonEnumEncodable >(value: [Key.RealValue: Value.RealValue], keyEnum: Key.Type, valueEnum: Value.Type, mandatory: Bool, path: String? = nil) throws where Key.RawValue: IQJsonValueEncodable & Hashable, Value.RawValue: IQJsonValueEncodable {
        var normalized: [Key.RawValue: Value.RawValue] = [:]
        for item in value {
            normalized[Key(realValue: item.key).rawValue] = Value(realValue: item.value).rawValue
        }
        try self.set(value: normalized, mandatory: mandatory, path: path)
    }
    
    func set(value: Date, format: String, path: String? = nil) throws {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        try self.set(value: value, formatter: formatter, path: path)
    }
    
    func set(value: Date, formatter: DateFormatter, path: String? = nil) throws {
        try self.set(value: formatter.string(from: value), path: path)
    }

    func remove(path: String) throws {
        try self._set(value: nil, subpaths: self._subpaths(path))
    }

    func get< Value: IQJsonValueDecodable >(path: String? = nil) throws -> Value {
        let jsonValue: Any = try self._get(path: path)
        return try Value.fromJson(value: jsonValue) as! Value
    }
    
    func get< Value: IQJsonEnumDecodable >(enum: Value.Type, path: String? = nil) throws -> Value.RealValue where Value.RawValue: IQJsonValueDecodable {
        let jsonValue: Any = try self._get(path: path)
        let rawValue = try Value.RawValue.fromJson(value: jsonValue) as! Value.RawValue
        guard let result = Value(rawValue: rawValue) else { throw QJsonError.cast }
        return result.realValue
    }

    func get< Value: IQJsonValueDecodable >(mandatory: Bool, path: String? = nil) throws -> [Value] {
        let jsonValue: Any = try self._get(path: path)
        guard let jsonArray = jsonValue as? NSArray else { throw QJsonError.cast }
        var result: [Value] = []
        var index: Int = 0
        for jsonItem in jsonArray {
            if mandatory == true {
                let item = try Value.fromJson(value: jsonItem) as! Value
                result.append(item)
            } else {
                guard let item = try? Value.fromJson(value: jsonItem) as? Value else { continue }
                result.append(item)
            }
            index += 1
        }
        return result
    }
    
    func get< Value: IQJsonEnumDecodable >(enum: Value.Type, mandatory: Bool, path: String? = nil) throws -> [Value.RealValue] where Value.RawValue: IQJsonValueDecodable {
        let jsonValue: Any = try self._get(path: path)
        guard let jsonArray = jsonValue as? NSArray else { throw QJsonError.cast }
        var result: [Value.RealValue] = []
        var index: Int = 0
        for jsonItem in jsonArray {
            if mandatory == true {
                let rawItem = try Value.RawValue.fromJson(value: jsonItem) as! Value.RawValue
                guard let item = Value(rawValue: rawItem) else { throw QJsonError.cast }
                result.append(item.realValue)
            } else {
                guard let rawItem = try? Value.RawValue.fromJson(value: jsonItem) as? Value.RawValue, let item = Value(rawValue: rawItem) else { continue }
                result.append(item.realValue)
            }
            index += 1
        }
        return result
    }

    func get< Key: IQJsonValueDecodable, Value: IQJsonValueDecodable >(mandatory: Bool, path: String? = nil) throws -> [Key : Value] {
        let jsonValue: Any = try self._get(path: path)
        guard let jsonDictionary = jsonValue as? NSDictionary else { throw QJsonError.cast }
        var result: [Key : Value] = [:]
        for jsonItem in jsonDictionary {
            let key = try Key.fromJson(value: jsonItem.key) as! Key
            if mandatory == true {
                let value = try Value.fromJson(value: jsonItem.value) as! Value
                result[key] = value
            } else {
                guard let value = try? Value.fromJson(value: jsonItem.value) as? Value else { continue }
                result[key] = value
            }
        }
        return result
    }
    
    func get< Key: IQJsonEnumDecodable, Value: IQJsonValueDecodable >(keyEnum: Key.Type, mandatory: Bool, path: String? = nil) throws -> [Key.RealValue : Value] where Key.RawValue: IQJsonValueDecodable {
        let jsonValue: Any = try self._get(path: path)
        guard let jsonDictionary = jsonValue as? NSDictionary else { throw QJsonError.cast }
        var result: [Key.RealValue : Value] = [:]
        for jsonItem in jsonDictionary {
            let keyRaw = try Key.RawValue.fromJson(value: jsonItem.key) as! Key.RawValue
            if mandatory == true {
                guard let key = Key(rawValue: keyRaw) else { throw QJsonError.cast }
                let value = try Value.fromJson(value: jsonItem.value) as! Value
                result[key.realValue] = value
            } else if let key = Key(rawValue: keyRaw) {
                guard let value = try? Value.fromJson(value: jsonItem.value) as? Value else { continue }
                result[key.realValue] = value
            } else {
                throw QJsonError.cast
            }
        }
        return result
    }
    
    func get< Key: IQJsonValueDecodable, Value: IQJsonEnumDecodable >(valueEnum: Value.Type, mandatory: Bool, path: String? = nil) throws -> [Key : Value.RealValue] where Value.RawValue: IQJsonValueDecodable {
        let jsonValue: Any = try self._get(path: path)
        guard let jsonDictionary = jsonValue as? NSDictionary else { throw QJsonError.cast }
        var result: [Key : Value.RealValue] = [:]
        for jsonItem in jsonDictionary {
            let key = try Key.fromJson(value: jsonItem.key) as! Key
            if mandatory == true {
                let valueRaw = try Value.RawValue.fromJson(value: jsonItem.value) as! Value.RawValue
                guard let value = Value(rawValue: valueRaw) else { throw QJsonError.cast }
                result[key] = value.realValue
            } else {
                guard let valueRaw = try? Value.RawValue.fromJson(value: jsonItem.value) as? Value.RawValue, let value = Value(rawValue: valueRaw) else { continue }
                result[key] = value.realValue
            }
        }
        return result
    }
    
    func get< Key: IQJsonEnumDecodable, Value: IQJsonEnumDecodable >(keyEnum: Key.Type, valueEnum: Value.Type, mandatory: Bool, path: String? = nil) throws -> [Key.RealValue : Value.RealValue] where Key.RawValue: IQJsonValueDecodable, Value.RawValue: IQJsonValueDecodable {
        let jsonValue: Any = try self._get(path: path)
        guard let jsonDictionary = jsonValue as? NSDictionary else { throw QJsonError.cast }
        var result: [Key.RealValue : Value.RealValue] = [:]
        for jsonItem in jsonDictionary {
            let keyRaw = try Key.RawValue.fromJson(value: jsonItem.key) as! Key.RawValue
            if mandatory == true {
                guard let key = Key(rawValue: keyRaw) else { throw QJsonError.cast }
                let valueRaw = try Value.RawValue.fromJson(value: jsonItem.value) as! Value.RawValue
                guard let value = Value(rawValue: valueRaw) else { throw QJsonError.cast }
                result[key.realValue] = value.realValue
            } else if let key = Key(rawValue: keyRaw) {
                guard let valueRaw = try? Value.RawValue.fromJson(value: jsonItem.value) as? Value.RawValue, let value = Value(rawValue: valueRaw) else { continue }
                result[key.realValue] = value.realValue
            } else {
                throw QJsonError.cast
            }
        }
        return result
    }
    
    func get(format: String, path: String? = nil) throws -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return try self.get(formatter: formatter, path: path)
    }
    
    func get(formatter: DateFormatter, path: String? = nil) throws -> Date {
        let string: String = try self.get(path: path)
        guard let date = formatter.date(from: string) else { throw QJsonError.cast }
        return date
    }
    
}

// MARK: QJson • Private

private extension QJson {
    
    func _set(value: Any, path: String? = nil) throws {
        if let path = path {
            try self._set(value: value, subpaths: self._subpaths(path))
        } else {
            self.root = value
        }
    }

    func _set(value: Any?, subpaths: [IQJsonPath]) throws {
        if self.root == nil {
            if let subpath = subpaths.first {
                if subpath.jsonPathKey != nil {
                    self.root = NSMutableDictionary()
                } else if subpath.jsonPathIndex != nil {
                    self.root = NSMutableArray()
                } else {
                    throw QJsonError.access
                }
            } else {
                throw QJsonError.access
            }
        }
        var root: Any = self.root!
        var prevRoot: Any?
        var subpathIndex: Int = 0
        while subpaths.endIndex != subpathIndex {
            let subpath = subpaths[subpathIndex]
            if let key = subpath.jsonPathKey {
                var mutable: NSMutableDictionary
                if root is NSMutableDictionary {
                    mutable = root as! NSMutableDictionary
                } else if root is NSDictionary {
                    mutable = NSMutableDictionary(dictionary: root as! NSDictionary)
                    if let prevRoot = prevRoot {
                        let prevSubpath = subpaths[subpathIndex - 1]
                        if let prevDictionary = prevRoot as? NSMutableDictionary {
                            prevDictionary.setValue(mutable, forKey: prevSubpath.jsonPathKey!)
                        } else if let prevArray = prevRoot as? NSMutableArray {
                            prevArray.insert(mutable, at: prevSubpath.jsonPathIndex!)
                        }
                    }
                    root = mutable
                } else {
                    throw QJsonError.access
                }
                if subpathIndex == subpaths.endIndex - 1 {
                    if let value = value {
                        mutable[key] = value
                    } else {
                        mutable.removeObject(forKey: key)
                    }
                } else if let nextRoot = mutable[key] {
                    root = nextRoot
                } else {
                    let nextSubpath = subpaths[subpathIndex + 1]
                    if nextSubpath.jsonPathKey != nil {
                        let nextRoot = NSMutableDictionary()
                        mutable[key] = nextRoot
                        root = nextRoot
                    } else if nextSubpath.jsonPathIndex != nil {
                        let nextRoot = NSMutableArray()
                        mutable[key] = nextRoot
                        root = nextRoot
                    } else {
                        throw QJsonError.access
                    }
                }
            } else if let index = subpath.jsonPathIndex {
                var mutable: NSMutableArray
                if root is NSMutableArray {
                    mutable = root as! NSMutableArray
                } else if root is NSArray {
                    mutable = NSMutableArray(array: root as! NSArray)
                    if let prevRoot = prevRoot {
                        let prevSubpath = subpaths[subpathIndex - 1]
                        if let prevDictionary = prevRoot as? NSMutableDictionary {
                            prevDictionary.setValue(mutable, forKey: prevSubpath.jsonPathKey!)
                        } else if let prevArray = prevRoot as? NSMutableArray {
                            prevArray.insert(mutable, at: prevSubpath.jsonPathIndex!)
                        }
                    }
                    root = mutable
                } else {
                    throw QJsonError.access
                }
                if subpathIndex == subpaths.endIndex - 1 {
                    if let value = value {
                        mutable.insert(value, at: index)
                    } else {
                        mutable.removeObject(at: index)
                    }
                } else if index < mutable.count {
                    root = mutable[index]
                } else {
                    let nextSubpath = subpaths[subpathIndex + 1]
                    if nextSubpath.jsonPathKey != nil {
                        let nextRoot = NSMutableDictionary()
                        mutable[index] = nextRoot
                        root = nextRoot
                    } else if nextSubpath.jsonPathIndex != nil {
                        let nextRoot = NSMutableArray()
                        mutable[index] = nextRoot
                        root = nextRoot
                    } else {
                        throw QJsonError.access
                    }
                }
            } else {
                throw QJsonError.access
            }
            subpathIndex += 1
            prevRoot = root
        }
    }
    
    func _get(path: String? = nil) throws -> Any {
        guard var root = self.root else { throw QJsonError.notJson }
        guard let path = path else { return root }
        var subpathIndex: Int = 0
        let subpaths = self._subpaths(path)
        while subpaths.endIndex != subpathIndex {
            let subpath = subpaths[subpathIndex]
            if let dictionary = root as? NSDictionary {
                guard let key = subpath.jsonPathKey else {
                    throw QJsonError.access
                }
                guard let temp = dictionary.object(forKey: key) else {
                    throw QJsonError.access
                }
                root = temp
            } else if let array = root as? NSArray {
                guard let index = subpath.jsonPathIndex, index < array.count else { throw QJsonError.access }
                root = array.object(at: index)
            } else {
                throw QJsonError.access
            }
            subpathIndex += 1
        }
        return root
    }
    
    func _subpaths(_ path: String) -> [IQJsonPath] {
        guard path.contains(Const.pathSeparator) == true else { return [ path ] }
        let components = path.components(separatedBy: Const.pathSeparator)
        return components.compactMap({ (subpath: String) -> IQJsonPath? in
            guard let match = Const.pathIndexPattern.firstMatch(in: subpath, options: [], range: NSRange(location: 0, length: subpath.count)) else { return subpath }
            if((match.range.location != NSNotFound) && (match.range.length > 0)) {
                let startIndex = subpath.index(subpath.startIndex, offsetBy: 1)
                let endIndex = subpath.index(subpath.endIndex, offsetBy: -1)
                let indexString = String(subpath[startIndex..<endIndex])
                return NSNumber.number(from: indexString)
            }
            return subpath
        })
    }

    struct Const {
        public static var pathSeparator = "."
        public static var pathIndexPattern = try! NSRegularExpression(pattern: "^\\[\\d+\\]$", options: [ .anchorsMatchLines ])
    }

}

// MARK: IQDebug

#if DEBUG

extension QJson : IQDebug {

    public func debugString(_ buffer: inout String, _ headerIndent: Int, _ indent: Int, _ footerIndent: Int) {
        if self.isArray() == true {
            let array = try! self.array()
            array.debugString(&buffer, headerIndent, indent, footerIndent)
        } else if self.isDictionary() == true {
            let dictionary = try! self.dictionary()
            dictionary.debugString(&buffer, headerIndent, indent, footerIndent)
        } else {
            if headerIndent > 0 {
                buffer.append(String(repeating: "\t", count: headerIndent))
            }
            buffer.append("<QJson>")
        }
    }

}

#endif

// MARK: IQJsonPath

protocol IQJsonPath {

    var jsonPathKey: String? { get }
    var jsonPathIndex: Int? { get }

}

// MARK: String : IQJsonPath

extension String : IQJsonPath {

    var jsonPathKey: String? {
        get { return self }
    }
    var jsonPathIndex: Int? {
        get { return nil }
    }

}

// MARK: NSNumber : IQJsonPath

extension NSNumber : IQJsonPath {

    var jsonPathKey: String? {
        get { return nil }
    }
    var jsonPathIndex: Int? {
        get { return self.intValue }
    }

}
