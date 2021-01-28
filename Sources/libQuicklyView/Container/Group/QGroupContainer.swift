//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QGroupContainer< Screen : IQScreen > : IQGroupContainer, IQContainerScreenable {
    
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
        return self.currentContainer?.supportedOrientations ?? .portrait
    }
    #endif
    public private(set) var isPresented: Bool
    public var view: IQView {
        return self._rootView
    }
    public private(set) var screen: Screen
    public var containers: [IQGroupContentContainer] {
        return self._items.compactMap({ $0.container })
    }
    public var currentContainer: IQGroupContentContainer? {
        return self._current?.container
    }
    
    private var _barView: QScrollView
    private var _barLayout: BarLayout
    private var _rootView: QCustomView
    private var _rootLayout: RootLayout
    private var _items: [Item]
    private var _current: Item?
    
    public init(screen: Screen) {
        self.isPresented = false
        self.screen = screen
        self._barLayout = BarLayout()
        self._barView = QScrollView(
            direction: .horizontal,
            layout: self._barLayout
        )
        self._rootLayout = RootLayout(
            barItem: QLayoutItem(view: self._barView)
        )
        self._rootView = QCustomView(
            layout: self._rootLayout
        )
        self._items = []
        self._init()
    }
    
    public func insets(of container: IQContainer) -> QInset {
        let inheritedInsets = self.inheritedInsets
        if let item = self._items.first(where: { $0.container === container }) {
            return QInset(
                top: inheritedInsets.top,
                left: inheritedInsets.left,
                right: inheritedInsets.right,
                bottom: inheritedInsets.bottom + item.container.groupBarSize
            )
        }
        return inheritedInsets
    }
    
    public func didChangeInsets() {
        let inheritedInsets = self.inheritedInsets
        self._barView.contentInset(QInset(left: inheritedInsets.left, right: inheritedInsets.right, bottom: inheritedInsets.bottom))
        self._rootLayout.barInset = inheritedInsets.bottom
        for item in self._items {
            item.container.didChangeInsets()
        }
    }
    
    public func prepareShow(interactive: Bool) {
        self.currentContainer?.prepareShow(interactive: interactive)
    }
    
    public func finishShow(interactive: Bool) {
        self.isPresented = true
        self.currentContainer?.finishShow(interactive: interactive)
    }
    
    public func cancelShow(interactive: Bool) {
        self.currentContainer?.cancelShow(interactive: interactive)
    }
    
    public func prepareHide(interactive: Bool) {
        self.currentContainer?.prepareHide(interactive: interactive)
    }
    
    public func finishHide(interactive: Bool) {
        self.isPresented = false
        self.currentContainer?.finishHide(interactive: interactive)
    }
    
    public func cancelHide(interactive: Bool) {
        self.currentContainer?.cancelHide(interactive: interactive)
    }
    
    public func update(container: IQGroupContentContainer, animated: Bool, completion: (() -> Void)?) {
        guard let item = self._items.first(where: { $0.container === container }) else {
            completion?()
            return
        }
        item.update()
        let barSize = self._groupBarSize()
        self._barLayout.itemSize = barSize
        self._barLayout.items = self._items.compactMap({ $0.barItem })
        self._rootLayout.barSize = barSize
    }
    
    public func set(containers: [IQGroupContentContainer], current: IQGroupContentContainer?, animated: Bool, completion: (() -> Void)?) {
        let oldCurrent = self._current
        let removeItems = self._items.filter({ item in
            return containers.contains(where: { item.container === $0 && oldCurrent?.container !== $0 }) == false
        })
        for item in removeItems {
            item.container.groupContainer = nil
        }
        let inheritedInsets = self.inheritedInsets
        self._items = containers.compactMap({ Item(container: $0, insets: inheritedInsets) })
        for item in self._items {
            item.container.groupContainer = self
        }
        let barSize = self._groupBarSize()
        self._barLayout.itemSize = barSize
        self._barLayout.items = self._items.compactMap({ $0.barItem })
        self._rootLayout.barSize = barSize
        let newCurrent: Item?
        if current != nil {
            newCurrent = self._items.first(where: { $0.container === current })
        } else if oldCurrent == nil {
            newCurrent = self._items.first
        } else {
            newCurrent = oldCurrent
        }
        if oldCurrent !== newCurrent {
            self._current = newCurrent
            self._set(current: oldCurrent, forward: newCurrent, animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
    
    public func set(current: IQGroupContentContainer, animated: Bool, completion: (() -> Void)?) {
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
                    self._set(current: oldCurrent, forward: newCurrent, animated: animated, completion: completion)
                } else {
                    self._set(current: oldCurrent, backward: newCurrent, animated: animated, completion: completion)
                }
            } else {
                completion?()
            }
        } else {
            self._set(current: nil, forward: newCurrent, animated: animated, completion: completion)
        }
    }
    
}

private extension QGroupContainer {
    
    class Item {
        
        var container: IQGroupContentContainer
        var barItem: IQLayoutItem
        var groupItem: IQLayoutItem

        init(
            container: IQGroupContentContainer,
            insets: QInset
        ) {
            self.container = container
            self.barItem = QLayoutItem(view: container.groupBarItemView)
            self.groupItem = QLayoutItem(view: container.view)
        }
        
        func update() {
            self.barItem = QLayoutItem(view: self.container.groupBarItemView)
        }

    }
    
}

private extension QGroupContainer {
    
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

        init(
            itemSpacing: QFloat = 0,
            itemSize: QFloat = 0
        ) {
            self.itemSpacing = itemSpacing
            self.itemSize = itemSize
            self.items = []
        }
        
        func layout(bounds: QRect) -> QSize {
            var size = QSize(width: 0, height: self.itemSize)
            if self.items.count > 1 {
                var sizes: [QFloat] = []
                for item in self.items {
                    let itemSize = item.size(QSize(width: bounds.size.width, height: self.itemSize))
                    sizes.append(itemSize.width)
                    size.width += itemSize.width + self.itemSpacing
                    size.height = self.itemSize
                }
                size.width -= self.itemSpacing
                let additionalItemSize: QFloat
                if size.width < bounds.size.width {
                    additionalItemSize = (bounds.size.width - size.width) / QFloat(self.items.count)
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
                    origin.x += itemSize + additionalItemSize + self.itemSpacing
                }
            } else if let item = self.items.first {
                item.frame = QRect(
                    x: bounds.origin.x,
                    y: bounds.origin.y,
                    width: bounds.size.width,
                    height: self.itemSize
                )
            }
            return size
        }
        
        func size(_ available: QSize) -> QSize {
            var size = QSize(width: 0, height: self.itemSize)
            if self.items.count > 1 {
                for item in self.items {
                    let itemSize = item.size(QSize(width: available.width, height: self.itemSize))
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
        
        func items(bounds: QRect) -> [IQLayoutItem] {
            return self.items
        }
        
    }
    
}

private extension QGroupContainer {
    
    class RootLayout : IQLayout {
        
        weak var delegate: IQLayoutDelegate?
        weak var parentView: IQView?
        var barInset: QFloat
        var barSize: QFloat
        var barItem: IQLayoutItem
        var state: State {
            didSet { self.setNeedUpdate() }
        }

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
        }
        
        func layout(bounds: QRect) -> QSize {
            self.barItem.frame = QRect(
                x: bounds.origin.x,
                y: (bounds.origin.y + bounds.size.height) - (self.barInset + self.barSize),
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
            case .forward(let current, let next, let progress):
                current.frame = currentFrame.lerp(backwardFrame, progress: progress)
                next.frame = forwardFrame.lerp(currentFrame, progress: progress)
            case .backward(let current, let next, let progress):
                current.frame = currentFrame.lerp(forwardFrame, progress: progress)
                next.frame = backwardFrame.lerp(currentFrame, progress: progress)
            }
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [IQLayoutItem] {
            switch self.state {
            case .empty: return [ self.barItem ]
            case .idle(let current): return [ current, self.barItem ]
            case .forward(let current, let next, _): return [ current, next, self.barItem ]
            case .backward(let current, let next, _): return [ next, current, self.barItem ]
            }
        }
        
    }
    
}

private extension QGroupContainer.RootLayout {
    
    enum State {
        case empty
        case idle(current: IQLayoutItem)
        case forward(current: IQLayoutItem, next: IQLayoutItem, progress: QFloat)
        case backward(current: IQLayoutItem, next: IQLayoutItem, progress: QFloat)
    }
    
}

private extension QGroupContainer {
    
    func _init() {
    }
    
    func _groupBarSize() -> QFloat {
        var barSize: QFloat = 0
        for item in self._items {
            barSize = max(barSize, item.container.groupBarSize)
        }
        return barSize
    }
    
    func _set(
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
                        self._barView.contentOffset(current.barItem.frame.center)
                        self._rootLayout.state = .forward(current: current.groupItem, next: forward.groupItem, progress: progress)
                        self._rootLayout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self._rootLayout.state = .idle(current: forward.groupItem)
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
                self._rootLayout.state = .idle(current: forward.groupItem)
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
            self._rootLayout.state = .idle(current: forward.groupItem)
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
                forward.container.finishShow(interactive: false)
            }
        } else if let forward = forward {
            if self.isPresented == true {
                forward.container.prepareShow(interactive: false)
            }
            self._rootLayout.state = .idle(current: forward.groupItem)
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
    
    func _set(
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
                        self._rootLayout.state = .backward(current: current.groupItem, next: backward.groupItem, progress: progress)
                        self._rootLayout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self._rootLayout.state = .idle(current: backward.groupItem)
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
                self._rootLayout.state = .idle(current: backward.groupItem)
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
            self._rootLayout.state = .idle(current: backward.groupItem)
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
                backward.container.finishShow(interactive: false)
            }
        } else if let backward = backward {
            if self.isPresented == true {
                backward.container.prepareShow(interactive: false)
            }
            self._rootLayout.state = .idle(current: backward.groupItem)
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
    
}
