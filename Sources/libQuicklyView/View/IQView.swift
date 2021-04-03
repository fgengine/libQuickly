//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQView : IQBaseView {
    
    var parentLayout: IQLayout? { get }
    var item: QLayoutItem? { set get }
    
    func appear(to layout: IQLayout)
    
}
