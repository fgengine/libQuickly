//
//  libQuicklyJson
//

import Foundation

public struct QNSNumberJsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> NSNumber {
        if let number = value as? NSNumber {
            return number
        } else if let string = value as? NSString, let number = NSNumber.number(from: string) {
            return number
        }
        throw QJsonError.cast
    }
    
    public static func encode(_ value: NSNumber) throws -> IQJsonValue {
        return value
    }
    
}
