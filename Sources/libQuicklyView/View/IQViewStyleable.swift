//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQViewStyleable : AnyObject {
    
    func triggeredChangeStyle(_ userIteraction: Bool)
    
    @discardableResult
    func onChangeStyle(_ value: ((_ userIteraction: Bool) -> Void)?) -> Self
    
}
