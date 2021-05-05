//
//  libQuicklyJson
//

import Foundation

public typealias IQJsonCoderAlias = IQJsonDecoderAlias & IQJsonEncoderAlias

public protocol IQJsonDecoderAlias {
    
    associatedtype JsonDecoder : IQJsonValueDecoder
    
}

public protocol IQJsonEncoderAlias {
    
    associatedtype JsonEncoder : IQJsonValueEncoder
    
}
