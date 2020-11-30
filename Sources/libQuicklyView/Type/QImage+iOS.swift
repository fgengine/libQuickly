//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

public struct QImage {

    public var native: UIImage
    public var size: QSize
    
    @inlinable
    public init(
        name: String
    ) {
        guard let image = UIImage(named: name) else {
            fatalError("Not found image with '\(name)'")
        }
        self.native = image
        self.size = QSize(image.size)
    }
    
    @inlinable
    public init(
        _ native: UIImage
    ) {
        self.native = native
        self.size = QSize(native.size)
    }
    
}

#endif
