//
//  libQuicklyJson
//

import Foundation

public protocol IQJsonValue {
}

extension NSNull : IQJsonValue {
}

extension NSString : IQJsonValue {
}

extension NSNumber : IQJsonValue {
}

extension NSArray : IQJsonValue {
}

extension NSDictionary : IQJsonValue {
}
