//
//  libQuicklyJson
//

import Foundation

public struct QInt8JsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> Int8 {
        return try QNSNumberJsonCoder.decode(value).int8Value
    }
    
    public static func encode(_ value: Int8) throws -> IQJsonValue {
        return try QNSNumberJsonCoder.encode(NSNumber(value: value))
    }
    
}

extension Int8 : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QInt8JsonCoder
    public typealias JsonEncoder = QInt8JsonCoder
    
}
