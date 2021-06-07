//
//  libQuicklyCode
//

import Foundation

public protocol IQEnumLocalized : RawRepresentable where RawValue == String {
}

public extension IQEnumLocalized {
    
    var localized: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
    
}
