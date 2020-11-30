//
//  libQuicklyJson
//

import Foundation

public protocol IQJsonEnumDecodable : RawRepresentable {
    
    associatedtype RealValue
    
    var realValue: RealValue { get }
    
}

public protocol IQJsonEnumEncodable : RawRepresentable {
    
    associatedtype RealValue
    
    init(realValue: RealValue)
    
}
