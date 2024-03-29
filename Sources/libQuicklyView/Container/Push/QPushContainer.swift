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
            guard self.parent !== oldValue else { return }
            self.didChangeInsets()
        }
    }
    public var shouldInteractive: Bool {
        return self.contentContainer?.shouldInteractive ?? false
    }
    #if os(iOS)
    public var statusBarHidden: Bool {
        guard let current = self._current else {
            return self.contentContainer?.statusBarHidden ?? false
        }
        return current.container.statusBarHidden
    }
    public var statusBarStyle: UIStatusBarStyle {
        guard let current = self._current else {
            return self.contentContainer?.statusBarStyle ?? .default
        }
        return current.container.statusBarStyle
    }
    public var statusBarAnimation: UIStatusBarAnimation {
        guard let current = self._current else {
            return self.contentContainer?.statusBarAnimation ?? .fade
        }
        return current.container.statusBarAnimation
    }
    public var supportedOrientations: UIInterfaceOrientationMask {
        guard let current = self._current else {
            return self.contentContainer?.supportedOrientations ?? .all
        }
        return current.container.supportedOrientations
    }
    #endif
    public private(set) var isPresented: Bool
    public var view: IQView {
        return self._view
    }
    public var additionalInset: QInset {
        set(value) { self._view.contentLayout.additionalInset = value }
        get { return self._view.contentLayout.additionalInset }
    }
    public var contentContainer: (IQContainer & IQContainerParentable)? {
        didSet(oldValue) {
            if let contentContainer = self.contentContainer {
                if self.isPresented == true {
                    contentContainer.prepareHide(interactive: false)
                    contentContainer.finishHide(interactive: false)
                }
                contentContainer.parent = nil
            }
            self._view.contentLayout.contentItem = self.contentContainer.flatMap({ QLayoutItem(view: $0.view) })
            if let contentContainer = self.contentContainer {
                contentContainer.parent = self
                if self.isPresented == true {
                    contentContainer.prepareHide(interactive: false)
                    contentContainer.finishHide(interactive: false)
                }
            }
        }
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
    
    private var _view: QCustomView< Layout >
    #if os(iOS)
    private var _interactiveGesture: QPanGesture
    private var _interactiveBeginLocation: QPoint?
    #endif
    private var _items: [Item]
    private var _previous: Item?
    private var _current: Item? {
        didSet {
            #if os(iOS)
            self._interactiveGesture.isEnabled = self._current != nil
            #endif
        }
    }
    private var _timer: QTimer?
    
    public init(
        additionalInset: QInset = QInset(horizontal: 8, vertical: 8),
        contentContainer: (IQContainer & IQContainerParentable)? = nil
    ) {
        self.isPresented = false
        #if os(iOS)
        self.animationVelocity = 500
        self.interactiveLimit = 20
        #endif
        self.contentContainer = contentContainer
        #if os(iOS)
        self._interactiveGesture = QPanGesture(
            isEnabled: false
        )
        self._view = QCustomView(
            gestures: [ self._interactiveGesture ],
            contentLayout: Layout(
                additionalInset: additionalInset,
                containerInset: .zero,
                contentItem: contentContainer.flatMap({ QLayoutItem(view: $0.view) }),
                state: .empty
            )
        )
        #else
        self._view = QCustomView(
            contentLayout: Layout(
                additionalInset: additionalInset,
                containerInset: .zero,
                contentItem: contentContainer.flatMap({ QLayoutItem(view: $0.view) }),
                state: .empty
            )
        )
        #endif
        self._items = []
        self._init()
    }
    
    deinit {
        self._timerReset()
    }
    
    public func insets(of container: IQContainer, interactive: Bool) -> QInset {
        return self.inheritedInsets(interactive: interactive)
    }
    
    public func didChangeInsets() {
        self._view.contentLayout.containerInset = self.inheritedInsets(interactive: true)
        self.contentContainer?.didChangeInsets()
        for container in self.containers {
            container.didChangeInsets()
        }
    }
    
    public func activate() -> Bool {
        if let current = self._current {
            if current.container.activate() == true {
                return true
            }
        }
        if let contentContainer = self.contentContainer {
            return contentContainer.activate()
        }
        return false
    }
    
    public func didChangeAppearance() {
        for container in self.containers {
            container.didChangeAppearance()
        }
        if let contentContainer = self.contentContainer {
            contentContainer.didChangeAppearance()
        }
    }
    
    public func prepareShow(interactive: Bool) {
        self.didChangeInsets()
        self.contentContainer?.prepareShow(interactive: interactive)
        self.currentContainer?.prepareShow(interactive: interactive)
    }
    
    public func finishShow(interactive: Bool) {
        self.isPresented = true
        self.contentContainer?.finishShow(interactive: interactive)
        self.currentContainer?.finishShow(interactive: interactive)
    }
    
    public func cancelShow(interactive: Bool) {
        self.contentContainer?.cancelShow(interactive: interactive)
        self.currentContainer?.cancelShow(interactive: interactive)
    }
    
    public func prepareHide(interactive: Bool) {
        self.contentContainer?.prepareHide(interactive: interactive)
        self.currentContainer?.prepareHide(interactive: interactive)
    }
    
    public func finishHide(interactive: Bool) {
        self.isPresented = false
        self.contentContainer?.finishHide(interactive: interactive)
        self.currentContainer?.finishHide(interactive: interactive)
    }
    
    public func cancelHide(interactive: Bool) {
        self.contentContainer?.cancelHide(interactive: interactive)
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
        #if os(iOS)
        self._interactiveGesture.onShouldBeRequiredToFailBy({ [unowned self] gesture -> Bool in
            guard let contentContainer = self.contentContainer else { return true }
            guard let view = gesture.view else { return false }
            return contentContainer.view.native.isChild(of: view, recursive: true)
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
        self.contentContainer?.parent = self
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
                    self._view.contentLayout.state = .present(push: push, progress: progress)
                    self._view.contentLayout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._didPresent(push: push)
                    push.container.finishShow(interactive: false)
                    self._view.contentLayout.state = .idle(push: push)
                    self.setNeedUpdateOrientations()
                    self.setNeedUpdateStatusBar()
                    completion?()
                }
            )
        } else {
            self._didPresent(push: push)
            push.container.finishShow(interactive: false)
            self._view.contentLayout.state = .idle(push: push)
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
                    self._view.contentLayout.state = .dismiss(push: push, progress: progress)
                    self._view.contentLayout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    push.container.finishHide(interactive: false)
                    self._view.contentLayout.state = .empty
                    self.setNeedUpdateOrientations()
                    self.setNeedUpdateStatusBar()
                    completion?()
                }
            )
        } else {
            push.container.finishHide(interactive: false)
            self._view.contentLayout.state = .empty
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
            let height = self._view.contentLayout.height(item: current)
            let progress = -deltaLocation / height
            self._view.contentLayout.state = .dismiss(push: current, progress: progress)
        } else if deltaLocation > 0 {
            let height = self._view.contentLayout.height(item: current)
            let progress = deltaLocation / pow(height, 1.5)
            self._view.contentLayout.state = .present(push: current, progress: 1 + progress)
        } else {
            self._view.contentLayout.state = .idle(push: current)
        }
    }

    func _endInteractiveGesture(_ canceled: Bool) {
        guard let beginLocation = self._interactiveBeginLocation, let current = self._current else { return }
        let currentLocation = self._interactiveGesture.location(in: self._view)
        let deltaLocation = currentLocation.y - beginLocation.y
        if deltaLocation < -self.interactiveLimit {
            let height = self._view.contentLayout.height(item: current)
            QAnimation.default.run(
                duration: TimeInterval(height / self.animationVelocity),
                elapsed: TimeInterval(-deltaLocation / self.animationVelocity),
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._view.contentLayout.state = .dismiss(push: current, progress: progress)
                    self._view.contentLayout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._finishInteractiveAnimation()
                }
            )
        } else if deltaLocation > 0 {
            let height = self._view.contentLayout.height(item: current)
            let baseProgress = deltaLocation / pow(height, 1.5)
            QAnimation.default.run(
                duration: TimeInterval((height * baseProgress) / self.animationVelocity),
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._view.contentLayout.state = .present(push: current, progress: 1 + (baseProgress - (baseProgress * progress)))
                    self._view.contentLayout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._cancelInteractiveAnimation()
                }
            )
        } else {
            self._view.contentLayout.state = .idle(push: current)
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
                self._view.contentLayout.state = .empty
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
            }
        } else {
            self._current = nil
            self._view.contentLayout.state = .empty
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
        }
    }
    
    func _cancelInteractiveAnimation() {
        self._interactiveBeginLocation = nil
        self._timer?.resume()
        if let current = self._current {
            current.container.cancelHide(interactive: true)
            self._view.contentLayout.state = .idle(push: current)
        } else {
            self._view.contentLayout.state = .empty
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
            self.size = container.view.size(available: available)
        }
        
        func update(available: QSize) {
            self.size = self.container.view.size(available: available)
        }

    }
    
}

private extension QPushContainer {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var additionalInset: QInset {
            didSet { self.setNeedUpdate() }
        }
        var containerInset: QInset {
            didSet { self.setNeedUpdate() }
        }
        var contentItem: QLayoutItem? {
            didSet { self.setNeedUpdate() }
        }
        var state: State {
            didSet { self.setNeedUpdate() }
        }

        init(
            additionalInset: QInset,
            containerInset: QInset,
            contentItem: QLayoutItem?,
            state: State
        ) {
            self.additionalInset = additionalInset
            self.containerInset = containerInset
            self.contentItem = contentItem
            self.state = state
        }
        
        func layout(bounds: QRect) -> QSize {
            if let contentItem = self.contentItem {
                contentItem.frame = bounds
            }
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
        
        func size(available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            var items: [QLayoutItem] = []
            if let contentItem = self.contentItem {
                items.append(contentItem)
            }
            switch self.state {
            case .empty: break
            case .idle(let push): items.append(push.item)
            case .present(let push, _): items.append(push.item)
            case .dismiss(let push, _): items.append(push.item)
            }
            return items
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
