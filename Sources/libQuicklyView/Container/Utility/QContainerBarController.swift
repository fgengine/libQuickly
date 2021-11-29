//
//  libQuicklyView
//

import Foundation
import libQuicklyCore
import libQuicklyObserver

public protocol IQContainerBarControllerObserver : AnyObject {
    
    func changed(containerBarController: QContainerBarController)
    
}

public class QContainerBarController {
    
    public var isAnimating: Bool {
        return self._animation != nil
    }
    
    private var _visibility: [Target : Float]
    private var _observer: QObserver< IQContainerBarControllerObserver >
    private var _animation: IQAnimationTask?
    
    public init(
        visibility: [Target : Float] = [:]
    ) {
        self._visibility = visibility
        self._observer = QObserver()
        for target in Target.allCases {
            guard self._visibility[target] == nil else { continue }
            self._visibility[target] = 1
        }
    }
    
}

public extension QContainerBarController {
    
    enum Target : CaseIterable {
        case stack
        case page
        case group
        case sticky
    }
    
}

public extension QContainerBarController {
    
    static let shared = QContainerBarController()
    
}

public extension QContainerBarController {
    
    func add(observer: IQContainerBarControllerObserver) {
        self._observer.add(observer, priority: 0)
    }
    
    func remove(observer: IQContainerBarControllerObserver) {
        self._observer.remove(observer)
    }
    
    func set(_ target: Target, visibility: Float) {
        self._visibility[target] = visibility
        self._notify()
    }
    
    func visibility(_ target: Target) -> Float {
        guard let visibility = self._visibility[target] else { return 0 }
        return visibility
    }
    
    func hidden(_ target: Target) -> Bool {
        return self.visibility(target) == 0
    }
    
    func animate(
        duration: TimeInterval,
        ease: IQAnimationEase = QAnimation.Ease.QuadraticInOut(),
        visibility: [Target : Float],
        completion: (() -> Void)? = nil
    ) {
        guard self.isAnimating == false else { return }
        let beginVisibility = self._visibility
        self._animation = QAnimation.default.run(
            duration: duration,
            ease: ease,
            processing: { [weak self] progress in
                guard let self = self else { return }
                for new in visibility {
                    guard let begin = beginVisibility[new.key] else { continue }
                    self._visibility[new.key] = begin.lerp(new.value, progress: progress)
                }
                self._notify()
            },
            completion: { [weak self] in
                guard let self = self else { return }
                self._animation = nil
                for new in visibility {
                    self._visibility[new.key] = new.value
                }
                self._notify()
            }
        )
    }
    
}

private extension QContainerBarController {
    
    func _notify() {
        self._observer.notify({ $0.changed(containerBarController: self) })
    }
    
}
