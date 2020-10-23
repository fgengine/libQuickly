//
//  libQuicklyView
//

import Foundation

public class QLayoutItem : IQLayoutItem {
    
    public var frame: QRect
    public private(set) var view: IQView
    
    public init(
        view: IQView
    ) {
        self.frame = QRect()
        self.view = view
        
        self.view.item = self
    }
    
    deinit {
        self.view.item = nil
    }
    
}
