//
//  libQuicklyCode
//

import Foundation

public typealias IQEnumCodable = IQEnumDecodable & IQEnumEncodable

public protocol IQEnumDecodable : RawRepresentable {
    
    associatedtype RealValue
    
    var realValue: RealValue { get }
    
}

public protocol IQEnumEncodable : RawRepresentable {
    
    associatedtype RealValue
    
    init(realValue: RealValue)
    
}
