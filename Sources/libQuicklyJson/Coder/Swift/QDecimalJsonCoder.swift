//
//  libQuicklyJson
//

import Foundation

public struct QDecimalJsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> Decimal {
        return try QNSDecimalNumberJsonCoder.decode(value) as Decimal
    }
    
    public static func encode(_ value: Decimal) throws -> IQJsonValue {
        return try QNSDecimalNumberJsonCoder.encode(NSDecimalNumber(decimal: value))
    }
    
}

extension Decimal : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QDecimalJsonCoder
    public typealias JsonEncoder = QDecimalJsonCoder
    
}
