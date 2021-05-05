//
//  libQuicklyJson
//

import Foundation
import libQuicklyCore

public struct QModelJsonDecoder< Model : IQJsonModelDecoder > : IQJsonValueDecoder {
    
    public static func decode(_ value: IQJsonValue) throws -> Model.Value {
        return try Model.decode(QJson(root: value))
    }
    
}

public struct QModelJsonEncoder< Model : IQJsonModelEncoder > : IQJsonValueEncoder {
    
    public static func encode(_ value: Model.Value) throws -> IQJsonValue {
        let json = QJson()
        try Model.encode(value, json: json)
        if let root = json.root {
            return root
        }
        throw QJsonError.cast
    }
    
}
