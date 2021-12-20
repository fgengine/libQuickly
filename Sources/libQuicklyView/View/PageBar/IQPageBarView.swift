//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQPageBarViewDelegate : AnyObject {
    
    func pressed(pageBar: IQPageBarView, itemView: IQView)
    
}

public protocol IQPageBarView : IQBarView {
    
    var delegate: IQPageBarViewDelegate? { set get }
    
    var leadingView: IQView? { get }
    
    var trailingView: IQView? { get }

    var indicatorView: IQView { get }
    
    var itemInset: QInset { get }
    
    var itemSpacing: Float { get }
    
    var itemViews: [IQBarItemView] { get }
    
    var selectedItemView: IQBarItemView? { get }
    
    @discardableResult
    func leadingView(_ value: IQView?) -> Self
    
    @discardableResult
    func trailingView(_ value: IQView?) -> Self
    
    @discardableResult
    func indicatorView(_ value: IQView) -> Self
    
    @discardableResult
    func itemInset(_ value: QInset) -> Self
    
    @discardableResult
    func itemSpacing(_ value: Float) -> Self
    
    @discardableResult
    func itemViews(_ value: [IQBarItemView]) -> Self
    
    @discardableResult
    func selectedItemView(_ value: IQBarItemView?) -> Self
    
    func beginTransition()
    
    func transition(to view: IQBarItemView, progress: Float)
    
    func finishTransition(to view: IQBarItemView)
    
    func cancelTransition()

}
