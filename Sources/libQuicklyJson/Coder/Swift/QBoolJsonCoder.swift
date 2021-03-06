//
//  libQuicklyJson
//

import Foundation

public struct QBoolJsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> Bool {
        if let number = value as? NSNumber {
            return number.boolValue
        } else if let string = value as? NSString {
            switch string.lowercased {
            case "true", "yes", "on": return true
            case "false", "no", "off": return false
            default: break
            }
        }
        throw QJsonError.cast
    }
    
    public static func encode(_ value: Bool) throws -> IQJsonValue {
        return NSNumber(value: value)
    }
    
}

extension Bool : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QBoolJsonCoder
    public typealias JsonEncoder = QBoolJsonCoder
    
}
