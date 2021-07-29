//
//  libQuicklyRemoteImageView
//

import Foundation
import libQuicklyCore
import libQuicklyView

public protocol IQRemoteImageFilter : AnyObject {
    
    var name: String { get }
    
    func apply(_ image: QImage) -> QImage?
    
}
