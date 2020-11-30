//
//  libQuicklyJson
//

import Foundation

extension Double : IQJsonValueDecodable {

    public static func fromJson(value: Any) throws -> Self {
        return try NSNumber.fromJson(value: value).doubleValue
    }

}

extension Double : IQJsonValueEncodable {
    
    public func toJsonValue() throws -> Any {
        return NSNumber(value: self)
    }
    
}
