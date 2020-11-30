//
//  libQuicklyJson
//

import Foundation
import libQuicklyCore

extension Date : IQJsonValueDecodable {

    public static func fromJson(value: Any) throws -> Self {
        let number = try NSNumber.fromJson(value: value)
        return Date(timeIntervalSince1970: number.doubleValue)
    }

}

extension Date : IQJsonValueEncodable {
    
    public func toJsonValue() throws -> Any {
        return NSNumber(value: Int(self.timeIntervalSince1970))
    }
    
}
