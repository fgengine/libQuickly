//
//  libQuicklyJson
//

import Foundation

public struct QStringJsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> String {
        return try QNSStringJsonCoder.decode(value) as String
    }
    
    public static func encode(_ value: String) throws -> IQJsonValue {
        return try QNSStringJsonCoder.encode(NSString(string: value))
    }
    
}

extension String : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QStringJsonCoder
    public typealias JsonEncoder = QStringJsonCoder
    
}
