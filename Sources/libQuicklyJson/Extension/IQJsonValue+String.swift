//
//  libQuicklyJson
//

import Foundation

extension String : IQJsonValueDecodable {

    public static func fromJson(value: Any) throws -> Self {
        if let string = value as? String {
            return string
        } else if let number = value as? NSNumber {
            return number.stringValue
        } else if let decimalNumber = value as? NSDecimalNumber {
            return decimalNumber.stringValue
        }
        throw QJsonError.cast
    }

}

extension String : IQJsonValueEncodable {
    
    public func toJsonValue() throws -> Any {
        return self
    }
    
}
