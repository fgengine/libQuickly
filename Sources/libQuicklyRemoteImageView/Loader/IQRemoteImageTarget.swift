//
//  libQuicklyRemoteImageView
//

import Foundation
import libQuicklyCore
import libQuicklyView

public protocol IQRemoteImageTarget : AnyObject {
    
    func remoteImage(progress: Float)
    func remoteImage(image: QImage)
    func remoteImage(error: Error)
    
}
