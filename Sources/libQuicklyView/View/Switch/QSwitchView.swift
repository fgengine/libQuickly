//
//  libQuicklyView
//

import Foundation

protocol SwitchViewDelegate : AnyObject {
    
    func changed(value: Bool)
    
}

public class QSwitchView : IQView {
    
    public typealias SimpleClosure = (_ switchView: QSwitchView) -> Void
    
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
    public var thumbColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qThumbColor = self.thumbColor
        }
    }
    public var offColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qOffColor = self.offColor
        }
    }
    public var onColor: QColor {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qOnColor = self.onColor
        }
    }
    public var value: Bool {
        set(value) {
            self._value = value
            guard self.isLoaded == true else { return }
            self._view.qValue = self._value
        }
        get { return self._value }
    }
    public var alpha: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qAlpha = self.alpha
        }
    }
    public var onChanged: SimpleClosure
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
    
    private var _value: Bool
    private var _view: SwitchView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _reuseView: QReuseView< SwitchView >
    
    public init(
        width: QDimensionBehaviour = .fill,
        height: QDimensionBehaviour,
        thumbColor: QColor,
        offColor: QColor,
        onColor: QColor,
        value: Bool,
        alpha: QFloat = 1,
        onChanged: @escaping SimpleClosure
    ) {
        self.width = width
        self.height = height
        self.thumbColor = thumbColor
        self.offColor = offColor
        self.onColor = onColor
        self._value = value
        self.alpha = alpha
        self.onChanged = onChanged
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

extension QSwitchView : SwitchViewDelegate {
    
    func changed(value: Bool) {
        self.value = value
        self.onChanged(self)
    }
    
}
