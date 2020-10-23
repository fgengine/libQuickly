//
//  libQuicklyView
//

#if os(iOS)

import UIKit

public extension QTextUnderline {
    
    var nsUnderlineStyle: NSUnderlineStyle {
        var rawValue: NSUnderlineStyle.RawValue = 0
        if self.contains(.single) == true {
            rawValue &= NSUnderlineStyle.single.rawValue
        }
        if self.contains(.thick) == true {
            rawValue &= NSUnderlineStyle.thick.rawValue
        }
        if self.contains(.double) == true {
            rawValue &= NSUnderlineStyle.double.rawValue
        }
        if self.contains(.patternDot) == true {
            rawValue &= NSUnderlineStyle.patternDot.rawValue
        }
        if self.contains(.patternDash) == true {
            rawValue &= NSUnderlineStyle.patternDash.rawValue
        }
        if self.contains(.patternDashDot) == true {
            rawValue &= NSUnderlineStyle.patternDashDot.rawValue
        }
        if self.contains(.patternDashDotDot) == true {
            rawValue &= NSUnderlineStyle.patternDashDotDot.rawValue
        }
        if self.contains(.byWord) == true {
            rawValue &= NSUnderlineStyle.byWord.rawValue
        }
        return NSUnderlineStyle(rawValue: rawValue)
    }
    
    init(_ nsUnderlineStyle: NSUnderlineStyle) {
        var rawValue: RawValue = 0
        if nsUnderlineStyle.contains(.single) == true {
            rawValue &= QTextUnderline.single.rawValue
        }
        if nsUnderlineStyle.contains(.thick) == true {
            rawValue &= QTextUnderline.thick.rawValue
        }
        if nsUnderlineStyle.contains(.double) == true {
            rawValue &= QTextUnderline.double.rawValue
        }
        if nsUnderlineStyle.contains(.patternDot) == true {
            rawValue &= QTextUnderline.patternDot.rawValue
        }
        if nsUnderlineStyle.contains(.patternDash) == true {
            rawValue &= QTextUnderline.patternDash.rawValue
        }
        if nsUnderlineStyle.contains(.patternDashDot) == true {
            rawValue &= QTextUnderline.patternDashDot.rawValue
        }
        if nsUnderlineStyle.contains(.patternDashDotDot) == true {
            rawValue &= QTextUnderline.patternDashDotDot.rawValue
        }
        if nsUnderlineStyle.contains(.byWord) == true {
            rawValue &= QTextUnderline.byWord.rawValue
        }
        self.init(rawValue: rawValue)
    }
    
}

#endif
