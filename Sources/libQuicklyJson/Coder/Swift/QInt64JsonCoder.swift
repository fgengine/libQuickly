//
//  libQuicklyJson
//

import Foundation

public struct QInt64JsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> Int64 {
        return try QNSNumberJsonCoder.decode(value).int64Value
    }
    
    public static func encode(_ value: Int64) throws -> IQJsonValue {
        return try QNSNumberJsonCoder.encode(NSNumber(value: value))
    }
    
}

extension Int64 : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QInt64JsonCoder
    public typealias JsonEncoder = QInt64JsonCoder
    
}
