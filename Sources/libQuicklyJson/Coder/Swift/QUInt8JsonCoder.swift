//
//  libQuicklyJson
//

import Foundation

public struct QUInt8JsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> UInt8 {
        return try QNSNumberJsonCoder.decode(value).uint8Value
    }
    
    public static func encode(_ value: UInt8) throws -> IQJsonValue {
        return try QNSNumberJsonCoder.encode(NSNumber(value: value))
    }
    
}

extension UInt8 : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QUInt8JsonCoder
    public typealias JsonEncoder = QUInt8JsonCoder
    
}
