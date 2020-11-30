//
//  libQuicklyJson
//

import Foundation

extension Float : IQJsonValueDecodable {

    public static func fromJson(value: Any) throws -> Self {
        return try NSNumber.fromJson(value: value).floatValue
    }

}

extension Float : IQJsonValueEncodable {
    
    public func toJsonValue() throws -> Any {
        return NSNumber(value: self)
    }
    
}
