//
//  libQuicklyJson
//

import Foundation

public struct QNSStringJsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> NSString {
        if let string = value as? NSString {
            return string
        } else if let number = value as? NSNumber {
            return number.stringValue as NSString
        } else if let decimalNumber = value as? NSDecimalNumber {
            return decimalNumber.stringValue as NSString
        }
        throw QJsonError.cast
    }
    
    public static func encode(_ value: NSString) throws -> IQJsonValue {
        return value
    }
    
}
