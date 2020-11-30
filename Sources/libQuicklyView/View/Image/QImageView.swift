//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

open class QImageView : IQView {
    
    public private(set) weak var parentLayout: IQLayout?
    public weak var item: IQLayoutItem?
    public var width: QDimensionBehaviour? {
        didSet {
            guard self.isLoaded == true else { return }
            self.parentLayout?.setNeedUpdate()
        }
    }
    public var height: QDimensionBehaviour? {
        didSet {
            guard self.isLoaded == true else { return }
            self.parentLayout?.setNeedUpdate()
        }
    }
    public var image: QImage {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qImage = self.image
            self.parentLayout?.setNeedUpdate()
        }
    }
    public var mode: Mode {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qMode = self.mode
        }
    }
    public var alpha: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qAlpha = self.alpha
        }
    }
    public var isLoaded: Bool {
        return self._reuseView.isLoaded
    }
    public var isAppeared: Bool {
        guard self.isLoaded == true else { return false }
        return self._view.qIsAppeared
    }
    public var native: QNativeView {
        return self._view
    }

    private var _view: ImageView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _reuseView: QReuseView< ImageView >
    
    public init(
        width: QDimensionBehaviour? = nil,
        height: QDimensionBehaviour? = nil,
        alpha: QFloat = 1,
        image: QImage,
        mode: Mode = .aspectFit
    ) {
        self.width = width
        self.height = height
        self.image = image
        self.mode = mode
        self.alpha = alpha
        self._reuseView = QReuseView()
    }
    
    public func onAppear(to layout: IQLayout) {
        self.parentLayout = layout
    }
    
    public func onDisappear() {
        self._reuseView.unload(view: self)
        self.parentLayout = nil
    }
    
    public func size(_ available: QSize) -> QSize {
        if let width = self.width, let height = self.height {
            return available.apply(width: width, height: height)
        } else if let width = self.width {
            return self.mode.size(
                size: self.image.size,
                available: QSize(
                    width: available.width.apply(width),
                    height: .infinity
                )
            )
        } else if let height = self.height {
            return self.mode.size(
                size: self.image.size,
                available: QSize(
                    width: .infinity,
                    height: available.height.apply(height)
                )
            )
        }
        return self.mode.size(size: self.image.size, available: available)
    }

}

public extension QImageView {
    
    enum Mode {
        case origin
        case aspectFit
        case aspectFill
    }
    
}

public extension QImageView.Mode {

    func size(size: QSize, available: QSize) -> QSize {
        switch self {
        case .origin:
            return size
        case .aspectFit:
            if available.isInfinite == true {
                return size
            } else if available.width.isInfinite == true {
                let aspectRatio = size.aspectRatio
                return QSize(
                    width: available.height * aspectRatio,
                    height: available.height
                )
            } else if available.height.isInfinite == true {
                let aspectRatio = size.aspectRatio
                return QSize(
                    width: available.width,
                    height: available.width / aspectRatio
                )
            }
            return size.aspectFit(size: available)
        case .aspectFill:
            if available.isInfinite == true {
                return size
            } else if available.width.isInfinite == true {
                let aspectRatio = size.aspectRatio
                return QSize(
                    width: available.height * aspectRatio,
                    height: available.height
                )
            } else if available.height.isInfinite == true {
                let aspectRatio = size.aspectRatio
                return QSize(
                    width: available.width,
                    height: available.width / aspectRatio
                )
            }
            return size.aspectFill(size: available)
        }
    }

}
