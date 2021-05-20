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
    
    var items: [IQInputToolbarItem] { get }
    var size: Float { get }
    var isTranslucent: Bool { get }
    var tintColor: QColor? { get }
    var contentTintColor: QColor { get }
    
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
