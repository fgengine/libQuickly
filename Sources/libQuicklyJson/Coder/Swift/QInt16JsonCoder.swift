//
//  libQuicklyJson
//

import Foundation

public struct QInt16JsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> Int16 {
        return try QNSNumberJsonCoder.decode(value).int16Value
    }
    
    public static func encode(_ value: Int16) throws -> IQJsonValue {
        return try QNSNumberJsonCoder.encode(NSNumber(value: value))
    }
    
}

extension Int16 : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QInt16JsonCoder
    public typealias JsonEncoder = QInt16JsonCoder
    
}
