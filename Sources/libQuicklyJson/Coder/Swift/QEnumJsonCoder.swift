//
//  libQuicklyJson
//

import Foundation
import libQuicklyCore

public struct QEnumJsonDecoder< Enum : IQEnumDecodable > : IQJsonValueDecoder where Enum.RawValue : IQJsonDecoderAlias, Enum.RawValue == Enum.RawValue.JsonDecoder.Value {
    
    public static func decode(_ value: IQJsonValue) throws -> Enum.RealValue {
        guard let rawValue = try? Enum.RawValue.JsonDecoder.decode(value) else { throw QJsonError.cast }
        guard let decoded = Enum(rawValue: rawValue) else { throw QJsonError.cast }
        return decoded.realValue
    }
    
}

public struct QEnumJsonEncoder< Enum : IQEnumEncodable > : IQJsonValueEncoder where Enum.RawValue : IQJsonEncoderAlias, Enum.RawValue == Enum.RawValue.JsonEncoder.Value {
    
    public static func encode(_ value: Enum.RealValue) throws -> IQJsonValue {
        let encoded = Enum(realValue: value)
        return try Enum.RawValue.JsonEncoder.encode(encoded.rawValue)
    }
    
}
