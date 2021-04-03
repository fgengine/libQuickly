//
//  libQuicklyView
//

#if os(iOS)

import UIKit

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
        _ uiImage: UIImage
    ) {
        self.native = uiImage
        self.size = QSize(uiImage.size)
    }
    
    @inlinable
    public init(
        _ cgImage: CGImage
    ) {
        self.native = UIImage(cgImage: cgImage)
        self.size = QSize(native.size)
    }
    
    public init?(size: QSize, scale: QFloat? = nil, color: QColor) {
        let realScale = scale ?? QFloat(UIScreen.main.scale)
        UIGraphicsBeginImageContextWithOptions(size.cgSize, false, CGFloat(realScale))
        defer {
            UIGraphicsEndImageContext()
        }
        guard let context = UIGraphicsGetCurrentContext() else {
            return nil
        }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: CGFloat(size.width), height: CGFloat(size.height)))
        guard let image = context.makeImage() else {
            return nil
        }
        self.native = UIImage(cgImage: image)
        self.size = QSize(width: QFloat(image.width), height: QFloat(image.height))
    }
    
}

#endif
