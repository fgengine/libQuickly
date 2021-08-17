//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQView : IQBaseView {
    
    var isAppeared: Bool { get }
    var isVisible: Bool { get }
    var layout: IQLayout? { get }
    var item: QLayoutItem? { set get }
    
    func appear(to layout: IQLayout)
    
    func visible()
    func visibility()
    func invisible()
    
    @discardableResult
    func onVisible(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onVisibility(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onInvisible(_ value: (() -> Void)?) -> Self
    
}

public extension IQView {
    
    @inlinable
    var isAppeared: Bool {
        return self.layout != nil
    }
    
    @inlinable
    func setNeedForceLayout() {
        if let layout = self.layout {
            if let item = self.item {
                layout.setNeedForceUpdate(item: item)
            } else {
                layout.setNeedForceUpdate()
            }
        } else if let item = self.item {
            item.setNeedForceUpdate()
        }
    }
    
    @inlinable
    func setNeedLayout() {
        self.layout?.setNeedUpdate()
    }
    
    @inlinable
    func layoutIfNeeded() {
        self.layout?.updateIfNeeded()
    }
    
    func parent< View >(of type: View.Type) -> View? {
        guard let layout = self.layout else { return nil }
        guard let view = layout.view else { return nil }
        if let view = view as? View {
            return view
        }
        return view.parent(of: type)
    }

}
