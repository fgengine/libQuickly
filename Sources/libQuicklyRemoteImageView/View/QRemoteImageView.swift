//
//  libQuicklyRemoteImageView
//

import Foundation
import libQuicklyCore
import libQuicklyView

public class QRemoteImageView : IQRemoteImageView {
    
    public var layout: IQLayout? {
        get { return self._view.layout }
    }
    public unowned var item: QLayoutItem? {
        set(value) { self._view.item = value }
        get { return self._view.item }
    }
    public var native: QNativeView {
        return self._view.native
    }
    public var isLoaded: Bool {
        return self._view.isLoaded
    }
    public var bounds: QRect {
        return self._view.bounds
    }
    public private(set) var isLoading: Bool
    public private(set) var imageView: IQImageView {
        didSet(oldValue) {
            guard self.imageView !== oldValue else { return }
            self._layout.imageItem = QLayoutItem(view: self.imageView)
        }
    }
    public private(set) var progressView: IQProgressView? {
        didSet(oldValue) {
            guard self.progressView !== oldValue else { return }
            self._layout.progressItem = self.progressView.flatMap({ QLayoutItem(view: $0) })
        }
    }
    public private(set) var errorView: IQView? {
        didSet(oldValue) {
            guard self.errorView !== oldValue else { return }
            self._layout.errorItem = self.errorView.flatMap({ QLayoutItem(view: $0) })
        }
    }
    public private(set) var loader: QRemoteImageLoader
    public private(set) var query: IQRemoteImageQuery
    public private(set) var filter: IQRemoteImageFilter?
    public var color: QColor? {
        set(value) { self._view.color = value }
        get { return self._view.color }
    }
    public var border: QViewBorder {
        set(value) { self._view.border = value }
        get { return self._view.border }
    }
    public var cornerRadius: QViewCornerRadius {
        set(value) { self._view.cornerRadius = value }
        get { return self._view.cornerRadius }
    }
    public var shadow: QViewShadow? {
        set(value) { self._view.shadow = value }
        get { return self._view.shadow }
    }
    public var alpha: Float {
        set(value) { self._view.alpha = value }
        get { return self._view.alpha }
    }
    
    private var _layout: Layout
    private var _view: QCustomView< Layout >
    private var _onProgress: ((_ progress: Float) -> Void)?
    private var _onFinish: ((_ image: QImage) -> Void)?
    private var _onError: ((_ error: Error) -> Void)?
    
    public init(
        imageView: IQImageView,
        progressView: IQProgressView? = nil,
        errorView: IQView? = nil,
        loader: QRemoteImageLoader = QRemoteImageLoader.shared,
        query: IQRemoteImageQuery,
        filter: IQRemoteImageFilter? = nil,
        color: QColor? = QColor(rgba: 0x00000000),
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1
    ) {
        self.isLoading = false
        self.imageView = imageView
        self.progressView = progressView
        self.loader = loader
        self.query = query
        self.filter = filter
        self._layout = Layout(
            state: .loading,
            imageItem: QLayoutItem(view: imageView),
            progressItem: progressView.flatMap({ QLayoutItem(view: $0) }),
            errorItem: errorView.flatMap({ QLayoutItem(view: $0) })
        )
        self._view = QCustomView(
            contentLayout: self._layout,
            color: color,
            border: border,
            cornerRadius: cornerRadius,
            shadow: shadow,
            alpha: alpha
        )
    }
    
    public func size(_ available: QSize) -> QSize {
        return self._view.size(available)
    }
    
    public func appear(to layout: IQLayout) {
        self._view.appear(to: layout)
    }
    
    public func disappear() {
        self._view.disappear()
    }
    
    @discardableResult
    public func startLoading() -> Self {
        self._start()
        return self
    }
    
    @discardableResult
    public func stopLoading() -> Self {
        self._stop()
        return self
    }
    
    @discardableResult
    public func imageView(_ value: IQImageView) -> Self {
        self.imageView = value
        return self
    }
    
    @discardableResult
    public func progressView(_ value: IQProgressView?) -> Self {
        self.progressView = value
        return self
    }
    
    @discardableResult
    public func errorView(_ value: IQView?) -> Self {
        self.errorView = value
        return self
    }
    
    @discardableResult
    public func query(_ value: IQRemoteImageQuery) -> Self {
        self.query = value
        return self
    }
    
    @discardableResult
    public func filter(_ value: IQRemoteImageFilter?) -> Self {
        self.filter = value
        return self
    }
    
    @discardableResult
    public func color(_ value: QColor?) -> Self {
        self._view.color(value)
        return self
    }
    
    @discardableResult
    public func border(_ value: QViewBorder) -> Self {
        self._view.border(value)
        return self
    }
    
    @discardableResult
    public func cornerRadius(_ value: QViewCornerRadius) -> Self {
        self._view.cornerRadius(value)
        return self
    }
    
    @discardableResult
    public func shadow(_ value: QViewShadow?) -> Self {
        self._view.shadow(value)
        return self
    }
    
    @discardableResult
    public func alpha(_ value: Float) -> Self {
        self._view.alpha(value)
        return self
    }
    
    @discardableResult
    public func onAppear(_ value: (() -> Void)?) -> Self {
        self._view.onAppear(value)
        return self
    }
    
    @discardableResult
    public func onDisappear(_ value: (() -> Void)?) -> Self {
        self._view.onDisappear(value)
        return self
    }
    
    @discardableResult
    public func onProgress(_ value: ((_ progress: Float) -> Void)?) -> Self {
        self._onProgress = value
        return self
    }
    
    @discardableResult
    public func onFinish(_ value: ((_ image: QImage) -> Void)?) -> Self {
        self._onFinish = value
        return self
    }
    
    @discardableResult
    public func onError(_ value: ((_ error: Error) -> Void)?) -> Self {
        self._onError = value
        return self
    }
    
}

private extension QRemoteImageView {
    
    func _start() {
        if self.isLoading == false {
            self.isLoading = true
            self._layout.state = .loading
            self.progressView?.progress(0)
            self.loader.download(
                query: self.query,
                filter: self.filter,
                target: self
            )
        }
    }

    func _stop() {
        if self.isLoading == true {
            self.isLoading = false
            self.loader.cancel(target: self)
        }
    }

}

private extension QRemoteImageView {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var state: State {
            didSet(oldValue) {
                guard self.state != oldValue else { return }
                self.setNeedUpdate()
            }
        }
        var imageItem: QLayoutItem {
            didSet { self.setNeedForceUpdate() }
        }
        var progressItem: QLayoutItem? {
            didSet { self.setNeedForceUpdate() }
        }
        var errorItem: QLayoutItem? {
            didSet { self.setNeedForceUpdate() }
        }

        init(
            state: State,
            imageItem: QLayoutItem,
            progressItem: QLayoutItem?,
            errorItem: QLayoutItem?
        ) {
            self.state = state
            self.imageItem = imageItem
            self.progressItem = progressItem
            self.errorItem = errorItem
        }
        
        func layout(bounds: QRect) -> QSize {
            switch self.state {
            case .loading:
                let imageSize = self.imageItem.size(bounds.size)
                if let progressItem = self.progressItem {
                    let progressSize = progressItem.size(bounds.size)
                    self.imageItem.frame = QRect(
                        x: bounds.origin.x,
                        y: bounds.origin.y,
                        width: imageSize.width,
                        height: imageSize.height
                    )
                    progressItem.frame = QRect(
                        center: self.imageItem.frame.center,
                        size: progressSize
                    )
                    return QSize(
                        width: max(progressSize.width, imageSize.height),
                        height: max(progressSize.height, imageSize.height)
                    )
                }
                self.imageItem.frame = QRect(
                    x: bounds.origin.x,
                    y: bounds.origin.y,
                    width: imageSize.width,
                    height: imageSize.height
                )
                return imageSize
            case .loaded:
                let imageSize = self.imageItem.size(bounds.size)
                self.imageItem.frame = QRect(
                    x: bounds.origin.x,
                    y: bounds.origin.y,
                    width: imageSize.width,
                    height: imageSize.height
                )
                return imageSize
            case .error:
                if let errorItem = self.errorItem {
                    let errorSize = errorItem.size(bounds.size)
                    errorItem.frame = QRect(
                        x: bounds.origin.x,
                        y: bounds.origin.y,
                        width: errorSize.width,
                        height: errorSize.height
                    )
                    return errorSize
                }
                let imageSize = self.imageItem.size(bounds.size)
                self.imageItem.frame = QRect(
                    x: bounds.origin.x,
                    y: bounds.origin.y,
                    width: imageSize.width,
                    height: imageSize.height
                )
                return imageSize
            }
        }
        
        func size(_ available: QSize) -> QSize {
            switch self.state {
            case .loading:
                let imageSize = self.imageItem.size(available)
                if let progressItem = self.progressItem {
                    let progressSize = progressItem.size(available)
                    return QSize(
                        width: max(progressSize.width, imageSize.height),
                        height: max(progressSize.height, imageSize.height)
                    )
                }
                return imageSize
            case .loaded:
                return self.imageItem.size(available)
            case .error:
                if let errorItem = self.errorItem {
                    return errorItem.size(available)
                }
                return self.imageItem.size(available)
            }
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            switch self.state {
            case .loading:
                if let progressItem = self.progressItem {
                    return [ self.imageItem, progressItem ]
                }
                return [ self.imageItem ]
            case .loaded:
                return [ self.imageItem ]
            case .error:
                if let errorItem = self.errorItem {
                    return [ errorItem ]
                }
                return [ self.imageItem ]
            }
        }
        
    }
    
}

private extension QRemoteImageView.Layout {
    
    enum State {
        case loading
        case loaded
        case error
    }
    
}

extension QRemoteImageView : IQRemoteImageTarget {
    
    public func remoteImage(progress: Float) {
        self.progressView?.progress(progress)
        self._onProgress?(progress)
    }
    
    public func remoteImage(image: QImage) {
        self.isLoading = false
        self._layout.state = .loaded
        self.imageView.image(image)
        self._onFinish?(image)
    }
    
    public func remoteImage(error: Error) {
        self.isLoading = false
        self._layout.state = .error
        self._onError?(error)
    }
    
}
