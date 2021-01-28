//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QStackContainer< Screen : IQScreen > : IQStackContainer, IQContainerScreenable {
    
    public weak var parentContainer: IQContainer? {
        didSet(oldValue) {
            if self.parentContainer !== oldValue {
                self.didChangeInsets()
            }
        }
    }
    #if os(iOS)
    public var statusBarHidden: Bool {
        return self.currentContainer?.statusBarHidden ?? false
    }
    public var statusBarStyle: UIStatusBarStyle {
        return self.currentContainer?.statusBarStyle ?? .default
    }
    public var statusBarAnimation: UIStatusBarAnimation {
        return self.currentContainer?.statusBarAnimation ?? .fade
    }
    public var supportedOrientations: UIInterfaceOrientationMask {
        return self.currentContainer?.supportedOrientations ?? .all
    }
    #endif
    public private(set) var isPresented: Bool
    public var view: IQView {
        return self._rootView
    }
    public private(set) var screen: Screen
    #if os(iOS)
    public var interactiveLimit: QFloat
    public var interactiveVelocity: QFloat
    #endif
    public var containers: [IQStackContentContainer] {
        return self._items.compactMap({ $0.container })
    }
    public var rootContainer: IQStackContentContainer? {
        return self._items.first?.container
    }
    public var currentContainer: IQStackContentContainer? {
        return self._items.last?.container
    }
    
    private var _rootView: QCustomView
    private var _rootLayout: RootLayout
    #if os(iOS)
    private var _interactiveGesture: IQPanGesture
    private var _interactiveBeginLocation: QPoint?
    private var _interactiveBackward: Item?
    private var _interactiveCurrent: Item?
    #endif
    private var _items: [Item]
    
    public init(screen: Screen) {
        self.isPresented = false
        self.screen = screen
        #if os(iOS)
        self.interactiveLimit = QFloat(UIScreen.main.bounds.width * 0.45)
        self.interactiveVelocity = QFloat(UIScreen.main.bounds.width * 5)
        #endif
        self._rootLayout = RootLayout()
        #if os(iOS)
        self._interactiveGesture = QPanGesture(screenEdge: .left)
        self._rootView = QCustomView(
            gestures: [ self._interactiveGesture ],
            layout: self._rootLayout
        )
        #else
        self._rootView = QCustomView(
            layout: self._rootLayout
        )
        #endif
        self._items = []
        self._init()
    }
    
    public func insets(of container: IQContainer) -> QInset {
        let inheritedInsets = self.inheritedInsets
        if let item = self._items.first(where: { $0.container === container }) {
            let stackItemSize: QFloat
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
        for item in self._items {
            item.set(insets: inheritedInsets)
            item.container.didChangeInsets()
        }
    }
    
    public func prepareShow(interactive: Bool) {
        self._items.last?.container.prepareShow(interactive: interactive)
    }
    
    public func finishShow(interactive: Bool) {
        self.isPresented = true
        self._items.last?.container.finishShow(interactive: interactive)
    }
    
    public func cancelShow(interactive: Bool) {
        self._items.last?.container.cancelShow(interactive: interactive)
    }
    
    public func prepareHide(interactive: Bool) {
        self._items.last?.container.prepareHide(interactive: interactive)
    }
    
    public func finishHide(interactive: Bool) {
        self.isPresented = false
        self._items.last?.container.finishHide(interactive: interactive)
    }
    
    public func cancelHide(interactive: Bool) {
        self._items.last?.container.cancelHide(interactive: interactive)
    }
    
    public func update(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?) {
        guard let item = self._items.first(where: { $0.container === container }) else {
            completion?()
            return
        }
        item.update()
    }
    
    public func set(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?) {
        self.set(containers: [ container ], animated: animated, completion: completion)
    }

    public func set(containers: [IQStackContentContainer], animated: Bool, completion: (() -> Void)?) {
        let current = self._items.last
        let removeItems = self._items.filter({ item in
            return containers.contains(where: { item.container === $0 && current?.container !== $0 }) == false
        })
        for item in removeItems {
            item.container.stackContainer = nil
        }
        let inheritedInsets = self.inheritedInsets
        self._items = containers.compactMap({ Item(container: $0, insets: inheritedInsets) })
        for item in self._items {
            item.container.stackContainer = self
        }
        let forward = self._items.last
        if current !== forward {
            self._push(current: current, forward: forward, animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
    
    public func push(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?) {
        guard self._items.contains(where: { $0.container === container }) == false else {
            completion?()
            return
        }
        let forward = Item(container: container, insets: self.inheritedInsets)
        let current = self._items.last
        self._items.append(forward)
        container.stackContainer = self
        self._push(current: current, forward: forward, animated: animated, completion: completion)
    }
    
    public func push(containers: [IQStackContentContainer], animated: Bool, completion: (() -> Void)?) {
        let newContainers = containers.filter({ container in
            return self._items.contains(where: { container === $0.container }) == false
        })
        if newContainers.count > 0 {
            let current = self._items.last
            let inheritedInsets = self.inheritedInsets
            let items: [Item] = newContainers.compactMap({ Item(container: $0, insets: inheritedInsets) })
            for item in items {
                item.container.stackContainer = self
            }
            self._items.append(contentsOf: items)
            self._push(current: current, forward: items.last, animated: animated, completion: completion)
        } else {
            completion?()
        }
    }

    public func pop(animated: Bool, completion: (() -> Void)?) {
        if self._items.count > 1 {
            let current = self._items.removeLast()
            let backward = self._items.last
            self._pop(current: current, backward: backward, animated: animated, completion: {
                current.container.stackContainer = nil
                completion?()
            })
        } else {
            completion?()
        }
    }
    
    public func popTo(container: IQStackContentContainer, animated: Bool, completion: (() -> Void)?) {
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
                    item.container.stackContainer = nil
                }
                completion?()
            })
        } else {
            completion?()
        }
    }
    
    public func popToRoot(animated: Bool, completion: (() -> Void)?) {
        if self._items.count > 1 {
            let current = self._items.last
            let root = self._items.first
            let range = 1 ..< self._items.count - 1
            let removing = self._items[range]
            self._items.removeSubrange(range)
            self._pop(current: current, backward: root, animated: animated, completion: {
                for item in removing {
                    item.container.stackContainer = nil
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

private extension QStackContainer {
    
    class Item {
        
        var container: IQStackContentContainer
        var pageView: QCustomView
        var pageItem: IQLayoutItem

        private var _layout: ItemLayout
        
        init(
            container: IQStackContentContainer,
            insets: QInset
        ) {
            container.stackBarView.safeArea(QInset(top: insets.top, left: insets.left, right: insets.right))
            self._layout = ItemLayout(
                barInset: insets.top,
                barSize: container.stackBarSize,
                barVisibility: container.stackBarVisibility,
                barHidden: container.stackBarHidden,
                barItem: QLayoutItem(view: container.stackBarView),
                contentItem: QLayoutItem(view: container.view)
            )
            self.container = container
            self.pageView = QCustomView(layout: self._layout)
            self.pageItem = QLayoutItem(view: self.pageView)
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
    
    class ItemLayout : IQLayout {
        
        weak var delegate: IQLayoutDelegate?
        weak var parentView: IQView?
        var barInset: QFloat {
            didSet { self.setNeedUpdate() }
        }
        var barSize: QFloat {
            didSet { self.setNeedUpdate() }
        }
        var barVisibility: QFloat {
            didSet { self.setNeedUpdate() }
        }
        var barHidden: Bool {
            didSet { self.setNeedUpdate() }
        }
        var barItem: IQLayoutItem {
            didSet { self.setNeedUpdate() }
        }
        var contentItem: IQLayoutItem

        init(
            barInset: QFloat,
            barSize: QFloat,
            barVisibility: QFloat,
            barHidden: Bool,
            barItem: IQLayoutItem,
            contentItem: IQLayoutItem
        ) {
            self.barInset = barInset
            self.barSize = barSize
            self.barVisibility = barVisibility
            self.barHidden = barHidden
            self.barItem = barItem
            self.contentItem = contentItem
        }
        
        func layout(bounds: QRect) -> QSize {
            self.barItem.frame = QRect(
                x: bounds.origin.x,
                y: bounds.origin.y,
                width: bounds.size.width,
                height: self.barInset + self.barSize
            )
            self.contentItem.frame = bounds
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [IQLayoutItem] {
            var items: [IQLayoutItem] = [ self.contentItem ]
            if self.barHidden == false {
                items.append(self.barItem)
            }
            return items
        }
        
    }
    
    class RootLayout : IQLayout {
        
        enum State {
            case empty
            case idle(current: IQLayoutItem)
            case push(current: IQLayoutItem, forward: IQLayoutItem, progress: QFloat)
            case pop(backward: IQLayoutItem, current: IQLayoutItem, progress: QFloat)
        }
        
        weak var delegate: IQLayoutDelegate?
        weak var parentView: IQView?
        var state: State {
            didSet { self.setNeedUpdate() }
        }

        init(state: State = .empty) {
            self.state = state
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
        
        func items(bounds: QRect) -> [IQLayoutItem] {
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
        self.screen.container = self
        #if os(iOS)
        self._interactiveGesture.onShouldBegin({ [weak self] in
            guard let self = self else { return false }
            return self._items.count > 1
        }).onShouldBeRequiredToFailBy({ [weak self] gesture in
            guard let self = self else { return false }
            guard let gestureView = gesture.view else { return false }
            return self._rootView.native.isChild(of: gestureView, recursive: true)
        }).onBegin({ [weak self] in
            self?._beginInteractiveGesture()
        }) .onChange({ [weak self] in
            self?._changeInteractiveGesture()
        }).onCancel({ [weak self] in
            self?._endInteractiveGesture(true)
        }).onEnd({ [weak self] in
            self?._endInteractiveGesture(false)
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
                    duration: 0.2,
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._rootLayout.state = .push(current: current.pageItem, forward: forward.pageItem, progress: progress)
                        self._rootLayout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self._rootLayout.state = .idle(current: forward.pageItem)
                        if self.isPresented == true {
                            current.container.finishHide(interactive: false)
                            forward.container.finishShow(interactive: false)
                        }
                        completion?()
                    }
                )
            } else if let forward = forward {
                if self.isPresented == true {
                    forward.container.prepareShow(interactive: false)
                }
                self._rootLayout.state = .idle(current: forward.pageItem)
                if self.isPresented == true {
                    forward.container.finishShow(interactive: false)
                }
                completion?()
            } else if let current = current {
                if self.isPresented == true {
                    current.container.prepareHide(interactive: false)
                }
                self._rootLayout.state = .empty
                if self.isPresented == true {
                    current.container.finishHide(interactive: false)
                }
                completion?()
            } else {
                self._rootLayout.state = .empty
                completion?()
            }
        } else if let current = current, let forward = forward {
            if self.isPresented == true {
                current.container.prepareHide(interactive: false)
                forward.container.prepareShow(interactive: false)
            }
            self._rootLayout.state = .idle(current: forward.pageItem)
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
                forward.container.finishShow(interactive: false)
            }
        } else if let forward = forward {
            if self.isPresented == true {
                forward.container.prepareShow(interactive: false)
            }
            self._rootLayout.state = .idle(current: forward.pageItem)
            if self.isPresented == true {
                forward.container.finishShow(interactive: false)
            }
            completion?()
        } else if let current = current {
            if self.isPresented == true {
                current.container.prepareHide(interactive: false)
            }
            self._rootLayout.state = .empty
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
            }
            completion?()
        } else {
            self._rootLayout.state = .empty
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
                    duration: 0.2,
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._rootLayout.state = .pop(backward: backward.pageItem, current: current.pageItem, progress: progress)
                        self._rootLayout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self._rootLayout.state = .idle(current: backward.pageItem)
                        if self.isPresented == true {
                            current.container.finishHide(interactive: false)
                            backward.container.finishShow(interactive: false)
                        }
                        completion?()
                    }
                )
            } else if let backward = backward {
                if self.isPresented == true {
                    backward.container.prepareShow(interactive: false)
                }
                self._rootLayout.state = .idle(current: backward.pageItem)
                if self.isPresented == true {
                    backward.container.finishShow(interactive: false)
                }
                completion?()
            } else if let current = current {
                if self.isPresented == true {
                    current.container.prepareHide(interactive: false)
                }
                self._rootLayout.state = .empty
                if self.isPresented == true {
                    current.container.finishHide(interactive: false)
                }
                completion?()
            } else {
                self._rootLayout.state = .empty
                completion?()
            }
        } else if let current = current, let backward = backward {
            if self.isPresented == true {
                current.container.prepareHide(interactive: false)
                backward.container.prepareShow(interactive: false)
            }
            self._rootLayout.state = .idle(current: backward.pageItem)
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
                backward.container.finishShow(interactive: false)
            }
        } else if let backward = backward {
            if self.isPresented == true {
                backward.container.prepareShow(interactive: false)
            }
            self._rootLayout.state = .idle(current: backward.pageItem)
            if self.isPresented == true {
                backward.container.finishShow(interactive: false)
            }
            completion?()
        } else if let current = current {
            if self.isPresented == true {
                current.container.prepareHide(interactive: false)
            }
            self._rootLayout.state = .empty
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
            }
            completion?()
        } else {
            self._rootLayout.state = .empty
            completion?()
        }
    }
    
    #if os(iOS)
    
    func _beginInteractiveGesture() {
        self._interactiveBeginLocation = self._interactiveGesture.location(in: self._rootView)
        let backward = self._items[self._items.count - 2]
        backward.container.prepareShow(interactive: true)
        self._interactiveBackward = backward
        let current = self._items[self._items.count - 1]
        current.container.prepareHide(interactive: true)
        self._interactiveCurrent = current
    }
    
    func _changeInteractiveGesture() {
        guard let beginLocation = self._interactiveBeginLocation, let backward = self._interactiveBackward, let current = self._interactiveCurrent else { return }
        let currentLocation = self._interactiveGesture.location(in: self._rootView)
        let deltaLocation = currentLocation - beginLocation
        let layoutSize = self._rootView.contentSize
        let progress = max(0, deltaLocation.x / layoutSize.width)
        self._rootLayout.state = .pop(backward: backward.pageItem, current: current.pageItem, progress: progress)
    }

    func _endInteractiveGesture(_ canceled: Bool) {
        guard let beginLocation = self._interactiveBeginLocation, let backward = self._interactiveBackward, let current = self._interactiveCurrent else { return }
        let currentLocation = self._interactiveGesture.location(in: self._rootView)
        let deltaLocation = currentLocation - beginLocation
        let layoutSize = self._rootView.contentSize
        if deltaLocation.x >= self.interactiveLimit && canceled == false {
            QAnimation.default.run(
                duration: layoutSize.width / self.interactiveVelocity,
                elapsed: deltaLocation.x / self.interactiveVelocity,
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._rootLayout.state = .pop(backward: backward.pageItem, current: current.pageItem, progress: progress)
                    self._rootLayout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._finishInteractiveAnimation()
                }
            )
        } else {
            QAnimation.default.run(
                duration: layoutSize.width / self.interactiveVelocity,
                elapsed: (layoutSize.width - deltaLocation.x) / self.interactiveVelocity,
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._rootLayout.state = .pop(backward: backward.pageItem, current: current.pageItem, progress: 1 - progress)
                    self._rootLayout.updateIfNeeded()
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
        self._rootLayout.state = .idle(current: backward.pageItem)
        current.container.finishHide(interactive: true)
        backward.container.finishShow(interactive: true)
        current.container.stackContainer = nil
        self._resetInteractiveAnimation()
    }
    
    func _cancelInteractiveAnimation() {
        guard let backward = self._interactiveBackward, let current = self._interactiveCurrent else { return }
        self._rootLayout.state = .idle(current: current.pageItem)
        current.container.cancelHide(interactive: true)
        backward.container.cancelShow(interactive: true)
        self._resetInteractiveAnimation()
    }
    
    func _resetInteractiveAnimation() {
        self._interactiveBeginLocation = nil
        self._interactiveBackward = nil
        self._interactiveCurrent = nil
    }
    
    #endif

}
