//
//  libQuicklyJson
//

import Foundation

public struct QNSDecimalNumberJsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> NSDecimalNumber {
        if let decimalNumber = value as? NSDecimalNumber {
            return decimalNumber
        } else if let number = value as? NSNumber {
            return NSDecimalNumber(string: number.stringValue)
        } else if let string = value as? NSString, let decimalNumber = NSDecimalNumber.decimalNumber(from: string) {
            return decimalNumber
        }
        throw QJsonError.cast
    }
    
    public static func encode(_ value: NSDecimalNumber) throws -> IQJsonValue {
        return value
    }
    
}
