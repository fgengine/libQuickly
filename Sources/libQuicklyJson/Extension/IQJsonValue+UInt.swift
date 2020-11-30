//
//  libQuicklyJson
//

import Foundation

extension UInt : IQJsonValueDecodable {

    public static func fromJson(value: Any) throws -> Self {
        return try NSNumber.fromJson(value: value).uintValue
    }

}

extension UInt : IQJsonValueEncodable {
    
    public func toJsonValue() throws -> Any {
        return NSNumber(value: self)
    }
    
}
