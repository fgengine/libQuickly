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
        guard let current = self._current else { return self._contentContainer.statusBarHidden }
        return current.container.statusBarHidden
    }
    public var statusBarStyle: UIStatusBarStyle {
        guard let current = self._current else { return self._contentContainer.statusBarStyle }
        return current.container.statusBarStyle
    }
    public var statusBarAnimation: UIStatusBarAnimation {
        guard let current = self._current else { return self._contentContainer.statusBarAnimation }
        return current.container.statusBarAnimation
    }
    public var supportedOrientations: UIInterfaceOrientationMask {
        guard let current = self._current else { return self._contentContainer.supportedOrientations }
        return current.container.supportedOrientations
    }
    #endif
    public private(set) var isPresented: Bool
    public var view: IQView {
        return self._view
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
    
    public init(
        contentContainer: IQContainer & IQContainerParentable
    ) {
        self.isPresented = false
        #if os(iOS)
        self.animationVelocity = 500
        self.interactiveLimit = 20
        #endif
        self._contentContainer = contentContainer
        self._layout = Layout(
            containerInset: QInset(),
            contentItem: QLayoutItem(view: contentContainer.view),
            state: .empty
        )
        #if os(iOS)
        self._interactiveGesture = QPanGesture(name: "QModalContainer-PanGesture")
        self._view = QCustomView(
            name: "QModalContainer-RootView",
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
                    self._layout.state = .present(modal: modal, progress: progress)
                    self._layout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    modal.container.finishShow(interactive: false)
                    self._layout.state = .idle(modal: modal)
                    completion?()
                }
            )
        } else {
            modal.container.finishShow(interactive: false)
            self._layout.state = .idle(modal: modal)
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
                    self._layout.state = .dismiss(modal: modal, progress: progress)
                    self._layout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    modal.container.finishHide(interactive: false)
                    self._layout.state = .empty
                    completion?()
                }
            )
        } else {
            modal.container.finishHide(interactive: false)
            self._layout.state = .empty
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
            self._layout.state = .dismiss(modal: current, progress: progress)
        } else {
            self._layout.state = .idle(modal: current)
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
                    self._layout.state = .dismiss(modal: current, progress: progress)
                    self._layout.updateIfNeeded()
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
                    self._layout.state = .present(modal: current, progress: 1 + (baseProgress - (baseProgress * progress)))
                    self._layout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._cancelInteractiveAnimation()
                }
            )
        } else {
            self._layout.state = .idle(modal: current)
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
                self._layout.state = .empty
            }
        } else {
            self._current = nil
            self._layout.state = .empty
        }
    }
    
    func _cancelInteractiveAnimation() {
        self._interactiveBeginLocation = nil
        if let current = self._current {
            current.container.cancelHide(interactive: true)
            self._layout.state = .idle(modal: current)
        } else {
            self._layout.state = .empty
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
            didSet { self.setNeedForceUpdate() }
        }
        var contentItem: QLayoutItem {
            didSet { self.setNeedForceUpdate() }
        }
        var state: State {
            didSet { self.setNeedUpdate() }
        }

        init(
            containerInset: QInset,
            contentItem: QLayoutItem,
            state: State
        ) {
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
            switch self.state {
            case .empty: return [ self.contentItem ]
            case .idle(let modal): return [ self.contentItem, modal.item ]
            case .present(let modal, _): return [ self.contentItem, modal.item ]
            case .dismiss(let modal, _): return [ self.contentItem, modal.item ]
            }
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
