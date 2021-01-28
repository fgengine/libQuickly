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
    var indicatorView: IQView { get }
    var views: [IQView] { get }
    var selectedView: IQView? { get }
    
    @discardableResult
    func indicatorView(_ value: IQView) -> Self
    
    @discardableResult
    func views(_ value: [IQView]) -> Self
    
    @discardableResult
    func selectedView(_ value: IQView?) -> Self
    
    func beginTransition()
    
    func changeTransition(to view: IQView, progress: QFloat)
    
    func finishTransition(to view: IQView)
    
    func cancelTransition()

}
