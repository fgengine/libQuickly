//
//  libQuicklyRemoteImageView
//

import Foundation
import libQuicklyCore
import libQuicklyView

public class QRemoteImageTarget {
    
    public let onProgress: ((_ progress: Float) -> Void)?
    public let onImage: ((_ image: QImage) -> Void)?
    public let onError: ((_ error: Error) -> Void)?
    
    public init(
        onProgress: ((_ progress: Float) -> Void)? = nil,
        onImage: ((_ image: QImage) -> Void)? = nil,
        onError: ((_ error: Error) -> Void)? = nil
    ) {
        self.onProgress = onProgress
        self.onImage = onImage
        self.onError = onError
    }
    
}

extension QRemoteImageTarget : IQRemoteImageTarget {
    
    public func remoteImage(progress: Float) {
        self.onProgress?(progress)
    }
    
    public func remoteImage(image: QImage) {
        self.onImage?(image)
    }
    
    public func remoteImage(error: Error) {
        self.onError?(error)
    }
    
}
