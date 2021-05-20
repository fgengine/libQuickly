//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QStackContainer< Screen : IQScreen > : IQStackContainer, IQContainerScreenable {
    
    public unowned var parent: IQContainer? {
        didSet(oldValue) {
            if self.parent !== oldValue {
                self.didChangeInsets()
            }
        }
    }
    public var shouldInteractive: Bool {
        return self._currentItem.container.shouldInteractive
    }
    #if os(iOS)
    public var statusBarHidden: Bool {
        return self._currentItem.container.statusBarHidden
    }
    public var statusBarStyle: UIStatusBarStyle {
        return self._currentItem.container.statusBarStyle
    }
    public var statusBarAnimation: UIStatusBarAnimation {
        return self._currentItem.container.statusBarAnimation
    }
    public var supportedOrientations: UIInterfaceOrientationMask {
        return self._currentItem.container.supportedOrientations
    }
    #endif
    public private(set) var isPresented: Bool
    public private(set) var screen: Screen
    public var view: IQView {
        return self._view
    }
    public var rootContainer: IQStackContentContainer {
        return self._rootItem.container
    }
    public var containers: [IQStackContentContainer] {
        return self._items.compactMap({ $0.container })
    }
    public var currentContainer: IQStackContentContainer {
        return self._currentItem.container
    }
    public var animationVelocity: Float
    #if os(iOS)
    public var interactiveLimit: Float
    #endif
    
    private var _rootItem: Item
    private var _items: [Item]
    private var _layout: Layout
    private var _view: QCustomView< Layout >
    #if os(iOS)
    private var _interactiveGesture: IQPanGesture
    private var _interactiveBeginLocation: QPoint?
    private var _interactiveBackward: Item?
    private var _interactiveCurrent: Item?
    #endif
    @inline(__always)
    private var _currentItem: Item {
        return self._items.last ?? self._rootItem
    }
    
    public init(
        screen: Screen,
        rootContainer: IQStackContentContainer
    ) {
        self.isPresented = false
        self.screen = screen
        #if os(iOS)
        self.animationVelocity = UIScreen.main.animationVelocity
        self.interactiveLimit = Float(UIScreen.main.bounds.width * 0.45)
        #endif
        self._rootItem = Item(
            container: rootContainer,
            insets: QInset()
        )
        self._layout = Layout(
            state: .idle(current: self._rootItem.item)
        )
        #if os(iOS)
        self._interactiveGesture = QPanGesture(name: "QStackContainer-PanGesture", screenEdge: .left)
        self._view = QCustomView(
            name: "QStackContainer-RootView",
            gestures: [ self._interactiveGesture ],
            contentLayout: self._layout
        )
        #else
        self._view = QCustomView(
            layout: self._layout
        )
        #endif
        self._items = []
        self._init()
    }
    
    public func insets(of container: IQContainer) -> QInset {
        let inheritedInsets = self.inheritedInsets
        let item: Item?
        if self._rootItem.container === container {
            item = self._rootItem
        } else {
            item = self._items.first(where: { $0.container === container })
        }
        if let item = item {
            let stackItemSize: Float
            if item.container.stackBarHidden == false {
                stackItemSize = item.container.stackBarSize
            } else {
                stackItemSize = 0
            }
            return QInset(
                top: inheritedInsets.top + stackItemSize,
                left: inheritedInsets.left,
                right: inheritedInsets.right,
                bottom: inheritedInsets.bottom
            )
        }
        return inheritedInsets
    }
    
    public func didChangeInsets() {
        let inheritedInsets = self.inheritedInsets
        self._rootItem.set(insets: inheritedInsets)
        self._rootItem.container.didChangeInsets()
        for item in self._items {
            item.set(insets: inheritedInsets)
            item.container.didChangeInsets()
        }
    }
    
    public func activate() -> Bool {
        if self.screen.activate() == true {
            return true
        }
        if self._items.count > 0 {
            self.popToRoot()
            return true
        }
        return self._rootItem.container.activate()
    }
    
    public func prepareShow(interactive: Bool) {
        self.screen.prepareShow(interactive: interactive)
        self._currentItem.container.prepareShow(interactive: interactive)
    }
    
    public func finishShow(interactive: Bool) {
        self.isPresented = true
        self.screen.finishShow(interactive: interactive)
        self._currentItem.container.finishShow(interactive: interactive)
    }
    
    public func cancelShow(interactive: Bool) {
        self.screen.cancelShow(interactive: interactive)
        self._currentItem.container.cancelShow(interactive: interactive)
    }
    
    public func prepareHide(interactive: Bool) {
        self.screen.prepareHide(interactive: interactive)
        self._currentItem.container.prepareHide(interactive: interactive)
    }
    
    public func finishHide(interactive: Bool) {
        self.isPresented = false
        self.screen.finishHide(interactive: interactive)
        self._currentItem.container.finishHide(interactive: interactive)
    }
    
    public func cancelHide(interactive: Bool) {
        self.screen.cancelHide(interactive: interactive)
        self._currentItem.container.cancelHide(interactive: interactive)
    }
    
    public func update(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?) {
        guard let item = self._items.first(where: { $0.container === container }) else {
            completion?()
            return
        }
        item.update()
    }
    
    public func set(rootContainer: IQStackContentContainer, animated: Bool, completion: (() -> Void)?) {
        let inheritedInsets = self.inheritedInsets
        let newRootItem = Item(container: rootContainer, insets: inheritedInsets)
        newRootItem.container.parent = self
        let oldRootItem = self._rootItem
        self._rootItem = newRootItem
        if self._items.isEmpty == true {
            self._push(current: oldRootItem, forward: newRootItem, animated: animated, completion: {
                oldRootItem.container.parent = nil
                completion?()
            })
        } else {
            oldRootItem.container.parent = nil
            completion?()
        }
    }

    public func set(containers: [IQStackContentContainer], animated: Bool, completion: (() -> Void)?) {
        let current = self._currentItem
        let removeItems = self._items.filter({ item in
            return containers.contains(where: { item.container === $0 }) == false
        })
        let inheritedInsets = self.inheritedInsets
        self._items = containers.compactMap({ Item(container: $0, insets: inheritedInsets) })
        for item in self._items {
            item.container.parent = self
        }
        let forward = self._items.last
        if current !== forward {
            self._push(current: current, forward: forward, animated: animated, completion: {
                for item in removeItems {
                    item.container.parent = nil
                }
                completion?()
            })
        } else {
            for item in removeItems {
                item.container.parent = nil
            }
            completion?()
        }
    }
    
    public func push(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?) {
        guard self._items.contains(where: { $0.container === container }) == false else {
            completion?()
            return
        }
        let forward = Item(container: container, insets: self.inheritedInsets)
        let current = self._currentItem
        self._items.append(forward)
        container.parent = self
        self._push(current: current, forward: forward, animated: animated, completion: completion)
    }
    
    public func push(containers: [IQStackContentContainer], animated: Bool, completion: (() -> Void)?) {
        let newContainers = containers.filter({ container in
            return self._items.contains(where: { container === $0.container }) == false
        })
        if newContainers.count > 0 {
            let current = self._currentItem
            let inheritedInsets = self.inheritedInsets
            let items: [Item] = newContainers.compactMap({ Item(container: $0, insets: inheritedInsets) })
            for item in items {
                item.container.parent = self
            }
            self._items.append(contentsOf: items)
            self._push(current: current, forward: items.last, animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
    
    public func push< Wireframe: IQWireframe >(wireframe: Wireframe, animated: Bool, completion: (() -> Void)?) where Wireframe : AnyObject, Wireframe.Container : IQStackContentContainer {
        guard self._items.contains(where: { $0.container === wireframe.container }) == false else {
            completion?()
            return
        }
        let forward = Item(container: wireframe.container, owner: wireframe, insets: self.inheritedInsets)
        let current = self._currentItem
        self._items.append(forward)
        wireframe.container.parent = self
        self._push(current: current, forward: forward, animated: animated, completion: completion)
    }

    public func pop(animated: Bool, completion: (() -> Void)?) {
        if self._items.count > 0 {
            let current = self._items.removeLast()
            let backward = self._items.last ?? self._rootItem
            self._pop(current: current, backward: backward, animated: animated, completion: {
                current.container.parent = nil
                completion?()
            })
        } else {
            completion?()
        }
    }
    
    public func popTo(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?) {
        if self._rootItem.container === container {
            self.popToRoot(animated: animated, completion: completion)
        } else {
            guard let index = self._items.firstIndex(where: { $0.container === container }) else {
                completion?()
                return
            }
            if index != self._items.count - 1 {
                let current = self._items.last
                let backward = self._items[index]
                let range = index + 1 ..< self._items.count - 1
                let removing = self._items[range]
                self._items.removeSubrange(range)
                self._pop(current: current, backward: backward, animated: animated, completion: {
                    for item in removing {
                        item.container.parent = nil
                    }
                    completion?()
                })
            } else {
                completion?()
            }
        }
    }
    
    public func popToRoot(animated: Bool, completion: (() -> Void)?) {
        if self._items.count > 0 {
            let current = self._items.last
            let removing = self._items
            self._items.removeAll()
            self._pop(current: current, backward: self._rootItem, animated: animated, completion: {
                for item in removing {
                    item.container.parent = nil
                }
                completion?()
            })
        } else {
            completion?()
        }
    }

}

extension QStackContainer : IQRootContentContainer {
}

extension QStackContainer : IQGroupContentContainer where Screen : IQScreenGroupable {
    
    public var groupItemView: IQBarItemView {
        return self.screen.groupItemView
    }
    
}

extension QStackContainer : IQDialogContentContainer where Screen : IQScreenDialogable {
    
    public var dialogWidth: QDialogContentContainerSize {
        return self.screen.dialogWidth
    }
    
    public var dialogHeight: QDialogContentContainerSize {
        return self.screen.dialogHeight
    }
    
    public var dialogAlignment: QDialogContentContainerAlignment {
        return self.screen.dialogAlignment
    }
    
}

private extension QStackContainer {
    
    class Item {
        
        var container: IQStackContentContainer
        var owner: AnyObject?
        var view: IQView {
            return self.item.view
        }
        var item: QLayoutItem

        private var _layout: Layout
        
        init(
            container: IQStackContentContainer,
            owner: AnyObject? = nil,
            insets: QInset
        ) {
            container.stackBarView.safeArea(QInset(top: insets.top, left: insets.left, right: insets.right))
            self._layout = Layout(
                barInset: insets.top,
                barSize: container.stackBarSize,
                barVisibility: container.stackBarVisibility,
                barHidden: container.stackBarHidden,
                barItem: QLayoutItem(view: container.stackBarView),
                contentItem: QLayoutItem(view: container.view)
            )
            self.container = container
            self.owner = owner
            self.item = QLayoutItem(
                view: QCustomView(
                    name: "QStackContainer-ContentView",
                    contentLayout: self._layout
                )
            )
        }
        
        func set(insets: QInset) {
            self.container.stackBarView.safeArea(QInset(top: insets.top, left: insets.left, right: insets.right))
            self._layout.barInset = insets.top
        }
        
        func update() {
            self._layout.barSize = self.container.stackBarSize
            self._layout.barVisibility = self.container.stackBarVisibility
            self._layout.barHidden = self.container.stackBarHidden
        }

    }
    
}

private extension QStackContainer.Item {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var barInset: Float {
            didSet { self.setNeedForceUpdate() }
        }
        var barSize: Float {
            didSet { self.setNeedForceUpdate() }
        }
        var barVisibility: Float {
            didSet { self.setNeedForceUpdate() }
        }
        var barHidden: Bool {
            didSet { self.setNeedForceUpdate() }
        }
        var barItem: QLayoutItem {
            didSet { self.setNeedForceUpdate() }
        }
        var contentItem: QLayoutItem

        init(
            barInset: Float,
            barSize: Float,
            barVisibility: Float,
            barHidden: Bool,
            barItem: QLayoutItem,
            contentItem: QLayoutItem
        ) {
            self.barInset = barInset
            self.barSize = barSize
            self.barVisibility = barVisibility
            self.barHidden = barHidden
            self.barItem = barItem
            self.contentItem = contentItem
        }
        
        func invalidate(item: QLayoutItem) {
        }
        
        func invalidate() {
        }
        
        func layout(bounds: QRect) -> QSize {
            let barSize = self.barInset + self.barSize
            let barOffset = barSize * (1 - self.barVisibility)
            self.barItem.frame = QRect(
                x: bounds.origin.x,
                y: bounds.origin.y - barOffset,
                width: bounds.size.width,
                height: barSize
            )
            self.contentItem.frame = bounds
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            var items: [QLayoutItem] = [ self.contentItem ]
            if self.barHidden == false {
                items.append(self.barItem)
            }
            return items
        }
        
    }
    
}

private extension QStackContainer {
    
    class Layout : IQLayout {
        
        enum State {
            case empty
            case idle(current: QLayoutItem)
            case push(current: QLayoutItem, forward: QLayoutItem, progress: Float)
            case pop(backward: QLayoutItem, current: QLayoutItem, progress: Float)
        }
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var state: State {
            didSet { self.setNeedUpdate() }
        }

        init(state: State = .empty) {
            self.state = state
        }
        
        func invalidate(item: QLayoutItem) {
        }
        
        func invalidate() {
        }
        
        func layout(bounds: QRect) -> QSize {
            let forwardFrame = QRect(topLeft: bounds.topRight, size: bounds.size)
            let currentFrame = bounds
            let backwardFrame = QRect(topRight: bounds.topLeft, size: bounds.size)
            switch self.state {
            case .empty:
                break
            case .idle(let current):
                current.frame = currentFrame
            case .push(let current, let forward, let progress):
                forward.frame = forwardFrame.lerp(currentFrame, progress: progress)
                current.frame = currentFrame.lerp(backwardFrame, progress: progress)
            case .pop(let backward, let current, let progress):
                current.frame = currentFrame.lerp(forwardFrame, progress: progress)
                backward.frame = backwardFrame.lerp(currentFrame, progress: progress)
            }
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            switch self.state {
            case .empty: return []
            case .idle(let current): return [ current ]
            case .push(let current, let forward, _): return [ current, forward ]
            case .pop(let backward, let current, _): return [ backward, current ]
            }
        }
        
    }
    
}

private extension QStackContainer {
    
    func _init() {
        self._rootItem.container.parent = self
        #if os(iOS)
        self._interactiveGesture.onShouldBeRequiredToFailBy({ [unowned self] gesture in
            guard let gestureView = gesture.view else { return false }
            guard self._view.native.isChild(of: gestureView, recursive: true) == true else { return false }
            return true
        }).onShouldBegin({ [unowned self] in
            guard self._items.count > 0 else { return false }
            guard self.shouldInteractive == true else { return false }
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
        #else
        #endif
    }
    
    func _push(
        current: Item?,
        forward: Item?,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        if animated == true {
            if let current = current, let forward = forward {
                if self.isPresented == true {
                    current.container.prepareHide(interactive: false)
                    forward.container.prepareShow(interactive: false)
                }
                QAnimation.default.run(
                    duration: TimeInterval(self._view.contentSize.width / self.animationVelocity),
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._layout.state = .push(current: current.item, forward: forward.item, progress: progress)
                        self._layout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self._layout.state = .idle(current: forward.item)
                        if self.isPresented == true {
                            current.container.finishHide(interactive: false)
                            forward.container.finishShow(interactive: false)
                        }
                        self.setNeedUpdateOrientations()
                        self.setNeedUpdateStatusBar()
                        completion?()
                    }
                )
            } else if let forward = forward {
                if self.isPresented == true {
                    forward.container.prepareShow(interactive: false)
                }
                self._layout.state = .idle(current: forward.item)
                if self.isPresented == true {
                    forward.container.finishShow(interactive: false)
                }
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
                completion?()
            } else if let current = current {
                if self.isPresented == true {
                    current.container.prepareHide(interactive: false)
                }
                self._layout.state = .empty
                if self.isPresented == true {
                    current.container.finishHide(interactive: false)
                }
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
                completion?()
            } else {
                self._layout.state = .empty
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
                completion?()
            }
        } else if let current = current, let forward = forward {
            if self.isPresented == true {
                current.container.prepareHide(interactive: false)
                forward.container.prepareShow(interactive: false)
            }
            self._layout.state = .idle(current: forward.item)
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
                forward.container.finishShow(interactive: false)
            }
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        } else if let forward = forward {
            if self.isPresented == true {
                forward.container.prepareShow(interactive: false)
            }
            self._layout.state = .idle(current: forward.item)
            if self.isPresented == true {
                forward.container.finishShow(interactive: false)
            }
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        } else if let current = current {
            if self.isPresented == true {
                current.container.prepareHide(interactive: false)
            }
            self._layout.state = .empty
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
            }
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        } else {
            self._layout.state = .empty
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        }
    }
    
    func _pop(
        current: Item?,
        backward: Item?,
        animated: Bool,
        completion: (() -> Void)?
    ) {
        if animated == true {
            if let current = current, let backward = backward {
                if self.isPresented == true {
                    current.container.prepareHide(interactive: false)
                    backward.container.prepareShow(interactive: false)
                }
                QAnimation.default.run(
                    duration: TimeInterval(self._view.contentSize.width / self.animationVelocity),
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._layout.state = .pop(backward: backward.item, current: current.item, progress: progress)
                        self._layout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self._layout.state = .idle(current: backward.item)
                        if self.isPresented == true {
                            current.container.finishHide(interactive: false)
                            backward.container.finishShow(interactive: false)
                        }
                        self.setNeedUpdateOrientations()
                        self.setNeedUpdateStatusBar()
                        completion?()
                    }
                )
            } else if let backward = backward {
                if self.isPresented == true {
                    backward.container.prepareShow(interactive: false)
                }
                self._layout.state = .idle(current: backward.item)
                if self.isPresented == true {
                    backward.container.finishShow(interactive: false)
                }
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
                completion?()
            } else if let current = current {
                if self.isPresented == true {
                    current.container.prepareHide(interactive: false)
                }
                self._layout.state = .empty
                if self.isPresented == true {
                    current.container.finishHide(interactive: false)
                }
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
                completion?()
            } else {
                self._layout.state = .empty
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
                completion?()
            }
        } else if let current = current, let backward = backward {
            if self.isPresented == true {
                current.container.prepareHide(interactive: false)
                backward.container.prepareShow(interactive: false)
            }
            self._layout.state = .idle(current: backward.item)
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
                backward.container.finishShow(interactive: false)
            }
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        } else if let backward = backward {
            if self.isPresented == true {
                backward.container.prepareShow(interactive: false)
            }
            self._layout.state = .idle(current: backward.item)
            if self.isPresented == true {
                backward.container.finishShow(interactive: false)
            }
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        } else if let current = current {
            if self.isPresented == true {
                current.container.prepareHide(interactive: false)
            }
            self._layout.state = .empty
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
            }
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        } else {
            self._layout.state = .empty
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        }
    }
    
}
    
#if os(iOS)

private extension QStackContainer {
    
    func _beginInteractiveGesture() {
        self._interactiveBeginLocation = self._interactiveGesture.location(in: self._view)
        let backward = self._items.count > 1 ? self._items[self._items.count - 2] : self._rootItem
        backward.container.prepareShow(interactive: true)
        self._interactiveBackward = backward
        let current = self._items[self._items.count - 1]
        current.container.prepareHide(interactive: true)
        self._interactiveCurrent = current
    }
    
    func _changeInteractiveGesture() {
        guard let beginLocation = self._interactiveBeginLocation, let backward = self._interactiveBackward, let current = self._interactiveCurrent else { return }
        let currentLocation = self._interactiveGesture.location(in: self._view)
        let deltaLocation = currentLocation - beginLocation
        let layoutSize = self._view.contentSize
        let progress = max(0, deltaLocation.x / layoutSize.width)
        self._layout.state = .pop(backward: backward.item, current: current.item, progress: progress)
    }

    func _endInteractiveGesture(_ canceled: Bool) {
        guard let beginLocation = self._interactiveBeginLocation, let backward = self._interactiveBackward, let current = self._interactiveCurrent else { return }
        let currentLocation = self._interactiveGesture.location(in: self._view)
        let deltaLocation = currentLocation - beginLocation
        let layoutSize = self._view.contentSize
        if deltaLocation.x >= self.interactiveLimit && canceled == false {
            QAnimation.default.run(
                duration: TimeInterval(layoutSize.width / self.animationVelocity),
                elapsed: TimeInterval(deltaLocation.x / self.animationVelocity),
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._layout.state = .pop(backward: backward.item, current: current.item, progress: progress)
                    self._layout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._finishInteractiveAnimation()
                }
            )
        } else {
            QAnimation.default.run(
                duration: TimeInterval(layoutSize.width / self.animationVelocity),
                elapsed: TimeInterval((layoutSize.width - deltaLocation.x) / self.animationVelocity),
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._layout.state = .pop(backward: backward.item, current: current.item, progress: 1 - progress)
                    self._layout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._cancelInteractiveAnimation()
                }
            )
        }
    }
    
    func _finishInteractiveAnimation() {
        guard let backward = self._interactiveBackward, let current = self._interactiveCurrent else { return }
        self._items.remove(at: self._items.count - 1)
        self._layout.state = .idle(current: backward.item)
        current.container.finishHide(interactive: true)
        backward.container.finishShow(interactive: true)
        current.container.parent = nil
        self._resetInteractiveAnimation()
        self.setNeedUpdateOrientations()
        self.setNeedUpdateStatusBar()
    }
    
    func _cancelInteractiveAnimation() {
        guard let backward = self._interactiveBackward, let current = self._interactiveCurrent else { return }
        self._layout.state = .idle(current: current.item)
        current.container.cancelHide(interactive: true)
        backward.container.cancelShow(interactive: true)
        self._resetInteractiveAnimation()
        self.setNeedUpdateOrientations()
        self.setNeedUpdateStatusBar()
    }
    
    func _resetInteractiveAnimation() {
        self._interactiveBeginLocation = nil
        self._interactiveBackward = nil
        self._interactiveCurrent = nil
    }
    
}
    
#endif
