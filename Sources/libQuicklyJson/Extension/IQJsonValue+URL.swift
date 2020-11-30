//
//  libQuicklyJson
//

import Foundation

extension URL : IQJsonValueDecodable {

    public static func fromJson(value: Any) throws -> Self {
        if let string = value as? String, let url = URL(string: string) {
            return url
        }
        throw QJsonError.cast
    }

}

extension URL : IQJsonValueEncodable {
    
    public func toJsonValue() throws -> Any {
        return self.absoluteString
    }
    
}
