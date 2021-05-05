//
//  libQuicklyJson
//

import Foundation

public struct QUInt64JsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> UInt64 {
        return try QNSNumberJsonCoder.decode(value).uint64Value
    }
    
    public static func encode(_ value: UInt64) throws -> IQJsonValue {
        return try QNSNumberJsonCoder.encode(NSNumber(value: value))
    }
    
}

extension UInt64 : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QUInt64JsonCoder
    public typealias JsonEncoder = QUInt64JsonCoder
    
}
