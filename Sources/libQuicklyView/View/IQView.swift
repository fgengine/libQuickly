//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQView : IQBaseView {
    
    var isAppeared: Bool { get }
    var layout: IQLayout? { get }
    var item: QLayoutItem? { set get }
    
    func appear(to layout: IQLayout)
    
}

public extension IQView {
    
    @inlinable
    var isAppeared: Bool {
        return self.layout != nil
    }
    
    @inlinable
    func setNeedForceUpdate() {
        if let item = self.item {
            self.layout?.setNeedForceUpdate(item: item)
        } else {
            self.layout?.setNeedForceUpdate()
        }
    }
    
    @inlinable
    func setNeedUpdate() {
        self.layout?.setNeedUpdate()
    }

}
