//
//  libQuicklyJson
//

import Foundation

public struct QUInt16JsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> UInt16 {
        return try QNSNumberJsonCoder.decode(value).uint16Value
    }
    
    public static func encode(_ value: UInt16) throws -> IQJsonValue {
        return try QNSNumberJsonCoder.encode(NSNumber(value: value))
    }
    
}

extension UInt16 : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QUInt16JsonCoder
    public typealias JsonEncoder = QUInt16JsonCoder
    
}
