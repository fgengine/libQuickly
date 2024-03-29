//
//  libQuicklyView
//

#if os(iOS)

import UIKit

public typealias QNativeView = UIView

public extension UIView {
    
    func child< View >(of type: View.Type, recursive: Bool) -> View? {
        for subview in self.subviews {
            if let view = subview as? View {
                return view
            } else if recursive == true {
                if let view = subview.child(of: type, recursive: recursive) {
                    return view
                }
            }
            
        }
        return nil
    }
    
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
