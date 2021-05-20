//
//  libQuicklyView
//

#if os(iOS)

import UIKit

public typealias QNativeView = UIView

public extension UIView {
    
    func isChild(of view: UIView, recursive: Bool) -> Bool {
        if self === view {
            return true
        }
        for subview in self.subviews {
            if subview === view {
                return true
            } else if recursive == true {
                if subview.isChild(of: view, recursive: recursive) == true {
                    return true
                }
            }
            
        }
        return false
    }
    
}

#endif
