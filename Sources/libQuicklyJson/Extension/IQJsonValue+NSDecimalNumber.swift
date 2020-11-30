//
//  libQuicklyJson
//

import Foundation
import libQuicklyCore

extension NSDecimalNumber {

    @objc
    public override class func fromJson(value: Any) throws -> NSDecimalNumber {
        if let decimalNumber = value as? NSDecimalNumber {
            return decimalNumber
        } else if let string = value as? String, let decimalNumber = NSDecimalNumber.decimalNumber(from: string) {
            return decimalNumber
        } else if let number = value as? NSNumber {
            return NSDecimalNumber(string: number.stringValue)
        }
        throw QJsonError.cast
    }
    
    @objc
    public override func toJsonValue() throws -> Any {
        return self
    }
    
}
