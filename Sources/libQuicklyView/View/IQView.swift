//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQView : IQBaseView {
    
    var layout: IQLayout? { get }
    var item: QLayoutItem? { set get }
    
    func appear(to layout: IQLayout)
    
}

public extension IQView {
    
    @inlinable
    func setNeedForceUpdate() {
        guard let layout = self.layout else { return }
        if let item = self.item {
            layout.setNeedForceUpdate(item: item)
        } else {
            layout.setNeedForceUpdate()
        }
    }
    
    @inlinable
    func setNeedUpdate() {
        guard let layout = self.layout else { return }
        layout.setNeedUpdate()
    }

}
