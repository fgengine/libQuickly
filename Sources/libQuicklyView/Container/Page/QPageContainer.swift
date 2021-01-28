//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QPageContainer< Screen : IQPageScreen > : IQPageContainer, IQContainerScreenable {
    
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
    public private(set) var barView: IQPageBarView {
        didSet(oldValue) {
            guard self.barView !== oldValue else { return }
            self._rootLayout.barItem = QLayoutItem(view: self.barView)
        }
    }
    public private(set) var barSize: QFloat {
        didSet(oldValue) {
            guard self.barSize != oldValue else { return }
            self._rootLayout.barSize = self.barSize
        }
    }
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
    
    private var _rootView: QCustomView
    private var _rootLayout: RootLayout
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
        self.barView = screen.pageBarView
        self.barSize = screen.pageBarSize
        #if os(iOS)
        self.interactiveLimit = QFloat(UIScreen.main.bounds.width * 0.33)
        self.interactiveVelocity = QFloat(UIScreen.main.bounds.width * 5)
        #endif
        self._rootLayout = RootLayout(
            barInset: 0,
            barSize: self.barSize,
            barItem: QLayoutItem(view: self.barView)
        )
        #if os(iOS)
        self._interactiveGesture = QPanGesture()
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
        self.barView.safeArea(QInset(top: inheritedInsets.top, left: inheritedInsets.left, right: inheritedInsets.right))
        self._rootLayout.barInset = inheritedInsets.top
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
    
    public func updateBar(animated: Bool, completion: (() -> Void)?) {
        self.barSize = self.screen.pageBarSize
        self.barView = self.screen.pageBarView
        completion?()
    }
    
    public func update(container: IQPageContentContainer, animated: Bool, completion: (() -> Void)?) {
        guard let item = self._items.first(where: { $0.container === container }) else {
            completion?()
            return
        }
        item.update()
        self.barView.views(self._items.compactMap({ $0.barView }))
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
        self.barView.views(self._items.compactMap({ $0.barView }))
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

private extension QPageContainer {
    
    class Item {
        
        var container: IQPageContentContainer
        var barView: IQView {
            return self.barItem.view
        }
        var barItem: IQLayoutItem
        var pageView: IQView {
            return self.pageItem.view
        }
        var pageItem: IQLayoutItem

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
    
    class RootLayout : IQLayout {
        
        enum State {
            case empty
            case idle(current: IQLayoutItem)
            case forward(current: IQLayoutItem, next: IQLayoutItem, progress: QFloat)
            case backward(current: IQLayoutItem, next: IQLayoutItem, progress: QFloat)
        }
        
        weak var delegate: IQLayoutDelegate?
        weak var parentView: IQView?
        var barInset: QFloat {
            didSet { self.setNeedUpdate() }
        }
        var barSize: QFloat {
            didSet { self.setNeedUpdate() }
        }
        var barItem: IQLayoutItem {
            didSet { self.setNeedUpdate() }
        }
        var state: State {
            didSet { self.setNeedUpdate() }
        }

        init(
            barInset: QFloat,
            barSize: QFloat,
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

private extension QPageContainer {
    
    func _init() {
        self.screen.container = self
        #if os(iOS)
        self._interactiveGesture.onShouldBegin({ [weak self] in
            guard let self = self else { return false }
            return self._items.count > 1
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
                self.barView.beginTransition()
                QAnimation.default.run(
                    duration: 0.2,
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self.barView.changeTransition(to: forward.barView, progress: progress)
                        self._rootLayout.state = .forward(current: current.pageItem, next: forward.pageItem, progress: progress)
                        self._rootLayout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self.barView.finishTransition(to: forward.barView)
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
                self.barView.selectedView(forward.barView)
                self._rootLayout.state = .idle(current: forward.pageItem)
                if self.isPresented == true {
                    forward.container.finishShow(interactive: false)
                }
                completion?()
            } else if let current = current {
                if self.isPresented == true {
                    current.container.prepareHide(interactive: false)
                }
                self.barView.selectedView(nil)
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
            self.barView.selectedView(forward.barView)
            self._rootLayout.state = .idle(current: forward.pageItem)
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
                forward.container.finishShow(interactive: false)
            }
        } else if let forward = forward {
            if self.isPresented == true {
                forward.container.prepareShow(interactive: false)
            }
            self.barView.selectedView(forward.barView)
            self._rootLayout.state = .idle(current: forward.pageItem)
            if self.isPresented == true {
                forward.container.finishShow(interactive: false)
            }
            completion?()
        } else if let current = current {
            if self.isPresented == true {
                current.container.prepareHide(interactive: false)
            }
            self.barView.selectedView(nil)
            self._rootLayout.state = .empty
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
            }
            completion?()
        } else {
            self.barView.selectedView(nil)
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
                self.barView.beginTransition()
                QAnimation.default.run(
                    duration: 0.2,
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self.barView.changeTransition(to: backward.barView, progress: progress)
                        self._rootLayout.state = .backward(current: current.pageItem, next: backward.pageItem, progress: progress)
                        self._rootLayout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        self.barView.finishTransition(to: backward.barView)
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
                self.barView.selectedView(backward.barView)
                self._rootLayout.state = .idle(current: backward.pageItem)
                if self.isPresented == true {
                    backward.container.finishShow(interactive: false)
                }
                completion?()
            } else if let current = current {
                if self.isPresented == true {
                    current.container.prepareHide(interactive: false)
                }
                self.barView.selectedView(nil)
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
            self.barView.selectedView(backward.barView)
            self._rootLayout.state = .idle(current: backward.pageItem)
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
                backward.container.finishShow(interactive: false)
            }
        } else if let backward = backward {
            if self.isPresented == true {
                backward.container.prepareShow(interactive: false)
            }
            self.barView.selectedView(nil)
            self._rootLayout.state = .idle(current: backward.pageItem)
            if self.isPresented == true {
                backward.container.finishShow(interactive: false)
            }
            completion?()
        } else if let current = current {
            if self.isPresented == true {
                current.container.prepareHide(interactive: false)
            }
            self.barView.selectedView(nil)
            self._rootLayout.state = .empty
            if self.isPresented == true {
                current.container.finishHide(interactive: false)
            }
            completion?()
        } else {
            self.barView.selectedView(nil)
            self._rootLayout.state = .empty
            completion?()
        }
    }
    
}

#if os(iOS)

import UIKit

private extension QPageContainer {
    
    func _beginInteractiveGesture() {
        guard let index = self._items.firstIndex(where: { $0 === self._current }) else { return }
        self._interactiveBeginLocation = self._interactiveGesture.location(in: self._rootView)
        self.barView.beginTransition()
        self._interactiveCurrentIndex = index
        let current = self._items[index]
        current.container.prepareHide(interactive: true)
        self._interactiveCurrent = current
    }
    
    func _changeInteractiveGesture() {
        guard let beginLocation = self._interactiveBeginLocation, let current = self._interactiveCurrent else { return }
        let currentLocation = self._interactiveGesture.location(in: self._rootView)
        let deltaLocation = currentLocation.x - beginLocation.x
        let absDeltaLocation = abs(deltaLocation)
        let layoutSize = self._rootView.contentSize
        if deltaLocation < 0 {
            if let index = self._interactiveCurrentIndex, self._interactiveForward == nil {
                if let forward = index < self._items.count - 1 ? self._items[index + 1] : nil {
                    forward.container.prepareShow(interactive: true)
                    self._interactiveForward = forward
                }
            }
            if let forward = self._interactiveForward {
                let progress = max(0, absDeltaLocation / layoutSize.width)
                self.barView.changeTransition(to: forward.barView, progress: progress)
                self._rootLayout.state = .forward(current: current.pageItem, next: forward.pageItem, progress: progress)
            } else {
                self.barView.selectedView(current.barView)
                self._rootLayout.state = .idle(current: current.pageItem)
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
                self.barView.changeTransition(to: backward.barView, progress: progress)
                self._rootLayout.state = .backward(current: current.pageItem, next: backward.pageItem, progress: progress)
            } else {
                self.barView.selectedView(current.barView)
                self._rootLayout.state = .idle(current: current.pageItem)
            }
        } else {
            self.barView.selectedView(current.barView)
            self._rootLayout.state = .idle(current: current.pageItem)
        }
    }

    func _endInteractiveGesture(_ canceled: Bool) {
        guard let beginLocation = self._interactiveBeginLocation, let current = self._interactiveCurrent else { return }
        let currentLocation = self._interactiveGesture.location(in: self._rootView)
        let deltaLocation = currentLocation.x - beginLocation.x
        let absDeltaLocation = abs(deltaLocation)
        let layoutSize = self._rootView.contentSize
        if let forward = self._interactiveForward, deltaLocation <= -self.interactiveLimit && canceled == false {
            QAnimation.default.run(
                duration: layoutSize.width / self.interactiveVelocity,
                elapsed: absDeltaLocation / self.interactiveVelocity,
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self.barView.changeTransition(to: forward.barView, progress: progress)
                    self._rootLayout.state = .forward(current: current.pageItem, next: forward.pageItem, progress: progress)
                    self._rootLayout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._finishForwardInteractiveAnimation()
                }
            )
        } else if let backward = self._interactiveBackward, deltaLocation >= self.interactiveLimit && canceled == false {
            QAnimation.default.run(
                duration: layoutSize.width / self.interactiveVelocity,
                elapsed: absDeltaLocation / self.interactiveVelocity,
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self.barView.changeTransition(to: backward.barView, progress: progress)
                    self._rootLayout.state = .backward(current: current.pageItem, next: backward.pageItem, progress: progress)
                    self._rootLayout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._finishBackwardInteractiveAnimation()
                }
            )
        } else if let forward = self._interactiveForward, deltaLocation < 0 {
            QAnimation.default.run(
                duration: layoutSize.width / self.interactiveVelocity,
                elapsed: (layoutSize.width - absDeltaLocation) / self.interactiveVelocity,
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self.barView.changeTransition(to: forward.barView, progress: 1 - progress)
                    self._rootLayout.state = .forward(current: current.pageItem, next: forward.pageItem, progress: 1 - progress)
                    self._rootLayout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    self._cancelInteractiveAnimation()
                }
            )
        } else if let backward = self._interactiveBackward, deltaLocation > 0 {
            QAnimation.default.run(
                duration: layoutSize.width / self.interactiveVelocity,
                elapsed: (layoutSize.width - absDeltaLocation) / self.interactiveVelocity,
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self.barView.changeTransition(to: backward.barView, progress: 1 - progress)
                    self._rootLayout.state = .backward(current: current.pageItem, next: backward.pageItem, progress: 1 - progress)
                    self._rootLayout.updateIfNeeded()
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
            self.barView.finishTransition(to: current.barView)
            self._rootLayout.state = .idle(current: current.pageItem)
            self._current = current
        }
        self._interactiveForward?.container.finishShow(interactive: true)
        self._interactiveCurrent?.container.finishHide(interactive: true)
        self._interactiveBackward?.container.cancelShow(interactive: true)
        self._resetInteractiveAnimation()
    }
    
    func _finishBackwardInteractiveAnimation() {
        if let current = self._interactiveBackward {
            self.barView.finishTransition(to: current.barView)
            self._rootLayout.state = .idle(current: current.pageItem)
            self._current = current
        }
        self._interactiveForward?.container.cancelShow(interactive: true)
        self._interactiveCurrent?.container.finishHide(interactive: true)
        self._interactiveBackward?.container.finishShow(interactive: true)
        self._resetInteractiveAnimation()
    }
    
    func _cancelInteractiveAnimation() {
        if let current = self._interactiveCurrent {
            self.barView.finishTransition(to: current.barView)
            self._rootLayout.state = .idle(current: current.pageItem)
        }
        self._interactiveForward?.container.cancelShow(interactive: true)
        self._interactiveCurrent?.container.cancelHide(interactive: true)
        self._interactiveBackward?.container.cancelShow(interactive: true)
        self._resetInteractiveAnimation()
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
