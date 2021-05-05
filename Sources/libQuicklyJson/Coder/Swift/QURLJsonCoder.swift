//
//  libQuicklyJson
//

import Foundation

public struct QURLJsonCoder : IQJsonValueCoder {
    
    public static func decode(_ value: IQJsonValue) throws -> URL {
        let string = try QNSStringJsonCoder.decode(value)
        if let url = URL(string: string as String) {
            return url
        }
        throw QJsonError.cast
    }
    
    public static func encode(_ value: URL) throws -> IQJsonValue {
        return value.absoluteString as NSString
    }
    
}

extension URL : IQJsonCoderAlias {
    
    public typealias JsonDecoder = QURLJsonCoder
    public typealias JsonEncoder = QURLJsonCoder
    
}
