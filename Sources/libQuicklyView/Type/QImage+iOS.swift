//
//  libQuicklyView
//

import libQuicklyCore

#if os(iOS)

import UIKit

public struct QImage {

    public var native: UIImage
    public var size: QSize
    
    @inlinable
    public init(
        name: String,
        renderingMode: UIImage.RenderingMode? = nil
    ) {
        guard let image = UIImage(named: name) else {
            fatalError("Not found image with '\(name)'")
        }
        if let renderingMode = renderingMode {
            self.native = image.withRenderingMode(renderingMode)
        } else {
            self.native = image
        }
        self.size = QSize(image.size)
    }
    
    @inlinable
    public init?(
        data: Data,
        renderingMode: UIImage.RenderingMode? = nil
    ) {
        guard let image = UIImage(data: data) else { return nil }
        if let renderingMode = renderingMode {
            self.native = image.withRenderingMode(renderingMode)
        } else {
            self.native = image
        }
        self.size = QSize(image.size)
    }
    
    @inlinable
    public init?(
        url: URL,
        renderingMode: UIImage.RenderingMode? = nil
    ) {
        guard let image = UIImage(contentsOfFile: url.path) else { return nil }
        if let renderingMode = renderingMode {
            self.native = image.withRenderingMode(renderingMode)
        } else {
            self.native = image
        }
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
    
    public init?(size: QSize, scale: Float? = nil, color: QColor) {
        let realScale = scale ?? Float(UIScreen.main.scale)
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
        self.size = QSize(width: Float(image.width), height: Float(image.height))
    }
    
}

public extension QImage {
    
    func pngData() -> Data? {
        return self.native.pngData()
    }
    
    func withRenderingMode(renderingMode: UIImage.RenderingMode) -> QImage {
        return QImage(self.native.withRenderingMode(renderingMode))
    }
    
    func unrotate(maxResolution: Float) -> QImage {
        guard let imgRef = self.native.cgImage else {
            return self
        }
        let width = CGFloat(imgRef.width);
        let height = CGFloat(imgRef.height);
        var bounds = CGRect(x: 0, y: 0, width: width, height: height)
        var scaleRatio : CGFloat = 1
        if width > CGFloat(maxResolution) || height > CGFloat(maxResolution) {
            scaleRatio = min(CGFloat(maxResolution) / bounds.size.width, CGFloat(maxResolution) / bounds.size.height)
            bounds.size.height = bounds.size.height * scaleRatio
            bounds.size.width = bounds.size.width * scaleRatio
        }
        let orientation = self.native.imageOrientation
        var transform = CGAffineTransform.identity
        let imageSize = CGSize(width: CGFloat(imgRef.width), height: CGFloat(imgRef.height))
        switch orientation {
        case .up:
            transform = CGAffineTransform.identity
        case .upMirrored:
            transform = CGAffineTransform(translationX: imageSize.width, y: 0.0)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
        case .down:
            transform = CGAffineTransform(translationX: imageSize.width, y: imageSize.height)
            transform = transform.rotated(by: .pi)
        case .downMirrored:
            transform = CGAffineTransform(translationX: 0.0, y: imageSize.height)
            transform = transform.scaledBy(x: 1.0, y: -1.0)
        case .left:
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = storedHeight
            transform = CGAffineTransform(translationX: 0.0, y: imageSize.width)
            transform = transform.rotated(by: 3.0 * .pi / 2.0)
        case .leftMirrored:
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = storedHeight
            transform = CGAffineTransform(translationX: imageSize.height, y: imageSize.width)
            transform = transform.scaledBy(x: -1.0, y: 1.0)
            transform = transform.rotated(by: 3.0 * .pi / 2.0)
        case .right:
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = storedHeight
            transform = CGAffineTransform(translationX: imageSize.height, y: 0.0)
            transform = transform.rotated(by: .pi / 2.0)
        case .rightMirrored:
            let storedHeight = bounds.size.height
            bounds.size.height = bounds.size.width
            bounds.size.width = storedHeight
            transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            transform = transform.rotated(by: .pi / 2.0)
        @unknown default:
            fatalError()
        }
        UIGraphicsBeginImageContext(bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else {
            return self
        }
        if orientation == .right || orientation == .left {
            context.scaleBy(x: -scaleRatio, y: scaleRatio)
            context.translateBy(x: -height, y: 0)
        } else {
            context.scaleBy(x: scaleRatio, y: -scaleRatio)
            context.translateBy(x: 0, y: -height)
        }
        context.concatenate(transform)
        context.draw(imgRef, in: CGRect(x: 0, y: 0, width: width, height: height))
        guard let imageCopy = UIGraphicsGetImageFromCurrentImageContext() else {
            return self
        }
        UIGraphicsEndImageContext()
        return QImage(imageCopy)
    }
    
    func scaleTo(size: QSize) -> QImage? {
        guard let cgImage = self.native.cgImage else {
            return nil
        }
        let scale = self.native.scale
        let size = size.aspectFit(size: self.size)
        UIGraphicsBeginImageContextWithOptions(size.cgSize, false, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        if let context = UIGraphicsGetCurrentContext() {
            context.translateBy(x: 0, y: CGFloat(size.height))
            context.scaleBy(x: 1.0, y: -1.0)
            context.draw(cgImage, in: CGRect(origin: .zero, size: size.cgSize))
            if let image = context.makeImage() {
                return QImage(UIImage(cgImage: image, scale: scale, orientation: .up))
            }
        }
        return nil
    }
    
}

#endif
