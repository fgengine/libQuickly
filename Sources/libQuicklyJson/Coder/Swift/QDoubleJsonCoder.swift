//
//  libQuicklyJson
//

import Foundation

public struct QDoubleJsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> Double {
        return try QNSNumberJsonCoder.decode(value).doubleValue
    }
    
    public static func encode(_ value: Double) throws -> IQJsonValue {
        return try QNSNumberJsonCoder.encode(NSNumber(value: value))
    }
    
}

extension Double : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QDoubleJsonCoder
    public typealias JsonEncoder = QDoubleJsonCoder
    
}
