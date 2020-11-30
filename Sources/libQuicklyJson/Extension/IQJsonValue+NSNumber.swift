//
//  libQuicklyJson
//

import Foundation
import libQuicklyCore

extension NSNumber : IQJsonValueDecodable {

    @objc
    public class func fromJson(value: Any) throws -> NSNumber {
        if let number = value as? NSNumber {
            return number
        } else if let string = value as? String, let number = NSNumber.number(from: string) {
            return number
        }
        throw QJsonError.cast
    }

}

extension NSNumber : IQJsonValueEncodable {
    
    @objc
    public func toJsonValue() throws -> Any {
        return self
    }
    
}
