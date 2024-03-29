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

    public private(set) var root: IQJsonValue?

    public init() {
    }

    public init(root: IQJsonValue) {
        self.root = root
    }

    public init?(data: Data) {
        guard let root = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        self.root = (root as! IQJsonValue)
    }

    public init?(string: String, encoding: String.Encoding = String.Encoding.utf8) {
        guard let data = string.data(using: String.Encoding.utf8) else { return nil }
        guard let root = try? JSONSerialization.jsonObject(with: data, options: []) else { return nil }
        self.root = (root as! IQJsonValue)
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
    
}

public extension QJson {

    func saveAsData(options: JSONSerialization.WritingOptions = []) throws -> Data {
        guard let root = self.root else {
            throw QJsonError.notJson
        }
        return try JSONSerialization.data(withJSONObject: root, options: options)
    }

    func saveAsString(encoding: String.Encoding = String.Encoding.utf8, options: JSONSerialization.WritingOptions = []) throws -> String? {
        return String(data: try self.saveAsData(options: options), encoding: encoding)
    }
    
}

public extension QJson {
    
    func get() throws -> IQJsonValue {
        return try self._get(path: nil)
    }
    
    func get(path: String) throws -> IQJsonValue {
        return try self._get(path: path)
    }

    func set(value: IQJsonValue) throws {
        try self._set(value: value, path: nil)
    }
    
    func set(value: IQJsonValue, path: String) throws {
        try self._set(value: value, path: path)
    }

    func remove(path: String) throws {
        try self._set(value: nil, subpaths: self._subpaths(path))
    }
    
    func clean() {
        self.root = nil
    }
    
}

public extension QJson {
    
    func decode< Decoder : IQJsonValueDecoder >(_ decoder: Decoder.Type) throws -> Decoder.Value {
        return try decoder.decode(try self._get(path: nil))
    }
    
    @inlinable
    func decode< Decoder : IQJsonModelDecoder >(_ decoder: Decoder.Type) throws -> Decoder.Value {
        return try self.decode(QModelJsonDecoder< Decoder >.self)
    }
    
    @inlinable
    func decode< Alias : IQJsonDecoderAlias >(_ alias: Alias.Type) throws -> Alias.JsonDecoder.Value {
        return try self.decode(Alias.JsonDecoder.self)
    }
    
}

public extension QJson {
    
    func decode< Decoder : IQJsonValueDecoder >(_ decoder: Decoder.Type, default: Decoder.Value) -> Decoder.Value {
        return (try? decoder.decode(try self._get(path: nil))) ?? `default`
    }
    
    @inlinable
    func decode< Decoder : IQJsonModelDecoder >(_ decoder: Decoder.Type, default: Decoder.Value) -> Decoder.Value {
        return self.decode(QModelJsonDecoder< Decoder >.self, default: `default`)
    }
    
    @inlinable
    func decode< Alias : IQJsonDecoderAlias >(_ alias: Alias.Type, default: Alias.JsonDecoder.Value) -> Alias.JsonDecoder.Value {
        return self.decode(Alias.JsonDecoder.self, default: `default`)
    }
    
}

public extension QJson {
    
    func decode< Decoder : IQJsonValueDecoder >(_ decoder: Decoder.Type, skipping: Bool = false) throws -> Array< Decoder.Value > {
        guard let jsonArray = try self._get() as? NSArray else { throw QJsonError.cast }
        var result: [Decoder.Value] = []
        if skipping == true {
            for jsonItem in jsonArray {
                guard let value = try? decoder.decode(jsonItem as! IQJsonValue) else { continue }
                result.append(value)
            }
        } else {
            for jsonItem in jsonArray {
                result.append(try decoder.decode(jsonItem as! IQJsonValue))
            }
        }
        return result
    }
    
    @inlinable
    func decode< Decoder : IQJsonModelDecoder >(_ decoder: Decoder.Type, skipping: Bool = false) throws -> Array< Decoder.Value > {
        return try self.decode(QModelJsonDecoder< Decoder >.self, skipping: skipping)
    }
    
    @inlinable
    func decode< Alias : IQJsonDecoderAlias >(_ alias: Alias.Type, skipping: Bool = false) throws -> Array< Alias.JsonDecoder.Value > {
        return try self.decode(Alias.JsonDecoder.self, skipping: skipping)
    }
    
}

public extension QJson {
    
    @inlinable
    func decode< Decoder : IQJsonValueDecoder >(_ decoder: Decoder.Type, default: Array< Decoder.Value >, skipping: Bool = false) -> Array< Decoder.Value > {
        return (try? self.decode(decoder, skipping: skipping) as Array< Decoder.Value >) ?? `default`
    }
    
    @inlinable
    func decode< Decoder : IQJsonModelDecoder >(_ decoder: Decoder.Type, default: Array< Decoder.Value >, skipping: Bool = false) -> Array< Decoder.Value > {
        return self.decode(QModelJsonDecoder< Decoder >.self, default: `default`, skipping: skipping)
    }
    
    @inlinable
    func decode< Alias : IQJsonDecoderAlias >(_ alias: Alias.Type, default: Array< Alias.JsonDecoder.Value >, skipping: Bool = false) -> Array< Alias.JsonDecoder.Value > {
        return self.decode(Alias.JsonDecoder.self, default: `default`, skipping: skipping)
    }
    
}

public extension QJson {
    
    func decode< KeyDecoder : IQJsonValueDecoder, ValueDecoder : IQJsonValueDecoder >(_ keyDecoder: KeyDecoder.Type, _ valueDecoder: ValueDecoder.Type, skipping: Bool = false) throws -> Dictionary< KeyDecoder.Value, ValueDecoder.Value > {
        guard let jsonDictionary = try self._get() as? NSDictionary else { throw QJsonError.cast }
        var result: [KeyDecoder.Value : ValueDecoder.Value] = [:]
        if skipping == true {
            for jsonItem in jsonDictionary {
                let key = try keyDecoder.decode(jsonItem.key as! IQJsonValue)
                guard let value = try? valueDecoder.decode(jsonItem.value as! IQJsonValue) else { continue }
                result[key] = value
            }
        } else {
            for jsonItem in jsonDictionary {
                let key = try keyDecoder.decode(jsonItem.key as! IQJsonValue)
                let value = try valueDecoder.decode(jsonItem.value as! IQJsonValue)
                result[key] = value
            }
        }
        return result
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonValueDecoder, ValueDecoder : IQJsonModelDecoder >(_ keyDecoder: KeyDecoder.Type, _ valueDecoder: ValueDecoder.Type, skipping: Bool = false) throws -> Dictionary< KeyDecoder.Value, ValueDecoder.Value > {
        return try self.decode(keyDecoder, QModelJsonDecoder< ValueDecoder >.self, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonValueDecoder, ValueAlias : IQJsonDecoderAlias >(_ keyDecoder: KeyDecoder.Type, _ valueAlias: ValueAlias.Type, skipping: Bool = false) throws -> Dictionary< KeyDecoder.Value, ValueAlias.JsonDecoder.Value > {
        return try self.decode(keyDecoder, ValueAlias.JsonDecoder.self, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonModelDecoder, ValueDecoder : IQJsonValueDecoder >(_ keyDecoder: KeyDecoder.Type, _ valueDecoder: ValueDecoder.Type, skipping: Bool = false) throws -> Dictionary< KeyDecoder.Value, ValueDecoder.Value > {
        return try self.decode(QModelJsonDecoder< KeyDecoder >.self, valueDecoder, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonModelDecoder, ValueDecoder : IQJsonModelDecoder >(_ keyDecoder: KeyDecoder.Type, _ valueDecoder: ValueDecoder.Type, skipping: Bool = false) throws -> Dictionary< KeyDecoder.Value, ValueDecoder.Value > {
        return try self.decode(QModelJsonDecoder< KeyDecoder >.self, QModelJsonDecoder< ValueDecoder >.self, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonModelDecoder, ValueAlias : IQJsonDecoderAlias >(_ keyDecoder: KeyDecoder.Type, _ valueAlias: ValueAlias.Type, skipping: Bool = false) throws -> Dictionary< KeyDecoder.Value, ValueAlias.JsonDecoder.Value > {
        return try self.decode(QModelJsonDecoder< KeyDecoder >.self, ValueAlias.JsonDecoder.self, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyAlias : IQJsonDecoderAlias, ValueDecoder : IQJsonValueDecoder >(_ keyAlias: KeyAlias.Type, _ valueDecoder: ValueDecoder.Type, skipping: Bool = false) throws -> Dictionary< KeyAlias.JsonDecoder.Value, ValueDecoder.Value > {
        return try self.decode(KeyAlias.JsonDecoder.self, valueDecoder.self, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyAlias : IQJsonDecoderAlias, ValueDecoder : IQJsonModelDecoder >(_ keyAlias: KeyAlias.Type, _ valueDecoder: ValueDecoder.Type, skipping: Bool = false) throws -> Dictionary< KeyAlias.JsonDecoder.Value, ValueDecoder.Value > {
        return try self.decode(KeyAlias.JsonDecoder.self, QModelJsonDecoder< ValueDecoder >.self, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyAlias : IQJsonDecoderAlias, ValueAlias : IQJsonDecoderAlias >(_ keyAlias: KeyAlias.Type, _ valueAlias: ValueAlias.Type, skipping: Bool = false) throws -> Dictionary< KeyAlias.JsonDecoder.Value, ValueAlias.JsonDecoder.Value > {
        return try self.decode(KeyAlias.JsonDecoder.self, ValueAlias.JsonDecoder.self, skipping: skipping)
    }
    
}

public extension QJson {
    
    @inlinable
    func decode< KeyDecoder : IQJsonValueDecoder, ValueDecoder : IQJsonValueDecoder >(_ keyDecoder: KeyDecoder.Type, _ valueDecoder: ValueDecoder.Type, default: Dictionary< KeyDecoder.Value, ValueDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyDecoder.Value, ValueDecoder.Value > {
        return (try? self.decode(keyDecoder, valueDecoder, skipping: skipping) as Dictionary< KeyDecoder.Value, ValueDecoder.Value >) ?? `default`
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonValueDecoder, ValueDecoder : IQJsonModelDecoder >(_ keyDecoder: KeyDecoder.Type, _ valueDecoder: ValueDecoder.Type, default: Dictionary< KeyDecoder.Value, ValueDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyDecoder.Value, ValueDecoder.Value > {
        return self.decode(keyDecoder, QModelJsonDecoder< ValueDecoder >.self, default: `default`, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonValueDecoder, ValueAlias : IQJsonDecoderAlias >(_ keyDecoder: KeyDecoder.Type, _ valueAlias: ValueAlias.Type, default: Dictionary< KeyDecoder.Value, ValueAlias.JsonDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyDecoder.Value, ValueAlias.JsonDecoder.Value > {
        return self.decode(keyDecoder, ValueAlias.JsonDecoder.self, default: `default`, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonModelDecoder, ValueDecoder : IQJsonValueDecoder >(_ keyDecoder: KeyDecoder.Type, _ valueDecoder: ValueDecoder.Type, default: Dictionary< KeyDecoder.Value, ValueDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyDecoder.Value, ValueDecoder.Value > {
        return self.decode(QModelJsonDecoder< KeyDecoder >.self, valueDecoder, default: `default`, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonModelDecoder, ValueDecoder : IQJsonModelDecoder >(_ keyDecoder: KeyDecoder.Type, _ valueDecoder: ValueDecoder.Type, default: Dictionary< KeyDecoder.Value, ValueDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyDecoder.Value, ValueDecoder.Value > {
        return self.decode(QModelJsonDecoder< KeyDecoder >.self, QModelJsonDecoder< ValueDecoder >.self, default: `default`, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonModelDecoder, ValueAlias : IQJsonDecoderAlias >(_ keyDecoder: KeyDecoder.Type, _ valueAlias: ValueAlias.Type, default: Dictionary< KeyDecoder.Value, ValueAlias.JsonDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyDecoder.Value, ValueAlias.JsonDecoder.Value > {
        return self.decode(QModelJsonDecoder< KeyDecoder >.self, ValueAlias.JsonDecoder.self, default: `default`, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyAlias : IQJsonDecoderAlias, ValueDecoder : IQJsonValueDecoder >(_ keyAlias: KeyAlias.Type, _ valueDecoder: ValueDecoder.Type, default: Dictionary< KeyAlias.JsonDecoder.Value, ValueDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyAlias.JsonDecoder.Value, ValueDecoder.Value > {
        return self.decode(KeyAlias.JsonDecoder.self, valueDecoder.self, default: `default`, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyAlias : IQJsonDecoderAlias, ValueDecoder : IQJsonModelDecoder >(_ keyAlias: KeyAlias.Type, _ valueDecoder: ValueDecoder.Type, default: Dictionary< KeyAlias.JsonDecoder.Value, ValueDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyAlias.JsonDecoder.Value, ValueDecoder.Value > {
        return self.decode(KeyAlias.JsonDecoder.self, QModelJsonDecoder< ValueDecoder >.self, default: `default`, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyAlias : IQJsonDecoderAlias, ValueAlias : IQJsonDecoderAlias >(_ keyAlias: KeyAlias.Type, _ valueAlias: ValueAlias.Type, default: Dictionary< KeyAlias.JsonDecoder.Value, ValueAlias.JsonDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyAlias.JsonDecoder.Value, ValueAlias.JsonDecoder.Value > {
        return self.decode(KeyAlias.JsonDecoder.self, ValueAlias.JsonDecoder.self, default: `default`, skipping: skipping)
    }
    
}

public extension QJson {
    
    func decode< Decoder : IQJsonValueDecoder >(_ decoder: Decoder.Type, path: String) throws -> Decoder.Value {
        return try decoder.decode(try self._get(path: path))
    }
    
    @inlinable
    func decode< Decoder : IQJsonModelDecoder >(_ decoder: Decoder.Type, path: String) throws -> Decoder.Value {
        return try self.decode(QModelJsonDecoder< Decoder >.self, path: path)
    }
    
    @inlinable
    func decode< Alias : IQJsonDecoderAlias >(_ alias: Alias.Type, path: String) throws -> Alias.JsonDecoder.Value {
        return try self.decode(Alias.JsonDecoder.self, path: path)
    }
    
}

public extension QJson {
    
    func decode< Decoder : IQJsonValueDecoder >(_ decoder: Decoder.Type, path: String, default: Decoder.Value) -> Decoder.Value {
        return (try? decoder.decode(try self._get(path: path))) ?? `default`
    }
    
    @inlinable
    func decode< Decoder : IQJsonModelDecoder >(_ decoder: Decoder.Type, path: String, default: Decoder.Value) -> Decoder.Value {
        return self.decode(QModelJsonDecoder< Decoder >.self, path: path, default: `default`)
    }
    
    @inlinable
    func decode< Alias : IQJsonDecoderAlias >(_ alias: Alias.Type, path: String, default: Alias.JsonDecoder.Value) -> Alias.JsonDecoder.Value {
        return self.decode(Alias.JsonDecoder.self, path: path, default: `default`)
    }
    
}

public extension QJson {
    
    func decode< Decoder : IQJsonValueDecoder >(_ decoder: Decoder.Type, path: String, skipping: Bool = false) throws -> Array< Decoder.Value > {
        guard let jsonArray = try self._get(path: path) as? NSArray else { throw QJsonError.cast }
        var result: [Decoder.Value] = []
        if skipping == true {
            for jsonItem in jsonArray {
                guard let value = try? decoder.decode(jsonItem as! IQJsonValue) else { continue }
                result.append(value)
            }
        } else {
            for jsonItem in jsonArray {
                result.append(try decoder.decode(jsonItem as! IQJsonValue))
            }
        }
        return result
    }
    
    @inlinable
    func decode< Decoder : IQJsonModelDecoder >(_ decoder: Decoder.Type, path: String, skipping: Bool = false) throws -> Array< Decoder.Value > {
        return try self.decode(QModelJsonDecoder< Decoder >.self, path: path, skipping: skipping)
    }
    
    @inlinable
    func decode< Alias : IQJsonDecoderAlias >(_ alias: Alias.Type, path: String, skipping: Bool = false) throws -> Array< Alias.JsonDecoder.Value > {
        return try self.decode(Alias.JsonDecoder.self, path: path, skipping: skipping)
    }
    
}

public extension QJson {
    
    @inlinable
    func decode< Decoder : IQJsonValueDecoder >(_ decoder: Decoder.Type, path: String, default: Array< Decoder.Value >, skipping: Bool = false) -> Array< Decoder.Value > {
        return (try? self.decode(decoder, path: path, skipping: skipping) as Array< Decoder.Value >) ?? `default`
    }
    
    @inlinable
    func decode< Decoder : IQJsonModelDecoder >(_ decoder: Decoder.Type, path: String, default: Array< Decoder.Value >, skipping: Bool = false) -> Array< Decoder.Value > {
        return self.decode(QModelJsonDecoder< Decoder >.self, path: path, default: `default`, skipping: skipping)
    }
    
    @inlinable
    func decode< Alias : IQJsonDecoderAlias >(_ alias: Alias.Type, path: String, default: Array< Alias.JsonDecoder.Value >, skipping: Bool = false) -> Array< Alias.JsonDecoder.Value > {
        return self.decode(Alias.JsonDecoder.self, path: path, default: `default`, skipping: skipping)
    }
    
}

public extension QJson {
    
    func decode< KeyDecoder : IQJsonValueDecoder, ValueDecoder : IQJsonValueDecoder >(_ keyDecoder: KeyDecoder.Type, _ valueDecoder: ValueDecoder.Type, path: String, skipping: Bool = false) throws -> Dictionary< KeyDecoder.Value, ValueDecoder.Value > {
        guard let jsonDictionary = try self._get(path: path) as? NSDictionary else { throw QJsonError.cast }
        var result: [KeyDecoder.Value : ValueDecoder.Value] = [:]
        if skipping == true {
            for jsonItem in jsonDictionary {
                let key = try keyDecoder.decode(jsonItem.key as! IQJsonValue)
                guard let value = try? valueDecoder.decode(jsonItem.value as! IQJsonValue) else { continue }
                result[key] = value
            }
        } else {
            for jsonItem in jsonDictionary {
                let key = try keyDecoder.decode(jsonItem.key as! IQJsonValue)
                let value = try valueDecoder.decode(jsonItem.value as! IQJsonValue)
                result[key] = value
            }
        }
        return result
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonValueDecoder, ValueDecoder : IQJsonModelDecoder >(_ keyDecoder: KeyDecoder.Type, _ valueDecoder: ValueDecoder.Type, path: String, skipping: Bool = false) throws -> Dictionary< KeyDecoder.Value, ValueDecoder.Value > {
        return try self.decode(keyDecoder, QModelJsonDecoder< ValueDecoder >.self, path: path, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonValueDecoder, ValueAlias : IQJsonDecoderAlias >(_ keyDecoder: KeyDecoder.Type, _ valueAlias: ValueAlias.Type, path: String, skipping: Bool = false) throws -> Dictionary< KeyDecoder.Value, ValueAlias.JsonDecoder.Value > {
        return try self.decode(keyDecoder, ValueAlias.JsonDecoder.self, path: path, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonModelDecoder, ValueDecoder : IQJsonValueDecoder >(_ keyDecoder: KeyDecoder.Type, _ valueDecoder: ValueDecoder.Type, path: String, skipping: Bool = false) throws -> Dictionary< KeyDecoder.Value, ValueDecoder.Value > {
        return try self.decode(QModelJsonDecoder< KeyDecoder >.self, valueDecoder, path: path, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonModelDecoder, ValueDecoder : IQJsonModelDecoder >(_ keyDecoder: KeyDecoder.Type, _ valueDecoder: ValueDecoder.Type, path: String, skipping: Bool = false) throws -> Dictionary< KeyDecoder.Value, ValueDecoder.Value > {
        return try self.decode(QModelJsonDecoder< KeyDecoder >.self, QModelJsonDecoder< ValueDecoder >.self, path: path, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonModelDecoder, ValueAlias : IQJsonDecoderAlias >(_ keyDecoder: KeyDecoder.Type, _ valueAlias: ValueAlias.Type, path: String, skipping: Bool = false) throws -> Dictionary< KeyDecoder.Value, ValueAlias.JsonDecoder.Value > {
        return try self.decode(QModelJsonDecoder< KeyDecoder >.self, ValueAlias.JsonDecoder.self, path: path, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyAlias : IQJsonDecoderAlias, ValueDecoder : IQJsonValueDecoder >(_ keyAlias: KeyAlias.Type, _ valueDecoder: ValueDecoder.Type, path: String, skipping: Bool = false) throws -> Dictionary< KeyAlias.JsonDecoder.Value, ValueDecoder.Value > {
        return try self.decode(KeyAlias.JsonDecoder.self, valueDecoder.self, path: path, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyAlias : IQJsonDecoderAlias, ValueDecoder : IQJsonModelDecoder >(_ keyAlias: KeyAlias.Type, _ valueDecoder: ValueDecoder.Type, path: String, skipping: Bool = false) throws -> Dictionary< KeyAlias.JsonDecoder.Value, ValueDecoder.Value > {
        return try self.decode(KeyAlias.JsonDecoder.self, QModelJsonDecoder< ValueDecoder >.self, path: path, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyAlias : IQJsonDecoderAlias, ValueAlias : IQJsonDecoderAlias >(_ keyAlias: KeyAlias.Type, _ valueAlias: ValueAlias.Type, path: String, skipping: Bool = false) throws -> Dictionary< KeyAlias.JsonDecoder.Value, ValueAlias.JsonDecoder.Value > {
        return try self.decode(KeyAlias.JsonDecoder.self, ValueAlias.JsonDecoder.self, path: path, skipping: skipping)
    }
    
}

public extension QJson {
    
    @inlinable
    func decode< KeyDecoder : IQJsonValueDecoder, ValueDecoder : IQJsonValueDecoder >(_ keyDecoder: KeyDecoder.Type, _ valueDecoder: ValueDecoder.Type, path: String, default: Dictionary< KeyDecoder.Value, ValueDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyDecoder.Value, ValueDecoder.Value > {
        return (try? self.decode(keyDecoder, valueDecoder, path: path, skipping: skipping) as Dictionary< KeyDecoder.Value, ValueDecoder.Value >) ?? `default`
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonValueDecoder, ValueDecoder : IQJsonModelDecoder >(_ keyDecoder: KeyDecoder.Type, _ valueDecoder: ValueDecoder.Type, path: String, default: Dictionary< KeyDecoder.Value, ValueDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyDecoder.Value, ValueDecoder.Value > {
        return self.decode(keyDecoder, QModelJsonDecoder< ValueDecoder >.self, path: path, default: `default`, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonValueDecoder, ValueAlias : IQJsonDecoderAlias >(_ keyDecoder: KeyDecoder.Type, _ valueAlias: ValueAlias.Type, path: String, default: Dictionary< KeyDecoder.Value, ValueAlias.JsonDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyDecoder.Value, ValueAlias.JsonDecoder.Value > {
        return self.decode(keyDecoder, ValueAlias.JsonDecoder.self, path: path, default: `default`, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonModelDecoder, ValueDecoder : IQJsonValueDecoder >(_ keyDecoder: KeyDecoder.Type, _ valueDecoder: ValueDecoder.Type, path: String, default: Dictionary< KeyDecoder.Value, ValueDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyDecoder.Value, ValueDecoder.Value > {
        return self.decode(QModelJsonDecoder< KeyDecoder >.self, valueDecoder, path: path, default: `default`, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonModelDecoder, ValueDecoder : IQJsonModelDecoder >(_ keyDecoder: KeyDecoder.Type, _ valueDecoder: ValueDecoder.Type, path: String, default: Dictionary< KeyDecoder.Value, ValueDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyDecoder.Value, ValueDecoder.Value > {
        return self.decode(QModelJsonDecoder< KeyDecoder >.self, QModelJsonDecoder< ValueDecoder >.self, path: path, default: `default`, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyDecoder : IQJsonModelDecoder, ValueAlias : IQJsonDecoderAlias >(_ keyDecoder: KeyDecoder.Type, _ valueAlias: ValueAlias.Type, path: String, default: Dictionary< KeyDecoder.Value, ValueAlias.JsonDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyDecoder.Value, ValueAlias.JsonDecoder.Value > {
        return self.decode(QModelJsonDecoder< KeyDecoder >.self, ValueAlias.JsonDecoder.self, path: path, default: `default`, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyAlias : IQJsonDecoderAlias, ValueDecoder : IQJsonValueDecoder >(_ keyAlias: KeyAlias.Type, _ valueDecoder: ValueDecoder.Type, path: String, default: Dictionary< KeyAlias.JsonDecoder.Value, ValueDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyAlias.JsonDecoder.Value, ValueDecoder.Value > {
        return self.decode(KeyAlias.JsonDecoder.self, valueDecoder.self, path: path, default: `default`, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyAlias : IQJsonDecoderAlias, ValueDecoder : IQJsonModelDecoder >(_ keyAlias: KeyAlias.Type, _ valueDecoder: ValueDecoder.Type, path: String, default: Dictionary< KeyAlias.JsonDecoder.Value, ValueDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyAlias.JsonDecoder.Value, ValueDecoder.Value > {
        return self.decode(KeyAlias.JsonDecoder.self, QModelJsonDecoder< ValueDecoder >.self, path: path, default: `default`, skipping: skipping)
    }
    
    @inlinable
    func decode< KeyAlias : IQJsonDecoderAlias, ValueAlias : IQJsonDecoderAlias >(_ keyAlias: KeyAlias.Type, _ valueAlias: ValueAlias.Type, path: String, default: Dictionary< KeyAlias.JsonDecoder.Value, ValueAlias.JsonDecoder.Value >, skipping: Bool = false) -> Dictionary< KeyAlias.JsonDecoder.Value, ValueAlias.JsonDecoder.Value > {
        return self.decode(KeyAlias.JsonDecoder.self, ValueAlias.JsonDecoder.self, path: path, default: `default`, skipping: skipping)
    }
    
}

public extension QJson {
    
    func decode(_ dateFormat: String, path: String) throws -> Date {
        let string = try self.decode(QStringJsonCoder.self, path: path) as String
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        guard let date = formatter.date(from: string) else { throw QJsonError.cast }
        return date
    }
    
}

public extension QJson {
    
    func encode< Encoder: IQJsonValueEncoder >(_ encoder: Encoder.Type, value: Encoder.Value) throws {
        try self._set(value: try encoder.encode(value), path: nil)
    }
    
    @inlinable
    func encode< Encoder: IQJsonModelEncoder >(_ encoder: Encoder.Type, value: Encoder.Value) throws {
        try self.encode(QModelJsonEncoder< Encoder >.self, value: value)
    }
    
    @inlinable
    func encode< Alias: IQJsonEncoderAlias >(_ alias: Alias.Type, value: Alias.JsonEncoder.Value) throws {
        try self.encode(Alias.JsonEncoder.self, value: value)
    }
    
}

public extension QJson {
    
    func encode< Encoder: IQJsonValueEncoder >(_ encoder: Encoder.Type, value: Encoder.Value, path: String) throws {
        try self._set(value: try encoder.encode(value), path: path)
    }
    
    @inlinable
    func encode< Encoder: IQJsonModelEncoder >(_ encoder: Encoder.Type, value: Encoder.Value, path: String) throws {
        try self.encode(QModelJsonEncoder< Encoder >.self, value: value, path: path)
    }
    
    @inlinable
    func encode< Alias: IQJsonEncoderAlias >(_ alias: Alias.Type, value: Alias.JsonEncoder.Value, path: String) throws {
        try self.encode(Alias.JsonEncoder.self, value: value, path: path)
    }
    
}

public extension QJson {
    
    func encode< Encoder : IQJsonValueEncoder >(_ encoder: Encoder.Type, value: Array< Encoder.Value >, skipping: Bool = false) throws {
        let jsonValue = NSMutableArray(capacity: value.count)
        if skipping == true {
            for item in value {
                guard let value = try? encoder.encode(item) else { continue }
                jsonValue.add(value)
            }
        } else {
            for item in value {
                jsonValue.add(try encoder.encode(item))
            }
        }
        try self.set(value: jsonValue)
    }
    
    @inlinable
    func encode< Encoder : IQJsonModelEncoder >(_ encoder: Encoder.Type, value: Array< Encoder.Value >, skipping: Bool = false) throws {
        try self.encode(QModelJsonEncoder< Encoder >.self, value: value, skipping: skipping)
    }
    
    @inlinable
    func encode< Alias : IQJsonEncoderAlias >(_ alias: Alias.Type, value: Array< Alias.JsonEncoder.Value >, skipping: Bool = false) throws {
        return try self.encode(Alias.JsonEncoder.self, value: value, skipping: skipping)
    }
    
}

public extension QJson {
    
    func encode< KeyEncoder : IQJsonValueEncoder, ValueEncoder : IQJsonValueEncoder >(_ keyEncoder: KeyEncoder.Type, _ valueEncoder: ValueEncoder.Type, value: Dictionary< KeyEncoder.Value, ValueEncoder.Value >, skipping: Bool = false) throws {
        let jsonValue = NSMutableDictionary(capacity: value.count)
        if skipping == true {
            for item in value {
                guard let key = try? keyEncoder.encode(item.key) else { continue }
                guard let value = try? valueEncoder.encode(item.value) else { continue }
                jsonValue.setObject(key, forKey: value as! NSCopying)
            }
        } else {
            for item in value {
                let key = try keyEncoder.encode(item.key)
                let value = try valueEncoder.encode(item.value)
                jsonValue.setObject(key, forKey: value as! NSCopying)
            }
        }
        try self.set(value: jsonValue)
    }
    
    @inlinable
    func encode< KeyEncoder : IQJsonValueEncoder, ValueEncoder : IQJsonModelEncoder >(_ keyEncoder: KeyEncoder.Type, _ valueEncoder: ValueEncoder.Type, value: Dictionary< KeyEncoder.Value, ValueEncoder.Value >, skipping: Bool = false) throws {
        return try self.encode(keyEncoder, QModelJsonEncoder< ValueEncoder >.self, value: value, skipping: skipping)
    }
    
    @inlinable
    func encode< KeyEncoder : IQJsonValueEncoder, ValueAlias : IQJsonEncoderAlias >(_ keyEncoder: KeyEncoder.Type, _ valueAlias: ValueAlias.Type, value: Dictionary< KeyEncoder.Value, ValueAlias.JsonEncoder.Value >, skipping: Bool = false) throws {
        return try self.encode(keyEncoder, ValueAlias.JsonEncoder.self, value: value, skipping: skipping)
    }
    
    @inlinable
    func encode< KeyEncoder : IQJsonModelEncoder, ValueEncoder : IQJsonValueEncoder >(_ keyEncoder: KeyEncoder.Type, _ valueEncoder: ValueEncoder.Type, value: Dictionary< KeyEncoder.Value, ValueEncoder.Value >, skipping: Bool = false) throws {
        return try self.encode(QModelJsonEncoder< KeyEncoder >.self, valueEncoder, value: value, skipping: skipping)
    }
    
    @inlinable
    func encode< KeyEncoder : IQJsonModelEncoder, ValueEncoder : IQJsonModelEncoder >(_ keyEncoder: KeyEncoder.Type, _ valueEncoder: ValueEncoder.Type, value: Dictionary< KeyEncoder.Value, ValueEncoder.Value >, skipping: Bool = false) throws {
        return try self.encode(QModelJsonEncoder< KeyEncoder >.self, QModelJsonEncoder< ValueEncoder >.self, value: value, skipping: skipping)
    }
    
    @inlinable
    func encode< KeyEncoder : IQJsonModelEncoder, ValueAlias : IQJsonEncoderAlias >(_ keyEncoder: KeyEncoder.Type, _ valueAlias: ValueAlias.Type, value: Dictionary< KeyEncoder.Value, ValueAlias.JsonEncoder.Value >, skipping: Bool = false) throws {
        return try self.encode(QModelJsonEncoder< KeyEncoder >.self, ValueAlias.JsonEncoder.self, value: value, skipping: skipping)
    }
    
    @inlinable
    func encode< KeyAlias : IQJsonEncoderAlias, ValueEncoder : IQJsonValueEncoder >(_ keyAlias: KeyAlias.Type, _ valueEncoder: ValueEncoder.Type, value: Dictionary< KeyAlias.JsonEncoder.Value, ValueEncoder.Value >, skipping: Bool = false) throws {
        return try self.encode(KeyAlias.JsonEncoder.self, valueEncoder.self, value: value, skipping: skipping)
    }
    
    @inlinable
    func encode< KeyAlias : IQJsonEncoderAlias, ValueEncoder : IQJsonModelEncoder >(_ keyAlias: KeyAlias.Type, _ valueEncoder: ValueEncoder.Type, value: Dictionary< KeyAlias.JsonEncoder.Value, ValueEncoder.Value >, skipping: Bool = false) throws {
        return try self.encode(KeyAlias.JsonEncoder.self, QModelJsonEncoder< ValueEncoder >.self, value: value, skipping: skipping)
    }
    
    @inlinable
    func encode< KeyAlias : IQJsonEncoderAlias, ValueAlias : IQJsonEncoderAlias >(_ keyAlias: KeyAlias.Type, _ valueAlias: ValueAlias.Type, value: Dictionary< KeyAlias.JsonEncoder.Value, ValueAlias.JsonEncoder.Value >, skipping: Bool = false) throws {
        return try self.encode(KeyAlias.JsonEncoder.self, ValueAlias.JsonEncoder.self, value: value, skipping: skipping)
    }
    
}

public extension QJson {
    
    func encode< Encoder: IQJsonValueEncoder >(_ encoder: Encoder.Type, value: Optional< Encoder.Value >, path: String, nullable: Bool = false) throws {
        if let value = value {
            try self._set(value: try encoder.encode(value), path: path)
        } else if nullable == true {
            try self._set(value: NSNull(), path: path)
        }
    }
    
    @inlinable
    func encode< Encoder: IQJsonModelEncoder >(_ encoder: Encoder.Type, value: Optional< Encoder.Value >, path: String, nullable: Bool = false) throws {
        try self.encode(QModelJsonEncoder< Encoder >.self, value: value, path: path, nullable: nullable)
    }
    
    @inlinable
    func encode< Alias: IQJsonEncoderAlias >(_ alias: Alias.Type, value: Optional< Alias.JsonEncoder.Value >, path: String, nullable: Bool = false) throws {
        try self.encode(Alias.JsonEncoder.self, value: value, path: path, nullable: nullable)
    }
    
}

public extension QJson {
    
    func encode< Encoder : IQJsonValueEncoder >(_ encoder: Encoder.Type, value: Array< Encoder.Value >, path: String, skipping: Bool = false) throws {
        let jsonValue = NSMutableArray(capacity: value.count)
        if skipping == true {
            for item in value {
                guard let value = try? encoder.encode(item) else { continue }
                jsonValue.add(value)
            }
        } else {
            for item in value {
                jsonValue.add(try encoder.encode(item))
            }
        }
        try self.set(value: jsonValue, path: path)
    }
    
    @inlinable
    func encode< Encoder : IQJsonModelEncoder >(_ encoder: Encoder.Type, value: Array< Encoder.Value >, path: String, skipping: Bool = false) throws {
        try self.encode(QModelJsonEncoder< Encoder >.self, value: value, path: path, skipping: skipping)
    }
    
    @inlinable
    func encode< Alias : IQJsonEncoderAlias >(_ alias: Alias.Type, value: Array< Alias.JsonEncoder.Value >, path: String, skipping: Bool = false) throws {
        return try self.encode(Alias.JsonEncoder.self, value: value, path: path, skipping: skipping)
    }
    
}

public extension QJson {
    
    func encode< Encoder : IQJsonValueEncoder >(_ encoder: Encoder.Type, value: Optional< Array< Encoder.Value > >, path: String, skipping: Bool = false, nullable: Bool = false) throws {
        if let value = value {
            try self.encode(encoder, value: value, path: path, skipping: skipping)
        } else if nullable == true {
            try self._set(value: NSNull(), path: path)
        }
    }
    
    @inlinable
    func encode< Encoder : IQJsonModelEncoder >(_ encoder: Encoder.Type, value: Optional< Array< Encoder.Value > >, path: String, skipping: Bool = false, nullable: Bool = false) throws {
        try self.encode(QModelJsonEncoder< Encoder >.self, value: value, path: path, skipping: skipping, nullable: nullable)
    }
    
    @inlinable
    func encode< Alias : IQJsonEncoderAlias >(_ alias: Alias.Type, value: Optional< Array< Alias.JsonEncoder.Value > >, path: String, skipping: Bool = false, nullable: Bool = false) throws {
        return try self.encode(Alias.JsonEncoder.self, value: value, path: path, skipping: skipping, nullable: nullable)
    }
    
}

public extension QJson {
    
    func encode< KeyEncoder : IQJsonValueEncoder, ValueEncoder : IQJsonValueEncoder >(_ keyEncoder: KeyEncoder.Type, _ valueEncoder: ValueEncoder.Type, value: Dictionary< KeyEncoder.Value, ValueEncoder.Value >, path: String, skipping: Bool = false) throws {
        let jsonValue = NSMutableDictionary(capacity: value.count)
        if skipping == true {
            for item in value {
                guard let key = try? keyEncoder.encode(item.key) else { continue }
                guard let value = try? valueEncoder.encode(item.value) else { continue }
                jsonValue.setObject(key, forKey: value as! NSCopying)
            }
        } else {
            for item in value {
                let key = try keyEncoder.encode(item.key)
                let value = try valueEncoder.encode(item.value)
                jsonValue.setObject(key, forKey: value as! NSCopying)
            }
        }
        try self.set(value: jsonValue, path: path)
    }
    
    @inlinable
    func encode< KeyEncoder : IQJsonValueEncoder, ValueEncoder : IQJsonModelEncoder >(_ keyEncoder: KeyEncoder.Type, _ valueEncoder: ValueEncoder.Type, value: Dictionary< KeyEncoder.Value, ValueEncoder.Value >, path: String, skipping: Bool = false) throws {
        return try self.encode(keyEncoder, QModelJsonEncoder< ValueEncoder >.self, value: value, path: path, skipping: skipping)
    }
    
    @inlinable
    func encode< KeyEncoder : IQJsonValueEncoder, ValueAlias : IQJsonEncoderAlias >(_ keyEncoder: KeyEncoder.Type, _ valueAlias: ValueAlias.Type, value: Dictionary< KeyEncoder.Value, ValueAlias.JsonEncoder.Value >, path: String, skipping: Bool = false) throws {
        return try self.encode(keyEncoder, ValueAlias.JsonEncoder.self, value: value, path: path, skipping: skipping)
    }
    
    @inlinable
    func encode< KeyEncoder : IQJsonModelEncoder, ValueEncoder : IQJsonValueEncoder >(_ keyEncoder: KeyEncoder.Type, _ valueEncoder: ValueEncoder.Type, value: Dictionary< KeyEncoder.Value, ValueEncoder.Value >, path: String, skipping: Bool = false) throws {
        return try self.encode(QModelJsonEncoder< KeyEncoder >.self, valueEncoder, value: value, path: path, skipping: skipping)
    }
    
    @inlinable
    func encode< KeyEncoder : IQJsonModelEncoder, ValueEncoder : IQJsonModelEncoder >(_ keyEncoder: KeyEncoder.Type, _ valueEncoder: ValueEncoder.Type, value: Dictionary< KeyEncoder.Value, ValueEncoder.Value >, path: String, skipping: Bool = false) throws {
        return try self.encode(QModelJsonEncoder< KeyEncoder >.self, QModelJsonEncoder< ValueEncoder >.self, value: value, path: path, skipping: skipping)
    }
    
    @inlinable
    func encode< KeyEncoder : IQJsonModelEncoder, ValueAlias : IQJsonEncoderAlias >(_ keyEncoder: KeyEncoder.Type, _ valueAlias: ValueAlias.Type, value: Dictionary< KeyEncoder.Value, ValueAlias.JsonEncoder.Value >, path: String, skipping: Bool = false) throws {
        return try self.encode(QModelJsonEncoder< KeyEncoder >.self, ValueAlias.JsonEncoder.self, value: value, path: path, skipping: skipping)
    }
    
    @inlinable
    func encode< KeyAlias : IQJsonEncoderAlias, ValueEncoder : IQJsonValueEncoder >(_ keyAlias: KeyAlias.Type, _ valueEncoder: ValueEncoder.Type, value: Dictionary< KeyAlias.JsonEncoder.Value, ValueEncoder.Value >, path: String, skipping: Bool = false) throws {
        return try self.encode(KeyAlias.JsonEncoder.self, valueEncoder.self, value: value, path: path, skipping: skipping)
    }
    
    @inlinable
    func encode< KeyAlias : IQJsonEncoderAlias, ValueEncoder : IQJsonModelEncoder >(_ keyAlias: KeyAlias.Type, _ valueEncoder: ValueEncoder.Type, value: Dictionary< KeyAlias.JsonEncoder.Value, ValueEncoder.Value >, path: String, skipping: Bool = false) throws {
        return try self.encode(KeyAlias.JsonEncoder.self, QModelJsonEncoder< ValueEncoder >.self, value: value, path: path, skipping: skipping)
    }
    
    @inlinable
    func encode< KeyAlias : IQJsonEncoderAlias, ValueAlias : IQJsonEncoderAlias >(_ keyAlias: KeyAlias.Type, _ valueAlias: ValueAlias.Type, value: Dictionary< KeyAlias.JsonEncoder.Value, ValueAlias.JsonEncoder.Value >, path: String, skipping: Bool = false) throws {
        return try self.encode(KeyAlias.JsonEncoder.self, ValueAlias.JsonEncoder.self, value: value, path: path, skipping: skipping)
    }
    
}

public extension QJson {
    
    func encode< KeyEncoder : IQJsonValueEncoder, ValueEncoder : IQJsonValueEncoder >(_ keyEncoder: KeyEncoder.Type, _ valueEncoder: ValueEncoder.Type, value: Optional< Dictionary< KeyEncoder.Value, ValueEncoder.Value > >, path: String, skipping: Bool = false, nullable: Bool = false) throws {
        if let value = value {
            try self.encode(keyEncoder, valueEncoder, value: value, path: path, skipping: skipping)
        } else if nullable == true {
            try self._set(value: NSNull(), path: path)
        }
    }
    
    @inlinable
    func encode< KeyEncoder : IQJsonValueEncoder, ValueEncoder : IQJsonModelEncoder >(_ keyEncoder: KeyEncoder.Type, _ valueEncoder: ValueEncoder.Type, value: Optional< Dictionary< KeyEncoder.Value, ValueEncoder.Value > >, path: String, skipping: Bool = false, nullable: Bool = false) throws {
        try self.encode(keyEncoder, QModelJsonEncoder< ValueEncoder >.self, value: value, path: path, skipping: skipping, nullable: nullable)
    }
    
    @inlinable
    func encode< KeyEncoder : IQJsonValueEncoder, ValueAlias : IQJsonEncoderAlias >(_ keyEncoder: KeyEncoder.Type, _ valueAlias: ValueAlias.Type, value: Optional< Dictionary< KeyEncoder.Value, ValueAlias.JsonEncoder.Value > >, path: String, skipping: Bool = false, nullable: Bool = false) throws {
        try self.encode(keyEncoder, ValueAlias.JsonEncoder.self, value: value, path: path, skipping: skipping, nullable: nullable)
    }
    
    @inlinable
    func encode< KeyEncoder : IQJsonModelEncoder, ValueEncoder : IQJsonValueEncoder >(_ keyEncoder: KeyEncoder.Type, _ valueEncoder: ValueEncoder.Type, value: Optional< Dictionary< KeyEncoder.Value, ValueEncoder.Value > >, path: String, skipping: Bool = false, nullable: Bool = false) throws {
        try self.encode(QModelJsonEncoder< KeyEncoder >.self, valueEncoder, value: value, path: path, skipping: skipping, nullable: nullable)
    }
    
    @inlinable
    func encode< KeyEncoder : IQJsonModelEncoder, ValueEncoder : IQJsonModelEncoder >(_ keyEncoder: KeyEncoder.Type, _ valueEncoder: ValueEncoder.Type, value: Optional< Dictionary< KeyEncoder.Value, ValueEncoder.Value > >, path: String, skipping: Bool = false, nullable: Bool = false) throws {
        try self.encode(QModelJsonEncoder< KeyEncoder >.self, QModelJsonEncoder< ValueEncoder >.self, value: value, path: path, skipping: skipping, nullable: nullable)
    }
    
    @inlinable
    func encode< KeyEncoder : IQJsonModelEncoder, ValueAlias : IQJsonEncoderAlias >(_ keyEncoder: KeyEncoder.Type, _ valueAlias: ValueAlias.Type, value: Optional< Dictionary< KeyEncoder.Value, ValueAlias.JsonEncoder.Value > >, path: String, skipping: Bool = false, nullable: Bool = false) throws {
        try self.encode(QModelJsonEncoder< KeyEncoder >.self, ValueAlias.JsonEncoder.self, value: value, path: path, skipping: skipping, nullable: nullable)
    }
    
    @inlinable
    func encode< KeyAlias : IQJsonEncoderAlias, ValueEncoder : IQJsonValueEncoder >(_ keyAlias: KeyAlias.Type, _ valueEncoder: ValueEncoder.Type, value: Optional< Dictionary< KeyAlias.JsonEncoder.Value, ValueEncoder.Value > >, path: String, skipping: Bool = false, nullable: Bool = false) throws {
        try self.encode(KeyAlias.JsonEncoder.self, valueEncoder.self, value: value, path: path, skipping: skipping, nullable: nullable)
    }
    
    @inlinable
    func encode< KeyAlias : IQJsonEncoderAlias, ValueEncoder : IQJsonModelEncoder >(_ keyAlias: KeyAlias.Type, _ valueEncoder: ValueEncoder.Type, value: Optional< Dictionary< KeyAlias.JsonEncoder.Value, ValueEncoder.Value > >, path: String, skipping: Bool = false, nullable: Bool = false) throws {
        try self.encode(KeyAlias.JsonEncoder.self, QModelJsonEncoder< ValueEncoder >.self, value: value, path: path, skipping: skipping, nullable: nullable)
    }
    
    @inlinable
    func encode< KeyAlias : IQJsonEncoderAlias, ValueAlias : IQJsonEncoderAlias >(_ keyAlias: KeyAlias.Type, _ valueAlias: ValueAlias.Type, value: Optional< Dictionary< KeyAlias.JsonEncoder.Value, ValueAlias.JsonEncoder.Value > >, path: String, skipping: Bool = false, nullable: Bool = false) throws {
        try self.encode(KeyAlias.JsonEncoder.self, ValueAlias.JsonEncoder.self, value: value, path: path, skipping: skipping, nullable: nullable)
    }
    
}

public extension QJson {
    
    func encode(_ dateFormat: String, value: Date, path: String) throws {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        try self.encode(String.self, value: formatter.string(from: value))
    }
    
}

// MARK: QJson • Private

private extension QJson {
    
    func _set(value: IQJsonValue, path: String? = nil) throws {
        if let path = path {
            try self._set(value: value, subpaths: self._subpaths(path))
        } else {
            self.root = value
        }
    }

    func _set(value: IQJsonValue?, subpaths: [IQJsonPath]) throws {
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
        var root: IQJsonValue = self.root!
        var prevRoot: IQJsonValue?
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
                    root = nextRoot as! IQJsonValue
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
                    root = mutable[index] as! IQJsonValue
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
    
    func _get(path: String? = nil) throws -> IQJsonValue {
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
                root = temp as! IQJsonValue
            } else if let array = root as? NSArray {
                guard let index = subpath.jsonPathIndex, index < array.count else { throw QJsonError.access }
                root = array.object(at: index) as! IQJsonValue
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
                let indexString = String(subpath[startIndex ..< endIndex])
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
