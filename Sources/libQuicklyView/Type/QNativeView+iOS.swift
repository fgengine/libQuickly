//
//  libQuicklyView
//

#if os(iOS)

import UIKit

public protocol IQNativeBlendingView : AnyObject {
    
    func allowBlending() -> Bool
    
    func updateBlending(superview: QNativeView)
    
}

public typealias QNativeView = UIView & IQNativeBlendingView

extension UIView {
    
    public func updateBlending() {
        guard let superview = self as? QNativeView else { return }
        for view in self.subviews {
            guard let view = view as? QNativeView else { continue }
            view.updateBlending(superview: superview)
        }
    }
    
}

#endif
