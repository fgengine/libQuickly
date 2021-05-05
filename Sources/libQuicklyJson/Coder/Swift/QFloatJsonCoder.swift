//
//  libQuicklyJson
//

import Foundation

public struct QFloatJsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> Float {
        return try QNSNumberJsonCoder.decode(value).floatValue
    }
    
    public static func encode(_ value: Float) throws -> IQJsonValue {
        return try QNSNumberJsonCoder.encode(NSNumber(value: value))
    }
    
}

extension Float : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QFloatJsonCoder
    public typealias JsonEncoder = QFloatJsonCoder
    
}
