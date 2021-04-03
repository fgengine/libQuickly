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
            if self.parent !== oldValue {
                self.didChangeInsets()
            }
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
        return self._rootView
    }
    public private(set) var screen: Screen
    public private(set) var barView: IQGroupBarView {
        set(value) {
            guard self._barView !== value else { return }
            self._barView.delegate = nil
            self._barView = value
            self._barView.delegate = self
            self._rootLayout.barItem = QLayoutItem(view: self._barView)
        }
        get { return self._barView }
    }
    public private(set) var barSize: QFloat {
        set(value) { self._rootLayout.barSize = value }
        get { return self._rootLayout.barSize }
    }
    public private(set) var barVisibility: QFloat {
        set(value) { self._rootLayout.barVisibility = value }
        get { return self._rootLayout.barVisibility }
    }
    public private(set) var barHidden: Bool {
        set(value) { self._rootLayout.barHidden = value }
        get { return self._rootLayout.barHidden }
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
    public var animationVelocity: QFloat
    
    private var _barView: IQGroupBarView
    private var _rootView: QCustomView
    private var _rootLayout: RootLayout
    private var _items: [Item]
    private var _current: Item?
    
    public init(
        screen: Screen,
        containers: [IQGroupContentContainer],
        current: IQGroupContentContainer?
    ) {
        self.isPresented = false
        self.screen = screen
        #if os(iOS)
        self.animationVelocity = UIScreen.main.animationVelocity
        #endif
        self._barView = screen.groupBarView
        self._rootLayout = RootLayout(
            barItem: QLayoutItem(view: self._barView),
            barInset: 0,
            barSize: screen.groupBarSize,
            barVisibility: screen.groupBarVisibility,
            barHidden: screen.groupBarHidden
        )
        self._rootView = QCustomView(
            name: "QGroupContainer-RootView",
            layout: self._rootLayout
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
    
    public func insets(of container: IQContainer) -> QInset {
        let inheritedInsets = self.inheritedInsets
        if self._items.contains(where: { $0.container === container }) == true {
            return QInset(
                top: inheritedInsets.top,
                left: inheritedInsets.left,
                right: inheritedInsets.right,
                bottom: inheritedInsets.bottom + self.barSize
            )
        }
        return inheritedInsets
    }
    
    public func didChangeInsets() {
        let inheritedInsets = self.inheritedInsets
        self._barView.safeArea(QInset(left: inheritedInsets.left, right: inheritedInsets.right, bottom: inheritedInsets.bottom))
        self._rootLayout.barInset = inheritedInsets.bottom
        for item in self._items {
            item.container.didChangeInsets()
        }
    }
    
    public func prepareShow(interactive: Bool) {
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
        self._barView = self.screen.groupBarView
        self.barSize = self.screen.groupBarSize
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
        let inheritedInsets = self.inheritedInsets
        self._items = containers.compactMap({ Item(container: $0, insets: inheritedInsets) })
        for item in self._items {
            item.container.parent = self
        }
        self._barView.itemViews(self._items.compactMap({ $0.barView }))
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
        self.set(current: item.container, animated: true, completion: nil)
    }
    
}

extension QGroupContainer : IQRootContentContainer {
}

extension QGroupContainer : IQStackContentContainer where Screen : IQScreenStackable {
    
    public var stackBarView: IQStackBarView {
        return self.screen.stackBarView
    }
    
    public var stackBarSize: QFloat {
        return self.screen.stackBarSize
    }
    
    public var stackBarVisibility: QFloat {
        return self.screen.stackBarVisibility
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
            insets: QInset = QInset()
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
            case forward(current: QLayoutItem, next: QLayoutItem, progress: QFloat)
            case backward(current: QLayoutItem, next: QLayoutItem, progress: QFloat)
        }
        
        unowned var delegate: IQLayoutDelegate?
        unowned var parentView: IQView?
        var barItem: QLayoutItem {
            didSet { self.setNeedUpdate() }
        }
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
        var state: State {
            didSet { self.setNeedUpdate() }
        }

        init(
            barItem: QLayoutItem,
            barInset: QFloat,
            barSize: QFloat,
            barVisibility: QFloat,
            barHidden: Bool,
            state: State = .empty
        ) {
            self.barItem = barItem
            self.barInset = barInset
            self.barSize = barSize
            self.barVisibility = barVisibility
            self.barHidden = barHidden
            self.state = state
        }
        
        func invalidate() {
        }
        
        func layout(bounds: QRect) -> QSize {
            let barSize = self.barInset + self.barSize
            let barOffset = barSize * (1 - self.barVisibility)
            self.barItem.frame = QRect(
                x: bounds.origin.x,
                y: (bounds.origin.y + bounds.size.height) - (barSize + barOffset),
                width: bounds.size.width,
                height: barSize
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

private extension QGroupContainer {
    
    func _init() {
        self.screen.container = self
        self._barView.delegate = self
        for item in self._items {
            item.container.parent = self
        }
        self._barView.itemViews(self._items.compactMap({ $0.barView }))
        if let current = self._current {
            self._rootLayout.state = .idle(current: current.groupItem)
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
                    duration: self._rootView.contentSize.width / self.animationVelocity,
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._rootLayout.state = .forward(current: current.groupItem, next: forward.groupItem, progress: progress)
                        self._rootLayout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self._barView.selectedItemView(forward.barView)
                        self._rootLayout.state = .idle(current: forward.groupItem)
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
                self._rootLayout.state = .idle(current: forward.groupItem)
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
                self._rootLayout.state = .empty
                if self.isPresented == true {
                    current.container.finishHide(interactive: false)
                }
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
                completion?()
            } else {
                self._rootLayout.state = .empty
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
            self._rootLayout.state = .idle(current: forward.groupItem)
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
            self._rootLayout.state = .idle(current: forward.groupItem)
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
            self._rootLayout.state = .empty
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
            }
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        } else {
            self._barView.selectedItemView(nil)
            self._rootLayout.state = .empty
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
                    duration: self._rootView.contentSize.width / self.animationVelocity,
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._rootLayout.state = .backward(current: current.groupItem, next: backward.groupItem, progress: progress)
                        self._rootLayout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self._barView.selectedItemView(backward.barView)
                        self._rootLayout.state = .idle(current: backward.groupItem)
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
                self._rootLayout.state = .idle(current: backward.groupItem)
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
                self._rootLayout.state = .empty
                if self.isPresented == true {
                    current.container.finishHide(interactive: false)
                }
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
                completion?()
            } else {
                self._rootLayout.state = .empty
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
            self._rootLayout.state = .idle(current: backward.groupItem)
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
            self._rootLayout.state = .idle(current: backward.groupItem)
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
            self._rootLayout.state = .empty
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
            }
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        } else {
            self._barView.selectedItemView(nil)
            self._rootLayout.state = .empty
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        }
    }
    
}
