//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQAccessoryView : IQBaseView {
    
    var parentView: IQView? { get }
    
    func appear(to view: IQView)
    
}
