//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

open class QProgressView : IQProgressView {
    
    public private(set) weak var parentLayout: IQLayout?
    public weak var item: IQLayoutItem?
    public var width: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.parentLayout?.setNeedUpdate()
        }
    }
    public var height: QDimensionBehaviour {
        didSet {
            guard self.isLoaded == true else { return }
            self.parentLayout?.setNeedUpdate()
        }
    }
    public var progressColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qProgressColor = self.progressColor
        }
    }
    public var trackColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qTrackColor = self.trackColor
        }
    }
    public var progress: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qProgress = self.progress
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

    private var _view: ProgressView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _reuseView: QReuseView< ProgressView >
    
    public init(
        width: QDimensionBehaviour = .fill,
        height: QDimensionBehaviour,
        progressColor: QColor,
        trackColor: QColor,
        progress: QFloat,
        alpha: QFloat = 1
    ) {
        self.width = width
        self.height = height
        self.progressColor = progressColor
        self.trackColor = trackColor
        self.progress = progress
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
        return available.apply(width: self.width, height: self.height)
    }
    
}
