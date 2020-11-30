//
//  libQuicklyJson
//

import Foundation

public protocol IQJsonValueDecodable {
    
    associatedtype Value
    
    static func fromJson(value: Any) throws -> Value

}

public protocol IQJsonValueEncodable {

    func toJsonValue() throws -> Any

}
