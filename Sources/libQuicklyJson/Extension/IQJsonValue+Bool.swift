//
//  libQuicklyJson
//

import Foundation

extension Bool : IQJsonValueDecodable {

    public static func fromJson(value: Any) throws -> Self {
        if let boolean = value as? Bool {
            return boolean
        } else if let string = value as? String {
            switch string.lowercased() {
            case "true", "yes", "on": return true
            case "false", "no", "off": return false
            default: break
            }
        } else if let number = value as? NSNumber {
            return number.boolValue
        }
        throw QJsonError.cast
    }

}

extension Bool : IQJsonValueEncodable {
    
    public func toJsonValue() throws -> Any {
        return NSNumber(value: self)
    }
    
}
