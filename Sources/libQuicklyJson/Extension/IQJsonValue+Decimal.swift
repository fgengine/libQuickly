//
//  libQuicklyJson
//

import Foundation
import libQuicklyCore

extension Decimal : IQJsonValueDecodable {

    public static func fromJson(value: Any) throws -> Self {
        return try NSDecimalNumber.fromJson(value: value) as Decimal
    }

}

extension Decimal : IQJsonValueEncodable {
    
    public func toJsonValue() throws -> Any {
        return self as NSDecimalNumber
    }
    
}
