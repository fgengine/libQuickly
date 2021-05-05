//
//  libQuicklyJson
//

import Foundation

public struct QInt32JsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> Int32 {
        return try QNSNumberJsonCoder.decode(value).int32Value
    }
    
    public static func encode(_ value: Int32) throws -> IQJsonValue {
        return try QNSNumberJsonCoder.encode(NSNumber(value: value))
    }
    
}

extension Int32 : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QInt32JsonCoder
    public typealias JsonEncoder = QInt32JsonCoder
    
}
