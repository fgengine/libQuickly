//
//  libQuicklyJson
//

import Foundation

extension Int : IQJsonValueDecodable {

    public static func fromJson(value: Any) throws -> Self {
        return try NSNumber.fromJson(value: value).intValue
    }

}

extension Int : IQJsonValueEncodable {
    
    public func toJsonValue() throws -> Any {
        return NSNumber(value: self)
    }
    
}
