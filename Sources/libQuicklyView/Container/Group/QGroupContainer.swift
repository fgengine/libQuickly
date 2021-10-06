//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QGroupContainer< Screen : IQGroupScreen > : IQGroupContainer, IQContainerScreenable {
    
    public unowned var parent: IQContainer? {
        didSet(oldValue) {
            guard self.parent !== oldValue else { return }
            guard self.isPresented == true else { return }
            self.didChangeInsets()
        }
    }
    public var shouldInteractive: Bool {
        return self.currentContainer?.shouldInteractive ?? false
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
        return self._view
    }
    public private(set) var screen: Screen
    public private(set) var barView: IQGroupBarView {
        set(value) {
            guard self._barView !== value else { return }
            self._barView.delegate = nil
            self._barView = value
            self._barView.delegate = self
            self._view.contentLayout.barItem = QLayoutItem(view: self._barView)
        }
        get { return self._barView }
    }
    public var barSize: Float {
        get { return self._view.contentLayout.barSize }
    }
    public private(set) var barVisibility: Float {
        set(value) { self._view.contentLayout.barVisibility = value }
        get { return self._view.contentLayout.barVisibility }
    }
    public private(set) var barHidden: Bool {
        set(value) { self._view.contentLayout.barHidden = value }
        get { return self._view.contentLayout.barHidden }
    }
    public var containers: [IQGroupContentContainer] {
        return self._items.compactMap({ $0.container })
    }
    public var backwardContainer: IQGroupContentContainer? {
        guard let current = self._current else { return nil }
        guard let index = self._items.firstIndex(where: { $0 === current }) else { return nil }
        return index > 0 ? self._items[index - 1].container : nil
    }
    public var currentContainer: IQGroupContentContainer? {
        return self._current?.container
    }
    public var forwardContainer: IQGroupContentContainer? {
        guard let current = self._current else { return nil }
        guard let index = self._items.firstIndex(where: { $0 === current }) else { return nil }
        return index < self._items.count - 1 ? self._items[index + 1].container : nil
    }
    public var animationVelocity: Float
    
    private var _barView: IQGroupBarView
    private var _view: QCustomView< RootLayout >
    private var _items: [Item]
    private var _current: Item?
    
    public init(
        screen: Screen,
        containers: [IQGroupContentContainer],
        current: IQGroupContentContainer? = nil
    ) {
        self.isPresented = false
        self.screen = screen
        #if os(iOS)
        self.animationVelocity = UIScreen.main.animationVelocity
        #endif
        self._barView = screen.groupBarView
        self._view = QCustomView(
            contentLayout: RootLayout(
                barItem: QLayoutItem(view: self._barView),
                barVisibility: screen.groupBarVisibility,
                barHidden: screen.groupBarHidden
            )
        )
        self._items = containers.compactMap({ Item(container: $0) })
        if let current = current {
            if let index = self._items.firstIndex(where: { $0.container === current }) {
                self._current = self._items[index]
            } else {
                self._current = self._items.first
            }
        } else {
            self._current = self._items.first
        }
        self._init()
    }
    
    deinit {
        self.screen.destroy()
    }
    
    public func insets(of container: IQContainer, interactive: Bool) -> QInset {
        let inheritedInsets = self.inheritedInsets(interactive: interactive)
        if self._items.contains(where: { $0.container === container }) == true {
            let bottom: Float
            if self.barHidden == false {
                let barSize = self.barSize
                let barVisibility = self.barVisibility
                if interactive == true {
                    bottom = barSize * barVisibility
                } else {
                    bottom = barSize
                }
            } else {
                bottom = inheritedInsets.bottom
            }
            return QInset(
                top: inheritedInsets.top,
                left: inheritedInsets.left,
                right: inheritedInsets.right,
                bottom: bottom
            )
        }
        return inheritedInsets
    }
    
    public func didChangeInsets() {
        let inheritedInsets = self.inheritedInsets(interactive: true)
        self._barView.safeArea(QInset(top: 0, left: inheritedInsets.left, right: inheritedInsets.right, bottom: 0))
        self._view.contentLayout.barOffset = inheritedInsets.bottom
        for item in self._items {
            item.container.didChangeInsets()
        }
    }
    
    public func activate() -> Bool {
        if self.screen.activate() == true {
            return true
        }
        if let current = self._current?.container {
            return current.activate()
        }
        return false
    }
    
    public func prepareShow(interactive: Bool) {
        self.didChangeInsets()
        self.screen.prepareShow(interactive: interactive)
        self.currentContainer?.prepareShow(interactive: interactive)
    }
    
    public func finishShow(interactive: Bool) {
        self.isPresented = true
        self.screen.finishShow(interactive: interactive)
        self.currentContainer?.finishShow(interactive: interactive)
    }
    
    public func cancelShow(interactive: Bool) {
        self.screen.cancelShow(interactive: interactive)
        self.currentContainer?.cancelShow(interactive: interactive)
    }
    
    public func prepareHide(interactive: Bool) {
        self.screen.prepareHide(interactive: interactive)
        self.currentContainer?.prepareHide(interactive: interactive)
    }
    
    public func finishHide(interactive: Bool) {
        self.isPresented = false
        self.screen.finishHide(interactive: interactive)
        self.currentContainer?.finishHide(interactive: interactive)
    }
    
    public func cancelHide(interactive: Bool) {
        self.screen.cancelHide(interactive: interactive)
        self.currentContainer?.cancelHide(interactive: interactive)
    }
    
    public func updateBar(animated: Bool, completion: (() -> Void)?) {
        self.barView = self.screen.groupBarView
        self.barVisibility = self.screen.groupBarVisibility
        self.barHidden = self.screen.groupBarHidden
        self.didChangeInsets()
        completion?()
    }
    
    public func update(container: IQGroupContentContainer, animated: Bool, completion: (() -> Void)?) {
        guard let item = self._items.first(where: { $0.container === container }) else {
            completion?()
            return
        }
        item.update()
        self._barView.itemViews(self._items.compactMap({ $0.barView }))
    }
    
    public func set(containers: [IQGroupContentContainer], current: IQGroupContentContainer?, animated: Bool, completion: (() -> Void)?) {
        let oldCurrent = self._current
        let removeItems = self._items.filter({ item in
            return containers.contains(where: { item.container === $0 && oldCurrent?.container !== $0 }) == false
        })
        for item in removeItems {
            item.container.parent = nil
        }
        let inheritedInsets = self.inheritedInsets(interactive: true)
        self._items = containers.compactMap({ Item(container: $0, insets: inheritedInsets) })
        for item in self._items {
            item.container.parent = self
        }
        self._barView.itemViews(self._items.compactMap({ $0.barView }))
        let newCurrent: Item?
        if current != nil {
            if let exist = self._items.first(where: { $0.container === current }) {
                newCurrent = exist
            } else {
                newCurrent = self._items.first
            }
        } else {
            newCurrent = self._items.first
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
            if oldCurrent !== newCurrent {
                self._current = newCurrent
                let oldIndex = self._items.firstIndex(where: { $0 === oldCurrent })!
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

extension QGroupContainer : IQGroupBarViewDelegate {
    
    public func pressed(groupBar: IQGroupBarView, itemView: IQView) {
        guard let item = self._items.first(where: { $0.barView === itemView }) else { return }
        if self._current === item {
            _ = self.activate()
        } else {
            self.set(current: item.container, animated: true, completion: nil)
        }
    }
    
}

extension QGroupContainer : IQRootContentContainer {
}

extension QGroupContainer : IQStackContentContainer where Screen : IQScreenStackable {
    
    public var stackBarView: IQStackBarView {
        return self.screen.stackBarView
    }
    
    public var stackBarVisibility: Float {
        return max(0, min(self.screen.stackBarVisibility, 1))
    }
    
    public var stackBarHidden: Bool {
        return self.screen.stackBarHidden
    }
    
}

extension QGroupContainer : IQDialogContentContainer where Screen : IQScreenDialogable {
    
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

extension QGroupContainer : IQHamburgerContentContainer {
}

private extension QGroupContainer {
    
    func _init() {
        self.screen.container = self
        self._barView.delegate = self
        for item in self._items {
            item.container.parent = self
        }
        self._barView.itemViews(self._items.compactMap({ $0.barView }))
        if let current = self._current {
            self._view.contentLayout.state = .idle(current: current.groupItem)
        }
        self.screen.setup()
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
                    duration: TimeInterval(self._view.contentSize.width / self.animationVelocity),
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._view.contentLayout.state = .forward(current: current.groupItem, next: forward.groupItem, progress: progress)
                        self._view.contentLayout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self._barView.selectedItemView(forward.barView)
                        self._view.contentLayout.state = .idle(current: forward.groupItem)
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
                self._barView.selectedItemView(forward.barView)
                self._view.contentLayout.state = .idle(current: forward.groupItem)
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
                self._barView.selectedItemView(nil)
                self._view.contentLayout.state = .empty
                if self.isPresented == true {
                    current.container.finishHide(interactive: false)
                }
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
                completion?()
            } else {
                self._view.contentLayout.state = .empty
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
                completion?()
            }
        } else if let current = current, let forward = forward {
            if self.isPresented == true {
                current.container.prepareHide(interactive: false)
                forward.container.prepareShow(interactive: false)
            }
            self._barView.selectedItemView(forward.barView)
            self._view.contentLayout.state = .idle(current: forward.groupItem)
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
            self._barView.selectedItemView(forward.barView)
            self._view.contentLayout.state = .idle(current: forward.groupItem)
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
            self._barView.selectedItemView(nil)
            self._view.contentLayout.state = .empty
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
            }
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        } else {
            self._barView.selectedItemView(nil)
            self._view.contentLayout.state = .empty
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
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
                    duration: TimeInterval(self._view.contentSize.width / self.animationVelocity),
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._view.contentLayout.state = .backward(current: current.groupItem, next: backward.groupItem, progress: progress)
                        self._view.contentLayout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self._barView.selectedItemView(backward.barView)
                        self._view.contentLayout.state = .idle(current: backward.groupItem)
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
                self._barView.selectedItemView(backward.barView)
                self._view.contentLayout.state = .idle(current: backward.groupItem)
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
                self._barView.selectedItemView(nil)
                self._view.contentLayout.state = .empty
                if self.isPresented == true {
                    current.container.finishHide(interactive: false)
                }
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
                completion?()
            } else {
                self._view.contentLayout.state = .empty
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
                completion?()
            }
        } else if let current = current, let backward = backward {
            if self.isPresented == true {
                current.container.prepareHide(interactive: false)
                backward.container.prepareShow(interactive: false)
            }
            self._barView.selectedItemView(backward.barView)
            self._view.contentLayout.state = .idle(current: backward.groupItem)
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
            self._barView.selectedItemView(nil)
            self._view.contentLayout.state = .idle(current: backward.groupItem)
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
            self._barView.selectedItemView(nil)
            self._view.contentLayout.state = .empty
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
            }
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        } else {
            self._barView.selectedItemView(nil)
            self._view.contentLayout.state = .empty
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        }
    }
    
}

private extension QGroupContainer {
    
    class Item {
        
        var container: IQGroupContentContainer
        var barView: IQBarItemView {
            return self.barItem.view as! IQBarItemView
        }
        var barItem: QLayoutItem
        var groupView: IQView {
            return self.groupItem.view
        }
        var groupItem: QLayoutItem

        init(
            container: IQGroupContentContainer,
            insets: QInset = .zero
        ) {
            self.container = container
            self.barItem = QLayoutItem(view: container.groupItemView)
            self.groupItem = QLayoutItem(view: container.view)
        }
        
        func update() {
            self.barItem = QLayoutItem(view: self.container.groupItemView)
        }

    }
    
    class RootLayout : IQLayout {
        
        enum State {
            case empty
            case idle(current: QLayoutItem)
            case forward(current: QLayoutItem, next: QLayoutItem, progress: Float)
            case backward(current: QLayoutItem, next: QLayoutItem, progress: Float)
        }
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var barOffset: Float {
            didSet { self.setNeedUpdate() }
        }
        var barSize: Float
        var barVisibility: Float {
            didSet { self.setNeedUpdate() }
        }
        var barHidden: Bool {
            didSet { self.setNeedUpdate() }
        }
        var barItem: QLayoutItem {
            didSet { self.setNeedUpdate() }
        }
        var state: State {
            didSet { self.setNeedUpdate() }
        }

        init(
            barItem: QLayoutItem,
            barVisibility: Float,
            barHidden: Bool,
            state: State = .empty
        ) {
            self.barOffset = 0
            self.barSize = 0
            self.barItem = barItem
            self.barVisibility = barVisibility
            self.barHidden = barHidden
            self.state = state
        }
        
        func layout(bounds: QRect) -> QSize {
            let barSize = self.barItem.size(available: QSize(
                width: bounds.width,
                height: .infinity
            ))
            self.barItem.frame = QRect(
                bottom: bounds.bottom,
                width: bounds.width,
                height: self.barOffset + (barSize.height * self.barVisibility)
            )
            self.barSize = barSize.height
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
        
        func size(available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            var items: [QLayoutItem] = []
            if self.barHidden == false {
                items.append(self.barItem)
            }
            switch self.state {
            case .empty: break
            case .idle(let current):
                items.insert(current, at: 0)
            case .forward(let current, let next, _):
                items.insert(contentsOf: [ current, next ], at: 0)
            case .backward(let current, let next, _):
                items.insert(contentsOf: [ next, current ], at: 0)
            }
            return items
        }
        
    }
    
}
