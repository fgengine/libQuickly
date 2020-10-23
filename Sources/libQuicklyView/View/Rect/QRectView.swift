//
//  libQuicklyView
//

import Foundation

public class QRectView : IQView {
    
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
    public var fill: Fill {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qFill = self.fill
        }
    }
    public var cornerRadius: CornerRadius {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qCornerRadius = self.cornerRadius
        }
    }
    public var border: Border {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qBorder = self.border
        }
    }
    public var shadow: Shadow? {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qShadow = self.shadow
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
    
    private var _view: RectView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _reuseView: QReuseView< RectView >
    
    public init(
        width: QDimensionBehaviour,
        height: QDimensionBehaviour,
        fill: Fill,
        cornerRadius: CornerRadius = .none,
        border: Border = .none,
        shadow: Shadow? = nil,
        alpha: QFloat = 1
    ) {
        self.width = width
        self.height = height
        self.fill = fill
        self.cornerRadius = cornerRadius
        self.border = border
        self.shadow = shadow
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

public extension QRectView {
    
    enum Fill {
        case color(_ value: QColor)
        case gradient(_ value: Gradient)
    }
    
    enum Border {
        case none
        case manual(width: QFloat, color: QColor)
    }
    
    enum CornerRadius {
        case none
        case manual(radius: QFloat)
        case auto
    }
    
    struct Shadow {
    
        public var color: QColor
        public var opacity: QFloat
        public var radius: QFloat
        public var offset: QPoint
    
        public init(
            color: QColor,
            opacity: QFloat,
            radius: QFloat,
            offset: QPoint
        ) {
            self.color = color
            self.opacity = opacity
            self.radius = radius
            self.offset = offset
        }
    
    }
    
    struct Gradient {
        
        public var mode: Mode
        public var points: [Point]
        public var start: QPoint
        public var end: QPoint
        
        public init(
            mode: Mode,
            points: [Point],
            start: QPoint,
            end: QPoint
        ) {
            self.mode = mode
            self.points = points
            self.start = start
            self.end = end
        }
        
    }
    
}

public extension QRectView.Gradient {
    
    enum Mode {
        case axial
        case radial
    }
    
    struct Point {
        
        public var color: QColor
        public var location: QFloat
        
        public init(
            color: QColor,
            location: QFloat
        ) {
            self.color = color
            self.location = location
        }
        
    }
    
}

public extension QRectView.Gradient {
    
    var isOpaque: Bool {
        for point in self.points {
            if point.color.isOpaque == false {
                return false
            }
        }
        return true
    }
    
}
