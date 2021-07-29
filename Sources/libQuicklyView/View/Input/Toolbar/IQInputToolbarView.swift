//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

public protocol IQInputToolbarItem {
    
    var barItem: UIBarButtonItem { get }
    
    func pressed()
    
}

public protocol IQInputToolbarView : IQAccessoryView, IQViewColorable {
    
    var items: [IQInputToolbarItem] { set get }
    
    var size: Float { set get }
    
    var isTranslucent: Bool { set get }
    
    var tintColor: QColor? { set get }
    
    var contentTintColor: QColor { set get }
    
    @discardableResult
    func items(_ value: [IQInputToolbarItem]) -> Self
    
    @discardableResult
    func size(_ value: Float) -> Self
    
    @discardableResult
    func translucent(_ value: Bool) -> Self
    
    @discardableResult
    func tintColor(_ value: QColor?) -> Self
    
    @discardableResult
    func contentTintColor(_ value: QColor) -> Self
    
}

#endif
