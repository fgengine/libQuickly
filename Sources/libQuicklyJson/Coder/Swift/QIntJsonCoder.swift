//
//  libQuicklyJson
//

import Foundation

public struct QIntJsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> Int {
        return try QNSNumberJsonCoder.decode(value).intValue
    }
    
    public static func encode(_ value: Int) throws -> IQJsonValue {
        return try QNSNumberJsonCoder.encode(NSNumber(value: value))
    }
    
}

extension Int : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QIntJsonCoder
    public typealias JsonEncoder = QIntJsonCoder
    
}
