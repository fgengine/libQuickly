//
//  libQuicklyJson
//

import Foundation

public struct QUIntJsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> UInt {
        return try QNSNumberJsonCoder.decode(value).uintValue
    }
    
    public static func encode(_ value: UInt) throws -> IQJsonValue {
        return try QNSNumberJsonCoder.encode(NSNumber(value: value))
    }
    
}

extension UInt : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QUIntJsonCoder
    public typealias JsonEncoder = QUIntJsonCoder
    
}
