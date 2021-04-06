//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QPageContainer< Screen : IQPageScreen > : IQPageContainer, IQContainerScreenable {
    
    public unowned var parent: IQContainer? {
        didSet(oldValue) {
            if self.parent !== oldValue {
                self.didChangeInsets()
            }
        }
    }
    public var shouldInteractive: Bool {
        return self.screen.shouldInteractive
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
    public private(set) var barView: IQPageBarView {
        set(value) {
            guard self._barView !== value else { return }
            self._barView.delegate = nil
            self._barView = value
            self._barView.delegate = self
            self._layout.barItem = QLayoutItem(view: self._barView)
        }
        get { return self._barView }
    }
    public private(set) var barSize: QFloat {
        set(value) { self._layout.barSize = value }
        get { return self._layout.barSize }
    }
    public private(set) var barVisibility: QFloat {
        set(value) { self._layout.barVisibility = value }
        get { return self._layout.barVisibility }
    }
    public private(set) var barHidden: Bool {
        set(value) { self._layout.barHidden = value }
        get { return self._layout.barHidden }
    }
    public var containers: [IQPageContentContainer] {
        return self._items.compactMap({ $0.container })
    }
    public var backwardContainer: IQPageContentContainer? {
        guard let current = self._current else { return nil }
        guard let index = self._items.firstIndex(where: { $0 === current }) else { return nil }
        return index > 0 ? self._items[index - 1].container : nil
    }
    public var currentContainer: IQPageContentContainer? {
        return self._current?.container
    }
    public var forwardContainer: IQPageContentContainer? {
        guard let current = self._current else { return nil }
        guard let index = self._items.firstIndex(where: { $0 === current }) else { return nil }
        return index < self._items.count - 1 ? self._items[index + 1].container : nil
    }
    public var animationVelocity: QFloat
    #if os(iOS)
    public var interactiveLimit: QFloat
    #endif
    
    private var _barView: IQPageBarView
    private var _view: QCustomView
    private var _layout: Layout
    #if os(iOS)
    private var _interactiveGesture: QPanGesture
    private var _interactiveBeginLocation: QPoint?
    private var _interactiveCurrentIndex: Int?
    private var _interactiveBackward: Item?
    private var _interactiveCurrent: Item?
    private var _interactiveForward: Item?
    #endif
    private var _items: [Item]
    private var _current: Item?
    
    public init(screen: Screen) {
        self.isPresented = false
        self.screen = screen
        #if os(iOS)
        self.animationVelocity = UIScreen.main.animationVelocity
        self.interactiveLimit = QFloat(UIScreen.main.bounds.width * 0.33)
        #endif
        self._barView = screen.pageBarView
        self._layout = Layout(
            barItem: QLayoutItem(view: self._barView),
            barInset: 0,
            barSize: screen.pageBarSize,
            barVisibility: screen.pageBarVisibility,
            barHidden: screen.pageBarHidden
        )
        #if os(iOS)
        self._interactiveGesture = QPanGesture(name: "QPageContainer-PanGesture")
        self._view = QCustomView(
            name: "QPageContainer-RootView",
            gestures: [ self._interactiveGesture ],
            layout: self._layout
        )
        #else
        self._view = QCustomView(
            layout: self._layout
        )
        #endif
        self._items = []
        self._init()
    }
    
    deinit {
        self.screen.destroy()
    }
    
    public func insets(of container: IQContainer) -> QInset {
        let inheritedInsets = self.inheritedInsets
        if self._items.contains(where: { $0.container === container }) == true {
            return QInset(
                top: inheritedInsets.top + self.barSize,
                left: inheritedInsets.left,
                right: inheritedInsets.right,
                bottom: inheritedInsets.bottom
            )
        }
        return inheritedInsets
    }
    
    public func didChangeInsets() {
        let inheritedInsets = self.inheritedInsets
        self._barView.safeArea(QInset(top: inheritedInsets.top, left: inheritedInsets.left, right: inheritedInsets.right))
        self._layout.barInset = inheritedInsets.top
        for item in self._items {
            item.container.didChangeInsets()
        }
    }
    
    public func activate() -> Bool {
        if self.screen.activate() == true {
            return true
        }
        if let container = self._current?.container {
            return container.activate()
        }
        return false
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
        self._barView = self.screen.pageBarView
        self.barSize = self.screen.pageBarSize
        completion?()
    }
    
    public func update(container: IQPageContentContainer, animated: Bool, completion: (() -> Void)?) {
        guard let item = self._items.first(where: { $0.container === container }) else {
            completion?()
            return
        }
        item.update()
        self._barView.itemViews(self._items.compactMap({ $0.barView }))
    }
    
    public func set(containers: [IQPageContentContainer], current: IQPageContentContainer?, animated: Bool, completion: (() -> Void)?) {
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
    
    public func set(current: IQPageContentContainer, animated: Bool, completion: (() -> Void)?) {
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

extension QPageContainer : IQPageBarViewDelegate {
    
    public func pressed(pageBar: IQPageBarView, itemView: IQView) {
        guard let item = self._items.first(where: { $0.barView === itemView }) else { return }
        self.set(current: item.container, animated: true, completion: nil)
    }
    
}

extension QPageContainer : IQStackContentContainer where Screen : IQScreenStackable {
    
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

extension QPageContainer : IQGroupContentContainer where Screen : IQScreenGroupable  {
    
    public var groupItemView: IQBarItemView {
        return self.screen.groupItemView
    }
    
    public func pressedToGroupItem() -> Bool {
        return false
    }
    
}

extension QPageContainer : IQDialogContentContainer where Screen : IQScreenDialogable {
    
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

private extension QPageContainer {
    
    func _init() {
        self._barView.delegate = self
        self.screen.container = self
        #if os(iOS)
        self._interactiveGesture.onShouldBegin({ [unowned self] in
            guard let current = self._current else { return false }
            guard self.shouldInteractive == true else { return false }
            guard current.container.shouldInteractive == true else { return false }
            guard self._items.count > 1 else { return false }
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
                self._barView.beginTransition()
                QAnimation.default.run(
                    duration: self._view.contentSize.width / self.animationVelocity,
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._barView.transition(to: forward.barView, progress: progress)
                        self._layout.state = .forward(current: current.pageItem, next: forward.pageItem, progress: progress)
                        self._layout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self._barView.finishTransition(to: forward.barView)
                        self._layout.state = .idle(current: forward.pageItem)
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
                self._layout.state = .idle(current: forward.pageItem)
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
            self._barView.selectedItemView(forward.barView)
            self._layout.state = .idle(current: forward.pageItem)
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
            self._layout.state = .idle(current: forward.pageItem)
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
            self._layout.state = .empty
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
            }
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        } else {
            self._barView.selectedItemView(nil)
            self._layout.state = .empty
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
                self._barView.beginTransition()
                QAnimation.default.run(
                    duration: self._view.contentSize.width / self.animationVelocity,
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._barView.transition(to: backward.barView, progress: progress)
                        self._layout.state = .backward(current: current.pageItem, next: backward.pageItem, progress: progress)
                        self._layout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self._barView.finishTransition(to: backward.barView)
                        self._layout.state = .idle(current: backward.pageItem)
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
                self._layout.state = .idle(current: backward.pageItem)
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
            self._barView.selectedItemView(backward.barView)
            self._layout.state = .idle(current: backward.pageItem)
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
            self._layout.state = .idle(current: backward.pageItem)
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
            self._layout.state = .empty
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
            }
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        } else {
            self._barView.selectedItemView(nil)
            self._layout.state = .empty
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        }
    }
    
}

#if os(iOS)

private extension QPageContainer {
    
    func _beginInteractiveGesture() {
        guard let index = self._items.firstIndex(where: { $0 === self._current }) else { return }
        self._interactiveBeginLocation = self._interactiveGesture.location(in: self._view)
        self._barView.beginTransition()
        self._interactiveCurrentIndex = index
        let current = self._items[index]
        current.container.prepareHide(interactive: true)
        self._interactiveCurrent = current
    }
    
    func _changeInteractiveGesture() {
        guard let beginLocation = self._interactiveBeginLocation, let current = self._interactiveCurrent else { return }
        let currentLocation = self._interactiveGesture.location(in: self._view)
        let deltaLocation = currentLocation.x - beginLocation.x
        let absDeltaLocation = abs(deltaLocation)
        let layoutSize = self._view.contentSize
        if deltaLocation < 0 {
            if let index = self._interactiveCurrentIndex, self._interactiveForward == nil {
                if let forward = index < self._items.count - 1 ? self._items[index + 1] : nil {
                    forward.container.prepareShow(interactive: true)
                    self._interactiveForward = forward
                }
            }
            if let forward = self._interactiveForward {
                let progress = max(0, absDeltaLocation / layoutSize.width)
                self._barView.transition(to: forward.barView, progress: progress)
                self._layout.state = .forward(current: current.pageItem, next: forward.pageItem, progress: progress)
            } else {
                self._barView.selectedItemView(current.barView)
                self._layout.state = .idle(current: current.pageItem)
            }
        } else if deltaLocation > 0 {
            if let index = self._interactiveCurrentIndex, self._interactiveBackward == nil {
                if let backward = index > 0 ? self._items[index - 1] : nil {
                    backward.container.prepareShow(interactive: true)
                    self._interactiveBackward = backward
                }
            }
            if let backward = self._interactiveBackward {
                let progress = max(0, absDeltaLocation / layoutSize.width)
                self._barView.transition(to: backward.barView, progress: progress)
                self._layout.state = .backward(current: current.pageItem, next: backward.pageItem, progress: progress)
            } else {
                self._barView.selectedItemView(current.barView)
                self._layout.state = .idle(current: current.pageItem)
            }
        } else {
            self._barView.selectedItemView(current.barView)
            self._layout.state = .idle(current: current.pageItem)
        }
    }

    func _endInteractiveGesture(_ canceled: Bool) {
        guard let beginLocation = self._interactiveBeginLocation, let current = self._interactiveCurrent else { return }
        let currentLocation = self._interactiveGesture.location(in: self._view)
        let deltaLocation = currentLocation.x - beginLocation.x
        let absDeltaLocation = abs(deltaLocation)
        let layoutSize = self._view.contentSize
        if let forward = self._interactiveForward, deltaLocation <= -self.interactiveLimit && canceled == false {
            QAnimation.default.run(
                duration: layoutSize.width / self.animationVelocity,
                elapsed: absDeltaLocation / self.animationVelocity,
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._barView.transition(to: forward.barView, progress: progress)
                    self._layout.state = .forward(current: current.pageItem, next: forward.pageItem, progress: progress)
                    self._layout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._finishForwardInteractiveAnimation()
                }
            )
        } else if let backward = self._interactiveBackward, deltaLocation >= self.interactiveLimit && canceled == false {
            QAnimation.default.run(
                duration: layoutSize.width / self.animationVelocity,
                elapsed: absDeltaLocation / self.animationVelocity,
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._barView.transition(to: backward.barView, progress: progress)
                    self._layout.state = .backward(current: current.pageItem, next: backward.pageItem, progress: progress)
                    self._layout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._finishBackwardInteractiveAnimation()
                }
            )
        } else if let forward = self._interactiveForward, deltaLocation < 0 {
            QAnimation.default.run(
                duration: layoutSize.width / self.animationVelocity,
                elapsed: (layoutSize.width - absDeltaLocation) / self.animationVelocity,
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._barView.transition(to: forward.barView, progress: 1 - progress)
                    self._layout.state = .forward(current: current.pageItem, next: forward.pageItem, progress: 1 - progress)
                    self._layout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._cancelInteractiveAnimation()
                }
            )
        } else if let backward = self._interactiveBackward, deltaLocation > 0 {
            QAnimation.default.run(
                duration: layoutSize.width / self.animationVelocity,
                elapsed: (layoutSize.width - absDeltaLocation) / self.animationVelocity,
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._barView.transition(to: backward.barView, progress: 1 - progress)
                    self._layout.state = .backward(current: current.pageItem, next: backward.pageItem, progress: 1 - progress)
                    self._layout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._cancelInteractiveAnimation()
                }
            )
        } else {
            self._cancelInteractiveAnimation()
        }
    }
    
    func _finishForwardInteractiveAnimation() {
        if let current = self._interactiveForward {
            self._barView.finishTransition(to: current.barView)
            self._layout.state = .idle(current: current.pageItem)
            self._current = current
        }
        self._interactiveForward?.container.finishShow(interactive: true)
        self._interactiveCurrent?.container.finishHide(interactive: true)
        self._interactiveBackward?.container.cancelShow(interactive: true)
        self._resetInteractiveAnimation()
        self.setNeedUpdateOrientations()
        self.setNeedUpdateStatusBar()
    }
    
    func _finishBackwardInteractiveAnimation() {
        if let current = self._interactiveBackward {
            self._barView.finishTransition(to: current.barView)
            self._layout.state = .idle(current: current.pageItem)
            self._current = current
        }
        self._interactiveForward?.container.cancelShow(interactive: true)
        self._interactiveCurrent?.container.finishHide(interactive: true)
        self._interactiveBackward?.container.finishShow(interactive: true)
        self._resetInteractiveAnimation()
        self.setNeedUpdateOrientations()
        self.setNeedUpdateStatusBar()
    }
    
    func _cancelInteractiveAnimation() {
        if let current = self._interactiveCurrent {
            self._barView.finishTransition(to: current.barView)
            self._layout.state = .idle(current: current.pageItem)
        }
        self._interactiveForward?.container.cancelShow(interactive: true)
        self._interactiveCurrent?.container.cancelHide(interactive: true)
        self._interactiveBackward?.container.cancelShow(interactive: true)
        self._resetInteractiveAnimation()
        self.setNeedUpdateOrientations()
        self.setNeedUpdateStatusBar()
    }
    
    func _resetInteractiveAnimation() {
        self._interactiveBeginLocation = nil
        self._interactiveCurrentIndex = nil
        self._interactiveBackward = nil
        self._interactiveCurrent = nil
        self._interactiveForward = nil
    }
    
}
    
#endif

private extension QPageContainer {
    
    class Item {
        
        var container: IQPageContentContainer
        var barView: IQBarItemView {
            return self.barItem.view as! IQBarItemView
        }
        var barItem: QLayoutItem
        var pageView: IQView {
            return self.pageItem.view
        }
        var pageItem: QLayoutItem

        init(
            container: IQPageContentContainer,
            insets: QInset
        ) {
            self.container = container
            self.barItem = QLayoutItem(view: container.pageItemView)
            self.pageItem = QLayoutItem(view: container.view)
        }
        
        func update() {
            self.barItem = QLayoutItem(view: self.container.pageItemView)
        }

    }
    
}

private extension QPageContainer {
    
    class Layout : IQLayout {
        
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
                y: bounds.origin.y - barOffset,
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

private extension QPageContainer.Layout {
    
    enum State {
        case empty
        case idle(current: QLayoutItem)
        case forward(current: QLayoutItem, next: QLayoutItem, progress: QFloat)
        case backward(current: QLayoutItem, next: QLayoutItem, progress: QFloat)
    }
    
}
