//
//  libQuicklyJson
//

import Foundation

public typealias IQJsonValueCoder = IQJsonValueDecoder & IQJsonValueEncoder

public protocol IQJsonValueDecoder {
    
    associatedtype Value
    
    static func decode(_ value: IQJsonValue) throws -> Value

}

public protocol IQJsonValueEncoder {
    
    associatedtype Value

    static func encode(_ value: Value) throws -> IQJsonValue

}
