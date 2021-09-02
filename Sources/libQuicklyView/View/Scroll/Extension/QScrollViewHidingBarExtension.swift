//
//  libQuicklyView
//

import Foundation
import libQuicklyCore
import libQuicklyObserver

public protocol QScrollViewHidingBarExtensionObserver : AnyObject {
    
    func changed(scrollViewExtension: QScrollViewHidingBarExtension)
    
}

public class QScrollViewHidingBarExtension {
    
    public var direction: Direction
    public var state: State
    public var visibility: Float {
        switch self.state {
        case .showed: return 1
        case .showing(let progress): return progress
        case .hiding(let progress): return 1 - progress
        case .hided: return 0
        }
    }
    public var threshold: Float
    public var animationVelocity: Float
    public var isAnimating: Bool
    public var scrollView: IQScrollView {
        willSet { self.scrollView.remove(observer: self) }
        didSet { self.scrollView.add(observer: self) }
    }
    
    private var _anchor: Float?
    private var _observer: QObserver< QScrollViewHidingBarExtensionObserver >
    
    public init(
        direction: Direction = .vertical,
        state: State = .showed,
        threshold: Float = 100,
        animationVelocity: Float = 600,
        scrollView: IQScrollView
    ) {
        self.direction = direction
        self.state = state
        self.threshold = threshold
        self.animationVelocity = animationVelocity
        self.isAnimating = false
        self.scrollView = scrollView
        self._observer = QObserver()
        self.scrollView.add(observer: self)
    }
    
    deinit {
        self.scrollView.remove(observer: self)
    }

}

public extension QScrollViewHidingBarExtension {
    
    enum Direction {
        case horizontal
        case vertical
    }
    
    enum State : Equatable {
        case showed
        case showing(progress: Float)
        case hiding(progress: Float)
        case hided
    }
    
}

public extension QScrollViewHidingBarExtension {
    
    func add(observer: QScrollViewHidingBarExtensionObserver) {
        self._observer.add(observer, priority: 0)
    }
    
    func remove(observer: QScrollViewHidingBarExtensionObserver) {
        self._observer.remove(observer)
    }
    
    func reset(animate: Bool, completion: (() -> Void)? = nil) {
        self._anchor = nil
        self._set(isShowed: true, animate: animate, completion: completion)
    }
    
}

extension QScrollViewHidingBarExtension : IQScrollViewObserver {
    
    public func beginScrolling(scrollView: IQScrollView) {
    }
    
    public func scrolling(scrollView: IQScrollView) {
        let visible: Float
        let offset: Float
        let size: Float
        switch self.direction {
        case .horizontal:
            visible = scrollView.bounds.width
            offset = scrollView.contentOffset.x + scrollView.contentInset.left
            size = scrollView.contentInset.left + scrollView.contentSize.width + scrollView.contentInset.right
        case .vertical:
            visible = scrollView.bounds.height
            offset = scrollView.contentOffset.y + scrollView.contentInset.top
            size = scrollView.contentInset.top + scrollView.contentSize.height + scrollView.contentInset.bottom
        }
        if size > visible {
            let anchor: Float
            if let existAnchor = self._anchor {
                anchor = existAnchor
            } else {
                self._anchor = offset
                anchor = offset
            }
            let newState = Self._visibility(
                state: self.state,
                threshold: self.threshold,
                visible: visible,
                anchor: anchor,
                offset: offset,
                size: size
            )
            if newState == .showed || newState == .hided {
                self._anchor = max(0, offset)
            }
            self._set(state: newState)
        }
    }
    
    public func endScrolling(scrollView: IQScrollView, decelerate: Bool) {
        if decelerate == false {
            self._end()
        }
    }
    
    public func beginDecelerating(scrollView: IQScrollView) {
    }
    
    public func endDecelerating(scrollView: IQScrollView) {
        self._end()
    }
    
    public func scrollToTop(scrollView: IQScrollView) {
        self._end()
    }
    
}

private extension QScrollViewHidingBarExtension {
    
    @inline(__always)
    func _end() {
        self._anchor = nil
        switch self.state {
        case .showed, .hided:
            break
        case .showing(let baseProgress):
            self.isAnimating = true
            if baseProgress >= 0.5 {
                QAnimation.default.run(
                    duration: TimeInterval((self.threshold * (1 - baseProgress)) / self.animationVelocity),
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._set(state: .showing(progress: baseProgress + ((1 - baseProgress) * progress)))
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self.isAnimating = false
                        self._set(state: .showed)
                    }
                )
            } else {
                QAnimation.default.run(
                    duration: TimeInterval((self.threshold * baseProgress) / self.animationVelocity),
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._set(state: .showing(progress: baseProgress - (baseProgress * progress)))
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self.isAnimating = false
                        self._set(state: .hided)
                    }
                )
            }
        case .hiding(let baseProgress):
            self.isAnimating = true
            if baseProgress >= 0.5 {
                QAnimation.default.run(
                    duration: TimeInterval((self.threshold * (1 - baseProgress)) / self.animationVelocity),
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._set(state: .hiding(progress: baseProgress + ((1 - baseProgress) * progress)))
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self.isAnimating = false
                        self._set(state: .hided)
                    }
                )
            } else {
                QAnimation.default.run(
                    duration: TimeInterval((self.threshold * baseProgress) / self.animationVelocity),
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._set(state: .hiding(progress: baseProgress - (baseProgress * progress)))
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self.isAnimating = false
                        self._set(state: .showed)
                    }
                )
            }
        }
    }
    
    @inline(__always)
    func _set(isShowed: Bool, animate: Bool, completion: (() -> Void)?) {
        if animate == true {
            switch self.state {
            case .showed:
                if isShowed == false {
                    self.isAnimating = true
                    QAnimation.default.run(
                        duration: TimeInterval(self.threshold / self.animationVelocity),
                        ease: QAnimation.Ease.QuadraticInOut(),
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._set(state: .hiding(progress:  progress))
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self.isAnimating = false
                            self._set(state: .hided)
                            completion?()
                        }
                    )
                } else {
                    completion?()
                }
            case .hided:
                if isShowed == true {
                    self.isAnimating = true
                    QAnimation.default.run(
                        duration: TimeInterval(self.threshold / self.animationVelocity),
                        ease: QAnimation.Ease.QuadraticInOut(),
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._set(state: .showing(progress: progress))
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self.isAnimating = false
                            self._set(state: .showed)
                            completion?()
                        }
                    )
                } else {
                    completion?()
                }
            case .showing(let baseProgress):
                self.isAnimating = true
                if isShowed == true {
                    QAnimation.default.run(
                        duration: TimeInterval((self.threshold * (1 - baseProgress)) / self.animationVelocity),
                        ease: QAnimation.Ease.QuadraticInOut(),
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._set(state: .showing(progress: baseProgress + ((1 - baseProgress) * progress)))
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self.isAnimating = false
                            self._set(state: .showed)
                            completion?()
                        }
                    )
                } else {
                    QAnimation.default.run(
                        duration: TimeInterval((self.threshold * baseProgress) / self.animationVelocity),
                        ease: QAnimation.Ease.QuadraticInOut(),
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._set(state: .showing(progress: baseProgress - (baseProgress * progress)))
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self.isAnimating = false
                            self._set(state: .hided)
                            completion?()
                        }
                    )
                }
            case .hiding(let baseProgress):
                self.isAnimating = true
                if isShowed == true {
                    QAnimation.default.run(
                        duration: TimeInterval((self.threshold * baseProgress) / self.animationVelocity),
                        ease: QAnimation.Ease.QuadraticInOut(),
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._set(state: .hiding(progress: baseProgress - (baseProgress * progress)))
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self.isAnimating = false
                            self._set(state: .showed)
                            completion?()
                        }
                    )
                } else {
                    QAnimation.default.run(
                        duration: TimeInterval((self.threshold * (1 - baseProgress)) / self.animationVelocity),
                        ease: QAnimation.Ease.QuadraticInOut(),
                        processing: { [weak self] progress in
                            guard let self = self else { return }
                            self._set(state: .hiding(progress: baseProgress + ((1 - baseProgress) * progress)))
                        },
                        completion: { [weak self] in
                            guard let self = self else { return }
                            self.isAnimating = false
                            self._set(state: .hided)
                            completion?()
                        }
                    )
                }
            }
        } else {
            self._set(state: isShowed == true ? .showed : .hided)
            completion?()
        }
    }
    
    @inline(__always)
    func _set(state: State) {
        if self.state != state {
            self.state = state
            self._observer.notify({ $0.changed(scrollViewExtension: self) })
        }
    }
    
    @inline(__always)
    static func _visibility(
        state: State,
        threshold: Float,
        visible: Float,
        anchor: Float,
        offset: Float,
        size: Float
    ) -> State {
        let delta = anchor - offset
        switch state {
        case .showed:
            if delta < 0 {
                if delta < -threshold {
                    return .hided
                }
                return .hiding(progress: -delta / threshold)
            }
            return .showed
        case .showing:
            if delta > 0 {
                if delta > threshold {
                    return .showed
                }
                return .showing(progress: delta / threshold)
            }
            return .hided
        case .hiding:
            if delta < 0 {
                if delta < -threshold {
                    return .hided
                }
                return .hiding(progress: -delta / threshold)
            }
            return .showed
        case .hided:
            if delta > 0 {
                if delta > threshold {
                    return .showed
                }
                return .showing(progress: delta / threshold)
            }
            return .hided
        }
    }
    
}
