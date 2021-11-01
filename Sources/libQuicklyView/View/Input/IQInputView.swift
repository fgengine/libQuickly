//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQInputView : IQView {
    
    var isEditing: Bool { get }
    
    @discardableResult
    func startEditing() -> Self
    
    @discardableResult
    func endEditing() -> Self
    
}
