//
//  libQuicklyView
//

#if os(OSX)

import AppKit

public struct QImage {

    public var native: NSImage
    public var size: QSize
    
    @inlinable
    public init(
        name: String
    ) {
        guard let image = NSImage(named: name) else {
            fatalError("Not found image with '\(name)'")
        }
        self.native = image
        self.size = QSize(image.size)
    }
    
    @inlinable
    public init(
        _ native: NSImage
    ) {
        self.native = native
        self.size = QSize(native.size)
    }
    
}

#endif
