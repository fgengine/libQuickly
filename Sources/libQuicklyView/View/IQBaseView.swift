//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQBaseView : AnyObject {
    
    var native: QNativeView { get }
    var isLoaded: Bool { get }
    var bounds: QRect { get }
    
    func size(available: QSize) -> QSize
    
    func disappear()
    
    func isChild(of view: IQView, recursive: Bool) -> Bool
    
    @discardableResult
    func onAppear(_ value: (() -> Void)?) -> Self
    
    @discardableResult
    func onDisappear(_ value: (() -> Void)?) -> Self
    
}

public extension IQBaseView {
    
    func isChild(of view: IQView, recursive: Bool) -> Bool {
        guard self.isLoaded == true && view.isLoaded == true else { return false }
        return self.native.isChild(of: view.native, recursive: recursive)
    }
    
}
