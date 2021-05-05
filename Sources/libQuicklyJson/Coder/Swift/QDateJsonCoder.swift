//
//  libQuicklyJson
//

import Foundation

public struct QDateJsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> Date {
        let number = try QNSNumberJsonCoder.decode(value)
        return Date(timeIntervalSince1970: number.doubleValue)
    }
    
    public static func encode(_ value: Date) throws -> IQJsonValue {
        return try QNSNumberJsonCoder.encode(NSNumber(value: Int(value.timeIntervalSince1970)))
    }
    
}

extension Date : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QDateJsonCoder
    public typealias JsonEncoder = QDateJsonCoder
    
}
