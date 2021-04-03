//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension UIScreen {
    
    var animationVelocity: QFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: return QFloat(max(self.bounds.width, self.bounds.height) * 2.2)
        case .pad: return QFloat(max(self.bounds.width, self.bounds.height) * 2.5)
        default: return 100
        }
    }
    
}

#endif
