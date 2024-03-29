//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

extension QRateView {
    
    struct Reusable : IQReusable {
        
        typealias Owner = QRateView
        typealias Content = NativeRateView

        static var reuseIdentificator: String {
            return "QRateView"
        }
        
        static func createReuse(owner: Owner) -> Content {
            return Content(frame: .zero)
        }
        
        static func configureReuse(owner: Owner, content: Content) {
            content.update(view: owner)
        }
        
        static func cleanupReuse(content: Content) {
            content.cleanup()
        }
        
    }
    
}

final class NativeRateView : UIView {
    
    typealias View = IQView & IQViewCornerRadiusable & IQViewShadowable
    
    override var frame: CGRect {
        set(value) {
            if super.frame != value {
                super.frame = value
                if let view = self._view {
                    self.update(cornerRadius: view.cornerRadius)
                    self.updateShadowPath()
                }
            }
        }
        get { return super.frame }
    }
    
    private unowned var _view: View?
    private var _itemSize: QSize {
        didSet(oldValue) {
            guard self._itemSize != oldValue else { return }
            self.setNeedsLayout()
        }
    }
    private var _itemSpacing: Float {
        didSet(oldValue) {
            guard self._itemSpacing != oldValue else { return }
            self.setNeedsLayout()
        }
    }
    private var _rounding: QRateViewRounding {
        didSet {
            guard self._rounding != oldValue else { return }
            self._update()
        }
    }
    private var _numberOfItem: UInt {
        didSet(oldValue) {
            guard self._numberOfItem != oldValue else { return }
            self.setNeedsLayout()
        }
    }
    private var _states: [QRateViewState] {
        didSet {
            self._update()
        }
    }
    private var _rating: Float {
        didSet {
            guard self._rating != oldValue else { return }
            self._update()
        }
    }
    private var _layers: [CALayer]
    
    override init(frame: CGRect) {
        self._itemSize = .zero
        self._itemSpacing = 0
        self._numberOfItem = 0
        self._rounding = .down
        self._states = []
        self._rating = 0
        self._layers = []
        
        super.init(frame: frame)
        
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self._layout()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self._layout(rebuild: true)
        self._update()
    }
    
}

extension NativeRateView {
    
    func update(view: QRateView) {
        self._view = view
        self.update(itemSize: view.itemSize)
        self.update(itemSpacing: view.itemSpacing)
        self.update(numberOfItem: view.numberOfItem)
        self.update(rounding: view.rounding)
        self.update(states: view.states)
        self.update(rating: view.rating)
        self.update(color: view.color)
        self.update(border: view.border)
        self.update(cornerRadius: view.cornerRadius)
        self.update(shadow: view.shadow)
        self.update(alpha: view.alpha)
        self.updateShadowPath()
    }
    
    func update(itemSize: QSize) {
        self._itemSize = itemSize
    }
    
    func update(itemSpacing: Float) {
        self._itemSpacing = itemSpacing
    }
    
    func update(numberOfItem: UInt) {
        self._numberOfItem = numberOfItem
    }
    
    func update(rounding: QRateViewRounding) {
        self._rounding = rounding
    }
    
    func update(states: [QRateViewState]) {
        self._states = states
    }
    
    func update(rating: Float) {
        self._rating = rating
    }
    
    func cleanup() {
        self._view = nil
    }
    
}

private extension NativeRateView {
    
    func _contentSize() -> QSize {
        if self._numberOfItem > 1 {
            return QSize(
                width: (self._itemSize.width * Float(self._numberOfItem)) + (self._itemSpacing * Float(self._numberOfItem - 1)),
                height: self._itemSize.height
            )
        } else if self._numberOfItem > 0 {
            return self._itemSize
        }
        return .zero
    }
    
    func _state(item: UInt) -> QRateViewState? {
        guard let firstState = self._states.first else { return nil }
        guard let lastState = self._states.last else { return nil }
        if self._rating <= Float(item) {
            return firstState
        } else if self._rating >= Float(item + 1) {
            return lastState
        }
        let rate = self._rating - self._rating.rounded(.towardZero)
        var nearestState: QRateViewState?
        switch self._rounding {
        case .up:
            for state in self._states.reversed() {
                if state.rate >= rate {
                    nearestState = state
                }
            }
        case .down:
            for state in self._states {
                if state.rate <= rate {
                    nearestState = state
                }
            }
        }
        return nearestState
    }
    
    func _layout(rebuild: Bool = false) {
        if rebuild == true {
            for layer in self._layers {
                layer.removeFromSuperlayer()
            }
            self._layers.removeAll()
        }
        let numberOfItem = Int(self._numberOfItem)
        if self._layers.count > numberOfItem {
            for index in (numberOfItem..<self._layers.count).reversed() {
                let layer = self._layers[index]
                self._layers.remove(at: index)
                layer.removeFromSuperlayer()
            }
        } else if self._layers.count < numberOfItem {
            for _ in self._layers.count..<numberOfItem {
                let layer = CALayer()
                layer.contentsGravity = .resizeAspect
                self._layers.append(layer)
                self.layer.addSublayer(layer)
            }
        }
        let bounds = QRect(self.bounds)
        let boundsCenter = bounds.center
        let contentSize = self._contentSize()
        var origin = QPoint(
            x: boundsCenter.x - (contentSize.width / 2),
            y: boundsCenter.y - (contentSize.height / 2)
        )
        for (index, layer) in self._layers.enumerated() {
            layer.frame = CGRect(
                x: CGFloat(origin.x),
                y: CGFloat(origin.y),
                width: CGFloat(self._itemSize.width),
                height: CGFloat(self._itemSize.height)
            )
            if let state = self._state(item: UInt(index)) {
                self._update(layer: layer, state: state)
            }
            origin.x += self._itemSize.width + self._itemSpacing
        }
    }
    
    func _update() {
        for (index, layer) in self._layers.enumerated() {
            if let state = self._state(item: UInt(index)) {
                self._update(layer: layer, state: state)
            }
        }
    }
    
    func _update(layer: CALayer, state: QRateViewState) {
        let image: UIImage
        if let imageAsset = state.image.native.imageAsset {
            image = imageAsset.image(with: self.traitCollection)
        } else {
            image = state.image.native
        }
        layer.contents = image.cgImage
    }
    
}

extension NativeRateView : IQLayoutDelegate {
    
    func setNeedUpdate(_ layout: IQLayout) -> Bool {
        self.setNeedsLayout()
        return true
    }
    
    func updateIfNeeded(_ layout: IQLayout) {
        self.layoutIfNeeded()
    }
    
}

#endif
