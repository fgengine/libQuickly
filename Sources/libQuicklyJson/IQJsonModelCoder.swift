//
//  libQuicklyJson
//

import Foundation

public typealias IQJsonModelCoder = IQJsonModelDecoder & IQJsonModelEncoder

public protocol IQJsonModelDecoder {
    
    associatedtype Value
    
    static func decode(_ json: QJson) throws -> Value

}

public protocol IQJsonModelEncoder {
    
    associatedtype Value

    static func encode(_ model: Value, json: QJson) throws

}
