//
//  libQuicklyRemoteImageView
//

import Foundation
import libQuicklyCore
import libQuicklyView

public class QThumbnailImageFilter : IQRemoteImageFilter {

    public let size: QSize
    public var name: String {
        return "\(self.size.width)x\(self.size.height)"
    }
    
    public init(_ size: QSize) {
        self.size = size
    }
    
    public func apply(_ image: QImage) -> QImage? {
        return image.scaleTo(size: self.size)
    }
    
}
