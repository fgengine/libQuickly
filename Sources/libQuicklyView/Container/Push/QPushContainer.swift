//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QPushContainer : IQPushContainer {
    
    public unowned var parent: IQContainer? {
        didSet(oldValue) {
            if self.parent !== oldValue {
                self.didChangeInsets()
            }
        }
    }
    public var shouldInteractive: Bool {
        return self._contentContainer.shouldInteractive
    }
    #if os(iOS)
    public var statusBarHidden: Bool {
        return self._contentContainer.statusBarHidden
    }
    public var statusBarStyle: UIStatusBarStyle {
        return self._contentContainer.statusBarStyle
    }
    public var statusBarAnimation: UIStatusBarAnimation {
        return self._contentContainer.statusBarAnimation
    }
    public var supportedOrientations: UIInterfaceOrientationMask {
        return self._contentContainer.supportedOrientations
    }
    #endif
    public private(set) var isPresented: Bool
    public var view: IQView {
        return self._view
    }
    public var additionalInset: QInset {
        set(value) { self._layout.additionalInset = value }
        get { return self._layout.additionalInset }
    }
    public var contentContainer: IQContainer & IQContainerParentable {
        set(value) {
            if self.isPresented == true {
                self._contentContainer.prepareHide(interactive: false)
                self._contentContainer.finishHide(interactive: false)
            }
            self._contentContainer.parent = nil
            self._contentContainer = value
            self._layout.contentItem = QLayoutItem(view: value.view)
            self._contentContainer.parent = self
            if self.isPresented == true {
                self._contentContainer.prepareHide(interactive: false)
                self._contentContainer.finishHide(interactive: false)
            }
        }
        get { return self._contentContainer }
    }
    public var containers: [IQPushContentContainer] {
        return self._items.compactMap({ return $0.container })
    }
    public var previousContainer: IQPushContentContainer? {
        return self._previous?.container
    }
    public var currentContainer: IQPushContentContainer? {
        return self._current?.container
    }
    public var animationVelocity: Float
    #if os(iOS)
    public var interactiveLimit: Float
    #endif
    
    private var _layout: Layout
    private var _view: QCustomView< Layout >
    #if os(iOS)
    private var _interactiveGesture: QPanGesture
    private var _interactiveBeginLocation: QPoint?
    #endif
    private var _contentContainer: IQContainer & IQContainerParentable
    private var _items: [Item]
    private var _previous: Item?
    private var _current: Item?
    private var _timer: QTimer?
    
    public init(
        additionalInset: QInset = QInset(horizontal: 8, vertical: 8),
        contentContainer: IQContainer & IQContainerParentable
    ) {
        self.isPresented = false
        #if os(iOS)
        self.animationVelocity = 500
        self.interactiveLimit = 20
        #endif
        self._contentContainer = contentContainer
        self._layout = Layout(
            additionalInset: additionalInset,
            containerInset: QInset(),
            contentItem: QLayoutItem(view: contentContainer.view),
            state: .empty
        )
        #if os(iOS)
        self._interactiveGesture = QPanGesture()
        self._view = QCustomView(
            gestures: [ self._interactiveGesture ],
            contentLayout: self._layout
        )
        #else
        self._view = QCustomView(
            contentLayout: self._layout
        )
        #endif
        self._items = []
        self._init()
    }
    
    deinit {
        self._timerReset()
    }
    
    public func insets(of container: IQContainer) -> QInset {
        return self.inheritedInsets
    }
    
    public func didChangeInsets() {
        self._layout.containerInset = self.inheritedInsets
        self._contentContainer.didChangeInsets()
        for container in self.containers {
            container.didChangeInsets()
        }
    }
    
    public func activate() -> Bool {
        if let current = self._current?.container {
            if current.activate() == true {
                return true
            }
        }
        return self._contentContainer.activate()
    }
    
    public func prepareShow(interactive: Bool) {
        self._contentContainer.prepareShow(interactive: interactive)
        self.currentContainer?.prepareShow(interactive: interactive)
    }
    
    public func finishShow(interactive: Bool) {
        self.isPresented = true
        self._contentContainer.finishShow(interactive: interactive)
        self.currentContainer?.finishShow(interactive: interactive)
    }
    
    public func cancelShow(interactive: Bool) {
        self._contentContainer.cancelShow(interactive: interactive)
        self.currentContainer?.cancelShow(interactive: interactive)
    }
    
    public func prepareHide(interactive: Bool) {
        self._contentContainer.prepareHide(interactive: interactive)
        self.currentContainer?.prepareHide(interactive: interactive)
    }
    
    public func finishHide(interactive: Bool) {
        self.isPresented = false
        self._contentContainer.finishHide(interactive: interactive)
        self.currentContainer?.finishHide(interactive: interactive)
    }
    
    public func cancelHide(interactive: Bool) {
        self._contentContainer.cancelHide(interactive: interactive)
        self.currentContainer?.cancelHide(interactive: interactive)
    }
    
    public func present(container: IQPushContentContainer, animated: Bool, completion: (() -> Void)?) {
        container.parent = self
        let item = Item(container: container, available: self._view.bounds.size)
        self._items.append(item)
        if self._current == nil {
            self._present(push: item, animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
    
    public func dismiss(container: IQPushContentContainer, animated: Bool, completion: (() -> Void)?) {
        guard let index = self._items.firstIndex(where: { $0.container === container }) else {
            completion?()
            return
        }
        let item = self._items[index]
        if self._current === item {
            self._items.remove(at: index)
            self._previous = self._items.first
            self._dismiss(current: item, previous: self._previous, animated: animated, completion: {
                container.parent = nil
                completion?()
            })
        } else {
            container.parent = nil
            self._items.remove(at: index)
            completion?()
        }
    }

}

extension QPushContainer : IQRootContentContainer {
}

private extension QPushContainer {
    
    func _init() {
        self._contentContainer.parent = self
        #if os(iOS)
        self._interactiveGesture.onShouldBeRequiredToFailBy({ [unowned self] gesture -> Bool in
            guard self._current != nil else { return false }
            guard let view = gesture.view else { return false }
            guard self.contentContainer.view.native.isChild(of: view, recursive: true) == true else { return false }
            return true
        }).onShouldBegin({ [unowned self] in
            guard let current = self._current else { return false }
            guard current.container.shouldInteractive == true else { return false }
            guard self._interactiveGesture.contains(in: current.container.view) == true else { return false }
            return true
        }).onBegin({ [unowned self] in
            self._beginInteractiveGesture()
        }) .onChange({ [unowned self] in
            self._changeInteractiveGesture()
        }).onCancel({ [unowned self] in
            self._endInteractiveGesture(true)
        }).onEnd({ [unowned self] in
            self._endInteractiveGesture(false)
        })
        #endif
    }
    
    func _timerReset() {
        self._timer?.stop()
        self._timer = nil
    }
    
    func _timerTriggered() {
        self._timerReset()
        if let currentItem = self._current {
            if let index = self._items.firstIndex(where: { $0 === currentItem }) {
                self._items.remove(at: index)
            }
            self._previous = self._items.first
            self._dismiss(current: currentItem, previous: self._previous, animated: true, completion: {
                currentItem.container.parent = nil
            })
        }
    }
    
    func _present(current: Item?, next: Item, animated: Bool, completion: (() -> Void)?) {
        if let current = current {
            self._dismiss(push: current, animated: animated, completion: { [weak self] in
                guard let self = self else { return }
                self._present(push: next, animated: animated, completion: completion)
            })
        } else {
            self._present(push: next, animated: animated, completion: completion)
        }
    }

    func _present(push: Item, animated: Bool, completion: (() -> Void)?) {
        self._current = push
        push.container.prepareShow(interactive: false)
        if animated == true {
            QAnimation.default.run(
                duration: TimeInterval(push.size.height / self.animationVelocity),
                ease: QAnimation.Ease.QuadraticInOut(),
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._layout.state = .present(push: push, progress: progress)
                    self._layout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._didPresent(push: push)
                    push.container.finishShow(interactive: false)
                    self._layout.state = .idle(push: push)
                    self.setNeedUpdateOrientations()
                    self.setNeedUpdateStatusBar()
                    completion?()
                }
            )
        } else {
            self._didPresent(push: push)
            push.container.finishShow(interactive: false)
            self._layout.state = .idle(push: push)
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
        }
    }
    
    func _didPresent(push: Item) {
        if let duration = push.container.pushDuration {
            let timer = QTimer(interval: duration, delay: 0, repeating: 0)
            timer.onFinished(self._timerTriggered)
            timer.start()
            self._timer = timer
        }
    }

    func _dismiss(current: Item, previous: Item?, animated: Bool, completion: (() -> Void)?) {
        self._dismiss(push: current, animated: animated, completion: { [weak self] in
            guard let self = self else { return }
            self._current = previous
            if let previous = previous {
                self._present(push: previous, animated: animated, completion: completion)
            } else {
                completion?()
            }
        })
    }
    
    func _dismiss(push: Item, animated: Bool, completion: (() -> Void)?) {
        push.container.prepareHide(interactive: false)
        if animated == true {
            QAnimation.default.run(
                duration: TimeInterval(push.size.height / self.animationVelocity),
                ease: QAnimation.Ease.QuadraticInOut(),
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._layout.state = .dismiss(push: push, progress: progress)
                    self._layout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    push.container.finishHide(interactive: false)
                    self._layout.state = .empty
                    self.setNeedUpdateOrientations()
                    self.setNeedUpdateStatusBar()
                    completion?()
                }
            )
        } else {
            push.container.finishHide(interactive: false)
            self._layout.state = .empty
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
        }
    }
    
}

#if os(iOS)

private extension QPushContainer {
    
    func _beginInteractiveGesture() {
        guard let current = self._current else { return }
        self._interactiveBeginLocation = self._interactiveGesture.location(in: self._view)
        self._timer?.pause()
        current.container.prepareHide(interactive: true)
    }
    
    func _changeInteractiveGesture() {
        guard let beginLocation = self._interactiveBeginLocation, let current = self._current else { return }
        let currentLocation = self._interactiveGesture.location(in: self._view)
        let deltaLocation = currentLocation.y - beginLocation.y
        if deltaLocation < 0 {
            let height = self._layout.height(item: current)
            let progress = -deltaLocation / height
            self._layout.state = .dismiss(push: current, progress: progress)
        } else if deltaLocation > 0 {
            let height = self._layout.height(item: current)
            let progress = deltaLocation / pow(height, 1.5)
            self._layout.state = .present(push: current, progress: 1 + progress)
        } else {
            self._layout.state = .idle(push: current)
        }
    }

    func _endInteractiveGesture(_ canceled: Bool) {
        guard let beginLocation = self._interactiveBeginLocation, let current = self._current else { return }
        let currentLocation = self._interactiveGesture.location(in: self._view)
        let deltaLocation = currentLocation.y - beginLocation.y
        if deltaLocation < -self.interactiveLimit {
            let height = self._layout.height(item: current)
            QAnimation.default.run(
                duration: TimeInterval(height / self.animationVelocity),
                elapsed: TimeInterval(-deltaLocation / self.animationVelocity),
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._layout.state = .dismiss(push: current, progress: progress)
                    self._layout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._finishInteractiveAnimation()
                }
            )
        } else if deltaLocation > 0 {
            let height = self._layout.height(item: current)
            let baseProgress = deltaLocation / pow(height, 1.5)
            QAnimation.default.run(
                duration: TimeInterval((height * baseProgress) / self.animationVelocity),
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._layout.state = .present(push: current, progress: 1 + (baseProgress - (baseProgress * progress)))
                    self._layout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._cancelInteractiveAnimation()
                }
            )
        } else {
            self._layout.state = .idle(push: current)
            self._cancelInteractiveAnimation()
        }
    }
    
    func _finishInteractiveAnimation() {
        self._timerReset()
        self._interactiveBeginLocation = nil
        if let current = self._current {
            current.container.finishHide(interactive: true)
            current.container.parent = nil
            if let index = self._items.firstIndex(where: { $0 === current }) {
                self._items.remove(at: index)
            }
            self._previous = self._items.first
            if let previous = self._previous {
                self._present(push: previous, animated: true, completion: nil)
            } else {
                self._current = nil
                self._layout.state = .empty
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
            }
        } else {
            self._current = nil
            self._layout.state = .empty
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
        }
    }
    
    func _cancelInteractiveAnimation() {
        self._interactiveBeginLocation = nil
        self._timer?.resume()
        if let current = self._current {
            current.container.cancelHide(interactive: true)
            self._layout.state = .idle(push: current)
        } else {
            self._layout.state = .empty
        }
        self.setNeedUpdateOrientations()
        self.setNeedUpdateStatusBar()
    }
    
}
    
#endif

private extension QPushContainer {
    
    class Item {
        
        var container: IQPushContentContainer
        var item: QLayoutItem
        var size: QSize

        init(container: IQPushContentContainer, available: QSize) {
            self.container = container
            self.item = QLayoutItem(view: container.view)
            self.size = container.view.size(available)
        }
        
        func update(available: QSize) {
            self.size = self.container.view.size(available)
        }

    }
    
}

private extension QPushContainer {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var additionalInset: QInset {
            didSet { self.setNeedForceUpdate() }
        }
        var containerInset: QInset {
            didSet { self.setNeedForceUpdate() }
        }
        var contentItem: QLayoutItem {
            didSet { self.setNeedForceUpdate() }
        }
        var state: State {
            didSet { self.setNeedUpdate() }
        }

        init(
            additionalInset: QInset,
            containerInset: QInset,
            contentItem: QLayoutItem,
            state: State
        ) {
            self.additionalInset = additionalInset
            self.containerInset = containerInset
            self.contentItem = contentItem
            self.state = state
        }
        
        func invalidate(item: QLayoutItem) {
        }
        
        func invalidate() {
        }
        
        func layout(bounds: QRect) -> QSize {
            self.contentItem.frame = bounds
            switch self.state {
            case .empty:
                break
            case .idle(let push):
                let inset = self.additionalInset + self.containerInset
                push.item.frame = QRect(
                    x: bounds.origin.x + inset.left,
                    y: bounds.origin.y + inset.top,
                    width: bounds.size.width - (inset.left + inset.right),
                    height: push.size.height
                )
            case .present(let push, let progress):
                let inset = self.additionalInset + self.containerInset
                let beginRect = QRect(
                    x: bounds.origin.x + inset.left,
                    y: bounds.origin.y - push.size.height,
                    width: bounds.size.width - (inset.left + inset.right),
                    height: push.size.height
                )
                let endRect = QRect(
                    x: bounds.origin.x + inset.left,
                    y: bounds.origin.y + inset.top,
                    width: bounds.size.width - (inset.left + inset.right),
                    height: push.size.height
                )
                push.item.frame = beginRect.lerp(endRect, progress: progress)
            case .dismiss(let push, let progress):
                let inset = self.additionalInset + self.containerInset
                let beginRect = QRect(
                    x: bounds.origin.x + inset.left,
                    y: bounds.origin.y + inset.top,
                    width: bounds.size.width - (inset.left + inset.right),
                    height: push.size.height
                )
                let endRect = QRect(
                    x: bounds.origin.x + inset.left,
                    y: bounds.origin.y - push.size.height,
                    width: bounds.size.width - (inset.left + inset.right),
                    height: push.size.height
                )
                push.item.frame = beginRect.lerp(endRect, progress: progress)
            }
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            switch self.state {
            case .empty: return [ self.contentItem ]
            case .idle(let push): return [ self.contentItem, push.item ]
            case .present(let push, _): return [ self.contentItem, push.item ]
            case .dismiss(let push, _): return [ self.contentItem, push.item ]
            }
        }
        
        func height(item: QPushContainer.Item) -> Float {
            return item.size.height + self.additionalInset.top + self.containerInset.top
        }
        
    }
    
}

private extension QPushContainer.Layout {
    
    enum State {
        case empty
        case idle(push: QPushContainer.Item)
        case present(push: QPushContainer.Item, progress: Float)
        case dismiss(push: QPushContainer.Item, progress: Float)
    }
    
}
