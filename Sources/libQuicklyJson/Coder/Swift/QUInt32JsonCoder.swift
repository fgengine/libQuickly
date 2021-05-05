//
//  libQuicklyJson
//

import Foundation

public struct QUInt32JsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> UInt32 {
        return try QNSNumberJsonCoder.decode(value).uint32Value
    }
    
    public static func encode(_ value: UInt32) throws -> IQJsonValue {
        return try QNSNumberJsonCoder.encode(NSNumber(value: value))
    }
    
}

extension UInt32 : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QUInt32JsonCoder
    public typealias JsonEncoder = QUInt32JsonCoder
    
}
