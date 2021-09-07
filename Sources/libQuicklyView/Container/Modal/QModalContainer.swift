//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QModalContainer : IQModalContainer {
    
    public unowned var parent: IQContainer? {
        didSet(oldValue) {
            guard self.parent !== oldValue else { return }
            guard self.isPresented == true else { return }
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
    public var containers: [IQModalContentContainer] {
        return self._items.compactMap({ return $0.container })
    }
    public var previousContainer: IQModalContentContainer? {
        return self._previous?.container
    }
    public var currentContainer: IQModalContentContainer? {
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
    
    public init(
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
                containerInset: .zero,
                contentItem: contentContainer.flatMap({ QLayoutItem(view: $0.view) }),
                state: .empty
            )
        )
        #else
        self._view = QCustomView(
            contentLayout: Layout(
                containerInset: .zero,
                contentItem: contentContainer.flatMap({ QLayoutItem(view: $0.view) }),
                state: .empty
            )
        )
        #endif
        self._items = []
        self._init()
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
        if let current = self._current?.container {
            if current.activate() == true {
                return true
            }
        }
        if let contentContainer = self.contentContainer {
            return contentContainer.activate()
        }
        return false
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
    
    public func present(container: IQModalContentContainer, animated: Bool, completion: (() -> Void)?) {
        container.parent = self
        let item = Item(container: container)
        self._items.append(item)
        if self._current == nil {
            self._present(modal: item, animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
    
    public func dismiss(container: IQModalContentContainer, animated: Bool, completion: (() -> Void)?) {
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

extension QModalContainer : IQRootContentContainer {
}

private extension QModalContainer {
    
    func _init() {
        #if os(iOS)
        self._interactiveGesture.onShouldBeRequiredToFailBy({ [unowned self] gesture -> Bool in
            guard let contentContainer = self.contentContainer else { return true }
            guard let view = gesture.view else { return false }
            return contentContainer.view.native.isChild(of: view, recursive: true)
        }).onShouldBegin({ [unowned self] in
            guard let current = self._current else { return false }
            guard current.container.shouldInteractive == true else { return false }
            return self._interactiveGesture.contains(in: current.container.view)
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
    
    func _present(current: Item?, next: Item, animated: Bool, completion: (() -> Void)?) {
        if let current = current {
            self._dismiss(modal: current, animated: animated, completion: { [weak self] in
                guard let self = self else { return }
                self._present(modal: next, animated: animated, completion: completion)
            })
        } else {
            self._present(modal: next, animated: animated, completion: completion)
        }
    }

    func _present(modal: Item, animated: Bool, completion: (() -> Void)?) {
        self._current = modal
        modal.container.prepareShow(interactive: false)
        if animated == true {
            QAnimation.default.run(
                duration: TimeInterval(self._view.bounds.size.height / self.animationVelocity),
                ease: QAnimation.Ease.QuadraticInOut(),
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._view.contentLayout.state = .present(modal: modal, progress: progress)
                    self._view.contentLayout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    modal.container.finishShow(interactive: false)
                    self._view.contentLayout.state = .idle(modal: modal)
                    completion?()
                }
            )
        } else {
            modal.container.finishShow(interactive: false)
            self._view.contentLayout.state = .idle(modal: modal)
        }
    }

    func _dismiss(current: Item, previous: Item?, animated: Bool, completion: (() -> Void)?) {
        self._dismiss(modal: current, animated: animated, completion: { [weak self] in
            guard let self = self else { return }
            self._current = previous
            if let previous = previous {
                self._present(modal: previous, animated: animated, completion: completion)
            } else {
                completion?()
            }
        })
    }
    
    func _dismiss(modal: Item, animated: Bool, completion: (() -> Void)?) {
        modal.container.prepareHide(interactive: false)
        if animated == true {
            QAnimation.default.run(
                duration: TimeInterval(self._view.bounds.size.height / self.animationVelocity),
                ease: QAnimation.Ease.QuadraticInOut(),
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._view.contentLayout.state = .dismiss(modal: modal, progress: progress)
                    self._view.contentLayout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    modal.container.finishHide(interactive: false)
                    self._view.contentLayout.state = .empty
                    completion?()
                }
            )
        } else {
            modal.container.finishHide(interactive: false)
            self._view.contentLayout.state = .empty
        }
    }
    
}

#if os(iOS)

private extension QModalContainer {
    
    func _beginInteractiveGesture() {
        guard let current = self._current else { return }
        self._interactiveBeginLocation = self._interactiveGesture.location(in: self._view)
        current.container.prepareHide(interactive: true)
    }
    
    func _changeInteractiveGesture() {
        guard let beginLocation = self._interactiveBeginLocation, let current = self._current else { return }
        let currentLocation = self._interactiveGesture.location(in: self._view)
        let deltaLocation = currentLocation.y - beginLocation.y
        if deltaLocation > 0 {
            let progress = deltaLocation / self._view.bounds.size.height
            self._view.contentLayout.state = .dismiss(modal: current, progress: progress)
        } else {
            self._view.contentLayout.state = .idle(modal: current)
        }
    }

    func _endInteractiveGesture(_ canceled: Bool) {
        guard let beginLocation = self._interactiveBeginLocation, let current = self._current else { return }
        let currentLocation = self._interactiveGesture.location(in: self._view)
        let deltaLocation = currentLocation.y - beginLocation.y
        if deltaLocation < -self.interactiveLimit {
            let height = self._view.bounds.size.height
            QAnimation.default.run(
                duration: TimeInterval(height / self.animationVelocity),
                elapsed: TimeInterval(-deltaLocation / self.animationVelocity),
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._view.contentLayout.state = .dismiss(modal: current, progress: progress)
                    self._view.contentLayout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._finishInteractiveAnimation()
                }
            )
        } else if deltaLocation > 0 {
            let height = self._view.bounds.size.height
            let baseProgress = deltaLocation / pow(height, 1.5)
            QAnimation.default.run(
                duration: TimeInterval((height * baseProgress) / self.animationVelocity),
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._view.contentLayout.state = .present(modal: current, progress: 1 + (baseProgress - (baseProgress * progress)))
                    self._view.contentLayout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._cancelInteractiveAnimation()
                }
            )
        } else {
            self._view.contentLayout.state = .idle(modal: current)
            self._cancelInteractiveAnimation()
        }
    }
    
    func _finishInteractiveAnimation() {
        self._interactiveBeginLocation = nil
        if let current = self._current {
            current.container.finishHide(interactive: true)
            current.container.parent = nil
            if let index = self._items.firstIndex(where: { $0 === current }) {
                self._items.remove(at: index)
            }
            self._previous = self._items.first
            if let previous = self._previous {
                self._present(modal: previous, animated: true, completion: nil)
            } else {
                self._current = nil
                self._view.contentLayout.state = .empty
            }
        } else {
            self._current = nil
            self._view.contentLayout.state = .empty
        }
    }
    
    func _cancelInteractiveAnimation() {
        self._interactiveBeginLocation = nil
        if let current = self._current {
            current.container.cancelHide(interactive: true)
            self._view.contentLayout.state = .idle(modal: current)
        } else {
            self._view.contentLayout.state = .empty
        }
    }
    
}
    
#endif

private extension QModalContainer {
    
    class Item {
        
        var container: IQModalContentContainer
        var item: QLayoutItem

        init(container: IQModalContentContainer) {
            self.container = container
            self.item = QLayoutItem(view: container.view)
        }

    }
    
}

private extension QModalContainer {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
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
            containerInset: QInset,
            contentItem: QLayoutItem?,
            state: State
        ) {
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
            case .idle(let modal):
                modal.item.frame = bounds.apply(inset: self.containerInset)
            case .present(let modal, let progress):
                let beginRect = QRect(bottomLeft: bounds.topLeft, size: bounds.size)
                let endRect = bounds.apply(inset: self.containerInset)
                modal.item.frame = beginRect.lerp(endRect, progress: progress)
            case .dismiss(let modal, let progress):
                let beginRect = bounds.apply(inset: self.containerInset)
                let endRect = QRect(bottomLeft: bounds.topLeft, size: bounds.size)
                modal.item.frame = beginRect.lerp(endRect, progress: progress)
            }
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            var items: [QLayoutItem] = []
            if let contentItem = self.contentItem {
                items.append(contentItem)
            }
            switch self.state {
            case .empty: break
            case .idle(let modal): items.append(modal.item)
            case .present(let modal, _): items.append(modal.item)
            case .dismiss(let modal, _): items.append(modal.item)
            }
            return items
        }
        
    }
    
}

private extension QModalContainer.Layout {
    
    enum State {
        case empty
        case idle(modal: QModalContainer.Item)
        case present(modal: QModalContainer.Item, progress: Float)
        case dismiss(modal: QModalContainer.Item, progress: Float)
    }
    
}
