//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QPageContainer< Screen : IQScreen > : IQPageContainer, IQContainerScreenable {
    
    public weak var parentContainer: IQContainer?
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
        return self.currentContainer?.supportedOrientations ?? .portrait
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
    public var containers: [IQPageContentContainer] {
        return self._items.compactMap({ $0.container })
    }
    public var backwardContainer: IQPageContentContainer? {
        guard let current = self._current else { return nil }
        guard let index = self._items.firstIndex(where: { $0 === current }) else { return nil }
        return self._items.count > index ? self._items[index - 1].container : nil
    }
    public var currentContainer: IQPageContentContainer? {
        return self._current?.container
    }
    public var forwardContainer: IQPageContentContainer? {
        guard let current = self._current else { return nil }
        guard let index = self._items.firstIndex(where: { $0 === current }) else { return nil }
        return index < self._items.count - 1 ? self._items[index + 1].container : nil
    }
    
    private var _items: [Item]
    private var _current: Item?
    #if os(iOS)
    private lazy var _rootView: QCustomView = QCustomView(
        gestures: [ self._interactiveGesture ],
        layout: self._rootLayout
    )
    private lazy var _interactiveGesture: QPanGesture = QPanGesture(
        onShouldBegin: { [weak self] gesture -> Bool in
            guard let self = self else { return false }
            return self._items.count > 1
        },
        onBegin: { [weak self] gesture in self?._beginInteractiveGesture() },
        onChange: { [weak self] gesture in self?._changeInteractiveGesture() },
        onCancel: { [weak self] gesture in self?._endInteractiveGesture(true) },
        onEnd: { [weak self] gesture in self?._endInteractiveGesture(false) }
    )
    private var _interactiveBeginLocation: QPoint?
    private var _interactiveBackward: Item?
    private var _interactiveCurrent: Item?
    private var _interactiveForward: Item?
    #else
    private lazy var _rootView: QCustomView = QCustomView(
        layout: self._rootLayout
    )
    #endif
    private lazy var _rootLayout: RootLayout = RootLayout(
        barItem: QLayoutItem(view: self._barView)
    )
    private lazy var _barView: QScrollView = QScrollView(
        direction: .horizontal,
        layout: self._barLayout
    )
    private lazy var _barLayout: BarLayout = BarLayout()
    
    public init(screen: Screen) {
        self.isPresented = false
        self.screen = screen
        #if os(iOS)
        self.interactiveLimit = QFloat(UIScreen.main.bounds.width * 0.45)
        self.interactiveVelocity = QFloat(UIScreen.main.bounds.width * 2)
        #endif
        self._items = []
    }
    
    public func insets(of container: IQContainer) -> QInset {
        let inheritedInsets = self.inheritedInsets
        if let item = self._items.first(where: { $0.container === container }) {
            return QInset(
                top: inheritedInsets.top + item.container.pageBarSize,
                left: inheritedInsets.left,
                right: inheritedInsets.right,
                bottom: inheritedInsets.bottom
            )
        }
        return inheritedInsets
    }
    
    public func didChangeInsets() {
        let inheritedInsets = self.inheritedInsets
        self._barView.contentInset = QInset(top: inheritedInsets.top, left: inheritedInsets.left, right: inheritedInsets.right)
        self._rootLayout.barInset = inheritedInsets.top
        for item in self._items {
            item.container.didChangeInsets()
        }
    }
    
    public func willShow(interactive: Bool) {
        self.currentContainer?.willShow(interactive: interactive)
    }
    
    public func didShow(interactive: Bool, finished: Bool) {
        self.isPresented = true
        self.currentContainer?.didShow(interactive: interactive, finished: finished)
    }

    public func willHide(interactive: Bool) {
        self.currentContainer?.willHide(interactive: interactive)
    }
    
    public func didHide(interactive: Bool, finished: Bool) {
        self.isPresented = false
        self.currentContainer?.didHide(interactive: interactive, finished: finished)
    }
    
    public func update(container: IQPageContentContainer, animated: Bool, completion: (() -> Void)?) {
        guard let item = self._items.first(where: { $0.container === container }) else {
            completion?()
            return
        }
        item.update()
        let barSize = self._pageBarSize()
        self._barLayout.itemSize = barSize
        self._barLayout.items = self._items.compactMap({ $0.barItem })
        self._rootLayout.barSize = barSize
    }
    
    public func set(containers: [IQPageContentContainer], current: IQPageContentContainer?, animated: Bool, completion: (() -> Void)?) {
        let oldCurrent = self._current
        let removeItems = self._items.filter({ item in
            return containers.contains(where: { item.container === $0 && oldCurrent?.container !== $0 }) == false
        })
        for item in removeItems {
            item.container.pageContainer = nil
        }
        let inheritedInsets = self.inheritedInsets
        self._items = containers.compactMap({ Item(container: $0, insets: inheritedInsets) })
        for item in self._items {
            item.container.pageContainer = self
        }
        self._barLayout.items = self._items.compactMap({ $0.barItem })
        let newCurrent = self._items.first(where: { $0.container === current })
        if oldCurrent !== newCurrent {
            self._current = newCurrent
            self._push(current: oldCurrent, forward: newCurrent, animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
    
    public func set(current: IQPageContentContainer, animated: Bool, completion: (() -> Void)?) {
        guard let newIndex = self._items.firstIndex(where: { $0.container === current }) else {
            completion?()
            return
        }
        let newCurrent = self._items[newIndex]
        if let oldCurrent = self._current {
            if oldCurrent !== current {
                self._current = newCurrent
                let oldIndex = self._items.firstIndex(where: { $0.container === oldCurrent })!
                if newIndex > oldIndex {
                    self._push(current: oldCurrent, forward: newCurrent, animated: animated, completion: completion)
                } else {
                    self._pop(current: oldCurrent, backward: newCurrent, animated: animated, completion: completion)
                }
            } else {
                completion?()
            }
        } else {
            self._push(current: nil, forward: newCurrent, animated: animated, completion: completion)
        }
    }
    
}

extension QPageContainer : IQStackContentContainer where Screen : IQScreenStackable {
    
    public var stackBarSize: QFloat {
        return self.screen.stackBarSize
    }
    
    public var stackBarVisibility: QFloat {
        return self.screen.stackBarVisibility
    }
    
    public var stackBarHidden: Bool {
        return self.screen.stackBarHidden
    }
    
    public var stackBarItemView: IQView {
        return self.screen.stackBarItemView
    }
    
}

private extension QPageContainer {
    
    class Item {
        
        var container: IQPageContentContainer
        var barItem: IQLayoutItem
        var pageItem: IQLayoutItem

        init(
            container: IQPageContentContainer,
            insets: QInset
        ) {
            self.container = container
            self.barItem = QLayoutItem(view: container.pageBarItemView)
            self.pageItem = QLayoutItem(view: container.view)
        }
        
        func update() {
            self.barItem = QLayoutItem(view: self.container.pageBarItemView)
        }

    }
    
}

private extension QPageContainer {
    
    class BarLayout : IQLayout {
        
        weak var delegate: IQLayoutDelegate?
        weak var parentView: IQView?
        var itemSpacing: QFloat {
            didSet { self.setNeedUpdate() }
        }
        var itemSize: QFloat {
            didSet { self.setNeedUpdate() }
        }
        var items: [IQLayoutItem] {
            didSet { self.setNeedUpdate() }
        }
        var size: QSize

        init(
            itemSpacing: QFloat = 0,
            itemSize: QFloat = 0
        ) {
            self.itemSpacing = itemSpacing
            self.itemSize = itemSize
            self.items = []
            self.size = QSize()
        }
        
        func layout() {
            guard let bounds = self.delegate?.bounds(self) else {
                self.size = QSize()
                return
            }
            var size = QSize(width: 0, height: self.itemSize)
            if self.items.count > 1 {
                var sizes: [QFloat] = []
                for item in self.items {
                    let itemSize = item.size(QSize(width: .infinity, height: size.height))
                    sizes.append(itemSize.width)
                    size.width += itemSize.width + self.itemSpacing
                    size.height = self.itemSize
                }
                size.width -= self.itemSpacing
                let additionalItemSize: QFloat
                if size.width < bounds.size.width {
                    additionalItemSize = (bounds.size.width - size.width) / QFloat(self.items.count - 1)
                    size.width = bounds.size.width
                } else {
                    additionalItemSize = 0
                }
                var origin = bounds.origin
                for index in 0 ..< self.items.count {
                    let item = self.items[index]
                    let itemSize = sizes[index]
                    item.frame = QRect(
                        x: origin.x,
                        y: origin.y,
                        width: itemSize + additionalItemSize,
                        height: self.itemSize
                    )
                    origin.x += itemSize + self.itemSpacing
                }
            } else if let item = self.items.first {
                item.frame = QRect(
                    x: bounds.origin.x,
                    y: bounds.origin.y,
                    width: bounds.size.width,
                    height: self.itemSize
                )
            }
            self.size = size
        }
        
        func size(_ available: QSize) -> QSize {
            var size = QSize(width: 0, height: self.itemSize)
            if self.items.count > 1 {
                for item in self.items {
                    let itemSize = item.size(QSize(width: .infinity, height: size.height))
                    size.width += itemSize.width + self.itemSpacing
                    size.height = self.itemSize
                }
                size.width -= self.itemSpacing
                if size.width < available.width {
                    size.width = available.width
                }
            } else {
                size.width = available.width
            }
            return size
        }
        
    }
    
}

private extension QPageContainer {
    
    class RootLayout : IQLayout {
        
        weak var delegate: IQLayoutDelegate?
        weak var parentView: IQView?
        var barInset: QFloat
        var barSize: QFloat
        var barItem: IQLayoutItem
        var state: State {
            didSet { self.setNeedUpdate() }
        }
        var items: [IQLayoutItem] {
            switch self.state {
            case .empty: return []
            case .idle(let current): return [ current ]
            case .push(let current, let forward, _): return [ current, forward ]
            case .pop(let backward, let current, _): return [ backward, current ]
            }
        }
        var size: QSize

        init(
            barInset: QFloat = 0,
            barSize: QFloat = 0,
            barItem: IQLayoutItem,
            state: State = .empty
        ) {
            self.barInset = barInset
            self.barSize = barSize
            self.barItem = barItem
            self.state = state
            self.size = QSize()
        }
        
        func layout() {
            var size: QSize
            if let bounds = self.delegate?.bounds(self) {
                self.barItem.frame = QRect(
                    x: bounds.origin.x,
                    y: bounds.origin.y,
                    width: bounds.size.width,
                    height: self.barInset + self.barSize
                )
                let forwardFrame = QRect(topLeft: bounds.topRight, size: bounds.size)
                let currentFrame = bounds
                let backwardFrame = QRect(topRight: bounds.topLeft, size: bounds.size)
                switch self.state {
                case .empty:
                    break
                case .idle(let current):
                    current.frame = bounds
                case .push(let current, let forward, let progress):
                    forward.frame = forwardFrame.lerp(currentFrame, progress: progress)
                    current.frame = currentFrame.lerp(backwardFrame, progress: progress)
                case .pop(let backward, let current, let progress):
                    current.frame = currentFrame.lerp(forwardFrame, progress: progress)
                    backward.frame = backwardFrame.lerp(currentFrame, progress: progress)
                }
                size = bounds.size
            } else {
                size = QSize()
            }
            self.size = size
        }
        
        func size(_ available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [IQLayoutItem] {
            return self.items
        }
        
    }
    
}

private extension QPageContainer.RootLayout {
    
    enum State {
        case empty
        case idle(current: IQLayoutItem)
        case push(current: IQLayoutItem, forward: IQLayoutItem, progress: QFloat)
        case pop(backward: IQLayoutItem, current: IQLayoutItem, progress: QFloat)
    }
    
}

private extension QPageContainer {
    
    func _pageBarSize() -> QFloat {
        var barSize: QFloat = 0
        for item in self._items {
            barSize = max(barSize, item.container.pageBarSize)
        }
        return barSize
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
                    current.container.willHide(interactive: false)
                    forward.container.willShow(interactive: false)
                }
                QAnimation.default.run(
                    duration: 0.2,
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._barView.scroll(to: current.barItem.frame.center)
                        self._rootLayout.state = .push(current: current.pageItem, forward: forward.pageItem, progress: progress)
                        self._rootLayout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self._rootLayout.state = .idle(current: forward.pageItem)
                        if self.isPresented == true {
                            current.container.didHide(interactive: false, finished: true)
                            forward.container.didShow(interactive: false, finished: true)
                        }
                        completion?()
                    }
                )
            } else if let forward = forward {
                if self.isPresented == true {
                    forward.container.willShow(interactive: false)
                }
                self._rootLayout.state = .idle(current: forward.pageItem)
                if self.isPresented == true {
                    forward.container.didShow(interactive: false, finished: true)
                }
                completion?()
            } else if let current = current {
                if self.isPresented == true {
                    current.container.willHide(interactive: false)
                }
                self._rootLayout.state = .empty
                if self.isPresented == true {
                    current.container.didHide(interactive: false, finished: true)
                }
                completion?()
            } else {
                self._rootLayout.state = .empty
                completion?()
            }
        } else if let current = current, let forward = forward {
            if self.isPresented == true {
                current.container.willHide(interactive: false)
                forward.container.willShow(interactive: false)
            }
            self._rootLayout.state = .idle(current: forward.pageItem)
            if self.isPresented == true {
                current.container.didHide(interactive: false, finished: true)
                forward.container.didShow(interactive: false, finished: true)
            }
        } else if let forward = forward {
            if self.isPresented == true {
                forward.container.willShow(interactive: false)
            }
            self._rootLayout.state = .idle(current: forward.pageItem)
            if self.isPresented == true {
                forward.container.didShow(interactive: false, finished: true)
            }
            completion?()
        } else if let current = current {
            if self.isPresented == true {
                current.container.willHide(interactive: false)
            }
            self._rootLayout.state = .empty
            if self.isPresented == true {
                current.container.didHide(interactive: false, finished: true)
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
                    current.container.willHide(interactive: false)
                    backward.container.willShow(interactive: false)
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
                            current.container.didHide(interactive: false, finished: true)
                            backward.container.didShow(interactive: false, finished: true)
                        }
                        completion?()
                    }
                )
            } else if let backward = backward {
                if self.isPresented == true {
                    backward.container.willShow(interactive: false)
                }
                self._rootLayout.state = .idle(current: backward.pageItem)
                if self.isPresented == true {
                    backward.container.didShow(interactive: false, finished: true)
                }
                completion?()
            } else if let current = current {
                if self.isPresented == true {
                    current.container.willHide(interactive: false)
                }
                self._rootLayout.state = .empty
                if self.isPresented == true {
                    current.container.didHide(interactive: false, finished: true)
                }
                completion?()
            } else {
                self._rootLayout.state = .empty
                completion?()
            }
        } else if let current = current, let backward = backward {
            if self.isPresented == true {
                current.container.willHide(interactive: false)
                backward.container.willShow(interactive: false)
            }
            self._rootLayout.state = .idle(current: backward.pageItem)
            if self.isPresented == true {
                current.container.didHide(interactive: false, finished: true)
                backward.container.didShow(interactive: false, finished: true)
            }
        } else if let backward = backward {
            if self.isPresented == true {
                backward.container.willShow(interactive: false)
            }
            self._rootLayout.state = .idle(current: backward.pageItem)
            if self.isPresented == true {
                backward.container.didShow(interactive: false, finished: true)
            }
            completion?()
        } else if let current = current {
            if self.isPresented == true {
                current.container.willHide(interactive: false)
            }
            self._rootLayout.state = .empty
            if self.isPresented == true {
                current.container.didHide(interactive: false, finished: true)
            }
            completion?()
        } else {
            self._rootLayout.state = .empty
            completion?()
        }
    }
    
}

#if os(iOS)

import UIKit

private extension QPageContainer {
    
    func _beginInteractiveGesture() {
        self._interactiveBeginLocation = self._interactiveGesture.location(in: self._rootView)
    }
    
    func _changeInteractiveGesture() {
    }

    func _endInteractiveGesture(_ canceled: Bool) {
    }
    
    func _finishInteractiveAnimation() {
        self._resetInteractiveAnimation()
    }
    
    func _cancelInteractiveAnimation() {
        self._resetInteractiveAnimation()
    }
    
    func _resetInteractiveAnimation() {
        self._interactiveBeginLocation = nil
        self._interactiveBackward = nil
        self._interactiveCurrent = nil
        self._interactiveForward = nil
    }
    
}
    
#endif
