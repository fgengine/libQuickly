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

public struct QNonEmptyStringJsonDecoder : IQJsonValueDecoder {
    
    public static func decode(_ value: IQJsonValue) throws -> String {
        let string = try QStringJsonCoder.decode(value)
        if string.isEmpty == true {
            throw QJsonError.cast
        }
        return string
    }
    
}

extension String : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QStringJsonCoder
    public typealias JsonEncoder = QStringJsonCoder
    
}
