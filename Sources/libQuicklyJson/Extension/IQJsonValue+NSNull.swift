//
//  libQuicklyJson
//

import Foundation

extension NSNull : IQJsonValueDecodable {

    public static func fromJson(value: Any) throws -> NSNull {
        if let null = value as? NSNull {
            return null
        }
        throw QJsonError.cast
    }

}

extension NSNull : IQJsonValueEncodable {
    
    public func toJsonValue() throws -> Any {
        return NSNull()
    }
    
}
