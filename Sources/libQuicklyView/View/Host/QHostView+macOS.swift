//
//  libQuicklyView
//

#if os(OSX)

import AppKit

public final class QHostView : NSView {
    
    public var view: IQView {
        willSet(newValue) {
            guard self.view !== newValue else { return }
            self._layout.items = []
            self._disappear(view: self.view)
        }
        didSet(oldValue) {
            guard self.view !== oldValue else { return }
            self._layout.items = [ QLayoutItem(view: self.view) ]
            self._appear(view: self.view)
        }
    }
    public override var isFlipped: Bool {
        return true
    }
    
    private var _layout: Layout!

    public init(view: IQView, frame: CGRect) {
        self.view = view
        
        super.init(frame: frame)
        
        self._layout = Layout(delegate: self, host: self)
        self._appear(view: view)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layout() {
        super.layout()
        
        self._layout.layout()
        for item in self._layout.items {
            item.view.native.frame = item.frame.cgRect
        }
    }
    
    public override func hitTest(_ point: NSPoint) -> NSView? {
        if let hitView = super.hitTest(point) {
            if hitView != self {
                return hitView
            }
        }
        return nil
    }
    
}

private extension QHostView {
    
    class Layout : IQLayout {
        
        var delegate: IQLayoutDelegate?
        weak var parentView: IQView?
        var items: [IQLayoutItem]
        var size: QSize

        private weak var _host: QHostView!
        
        init(delegate: IQLayoutDelegate, host: QHostView) {
            self.delegate = delegate
            self.items = [ QLayoutItem(view: host.view) ]
            self.size = QSize()
            self._host = host
        }
        
        func layout() {
            var size: QSize
            if let bounds = self.delegate?.bounds(self) {
                size = bounds.size
                for item in self.items {
                    item.frame = bounds
                }
            } else {
                size = QSize()
            }
            self.size = size
        }
        
        func size(_ available: QSize) -> QSize {
            return available
        }
        
    }
    
}

private extension QHostView {
    
    func _appear(view: IQView) {
        self.addSubview(view.native)
        view.onAppear(to: self._layout)
    }
    
    func _disappear(view: IQView) {
        view.native.removeFromSuperview()
        view.onDisappear()
    }
    
}

extension QHostView : IQLayoutDelegate {
    
    public func bounds(_ layout: IQLayout) -> QRect {
        return QRect(self.bounds)
    }
    
    public func setNeedUpdate(_ layout: IQLayout) {
        self.needsLayout = true
    }
    
    public func updateIfNeeded(_ layout: IQLayout) {
        self.layoutSubtreeIfNeeded()
    }
    
}

#endif
