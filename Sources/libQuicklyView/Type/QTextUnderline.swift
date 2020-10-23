//
//  libQuicklyView
//

import Foundation

public struct QTextUnderline : OptionSet {
    
    public var rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static var single: QTextUnderline = QTextUnderline(rawValue: 1 << 0)
    public static var thick: QTextUnderline = QTextUnderline(rawValue: 1 << 1)
    public static var double: QTextUnderline = QTextUnderline(rawValue: 1 << 2)
    public static var patternDot: QTextUnderline = QTextUnderline(rawValue: 1 << 3)
    public static var patternDash: QTextUnderline = QTextUnderline(rawValue: 1 << 4)
    public static var patternDashDot: QTextUnderline = QTextUnderline(rawValue: 1 << 5)
    public static var patternDashDotDot: QTextUnderline = QTextUnderline(rawValue: 1 << 6)
    public static var byWord: QTextUnderline = QTextUnderline(rawValue: 1 << 7)
    
}
