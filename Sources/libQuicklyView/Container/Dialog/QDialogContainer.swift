//
//  libQuicklyView
//

import Foundation
#if os(iOS)
import UIKit
#endif
import libQuicklyCore

public class QDialogContainer : IQDialogContainer {
    
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
    public var containers: [IQDialogContentContainer] {
        return self._items.compactMap({ return $0.container })
    }
    public var previousContainer: IQDialogContentContainer? {
        return self._previous?.container
    }
    public var currentContainer: IQDialogContentContainer? {
        return self._current?.container
    }
    public var animationVelocity: QFloat
    #if os(iOS)
    public var interactiveLimit: QFloat
    #endif
    
    private var _layout: Layout
    private var _view: QCustomView< Layout >
    #if os(iOS)
    private var _interactiveGesture: QPanGesture
    private var _interactiveBeginLocation: QPoint?
    private var _interactiveDialogItem: Item?
    private var _interactiveDialogSize: QSize?
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
        self.animationVelocity = 700
        self.interactiveLimit = 20
        #endif
        self._contentContainer = contentContainer
        self._layout = Layout(
            containerInset: QInset(),
            contentItem: QLayoutItem(view: contentContainer.view),
            state: .idle
        )
        #if os(iOS)
        self._interactiveGesture = QPanGesture(name: "QDialogContainer-PanGesture")
        self._view = QCustomView(
            name: "QDialogContainer-RootView",
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
    
    public func present(container: IQDialogContentContainer, animated: Bool, completion: (() -> Void)?) {
        container.parent = self
        let item = Item(container: container, available: self._view.bounds.size)
        self._items.append(item)
        if self._current == nil {
            self._present(dialog: item, animated: animated, completion: completion)
        } else {
            completion?()
        }
    }
    
    public func dismiss(container: IQDialogContentContainer, animated: Bool, completion: (() -> Void)?) {
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

extension QDialogContainer : IQRootContentContainer {
}

private extension QDialogContainer {
    
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
            guard self._interactiveGesture.contains(in: current.container.view) == true else { return false }
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
        #endif
    }
    
    func _present(current: Item?, next: Item, animated: Bool, completion: (() -> Void)?) {
        if let current = current {
            self._dismiss(dialog: current, animated: animated, completion: { [weak self] in
                guard let self = self else { return }
                self._present(dialog: next, animated: animated, completion: completion)
            })
        } else {
            self._present(dialog: next, animated: animated, completion: completion)
        }
    }

    func _present(dialog: Item, animated: Bool, completion: (() -> Void)?) {
        self._current = dialog
        self._layout.dialogItem = dialog
        if let dialogSize = self._layout.dialogSize {
            dialog.container.prepareShow(interactive: false)
            if animated == true {
                let size = self._layout._size(dialog: dialog, size: dialogSize)
                QAnimation.default.run(
                    duration: size / self.animationVelocity,
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._layout.state = .present(progress: progress)
                        self._layout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        dialog.container.finishShow(interactive: false)
                        self._layout.state = .idle
                        self.setNeedUpdateOrientations()
                        self.setNeedUpdateStatusBar()
                        completion?()
                    }
                )
            } else {
                dialog.container.finishShow(interactive: false)
                self._layout.state = .idle
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
                completion?()
            }
        } else {
            self._layout.state = .idle
            self._layout.dialogItem = nil
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        }
    }

    func _dismiss(current: Item, previous: Item?, animated: Bool, completion: (() -> Void)?) {
        self._dismiss(dialog: current, animated: animated, completion: { [weak self] in
            guard let self = self else { return }
            self._current = previous
            if let previous = previous {
                self._present(dialog: previous, animated: animated, completion: completion)
            } else {
                completion?()
            }
        })
    }
    
    func _dismiss(dialog: Item, animated: Bool, completion: (() -> Void)?) {
        self._layout.dialogItem = dialog
        if let dialogSize = self._layout.dialogSize {
            dialog.container.prepareHide(interactive: false)
            if animated == true {
                let size = self._layout._size(dialog: dialog, size: dialogSize)
                QAnimation.default.run(
                    duration: size / self.animationVelocity,
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._layout.state = .dismiss(progress: progress)
                        self._layout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        dialog.container.finishHide(interactive: false)
                        self._layout.state = .idle
                        self._layout.dialogItem = nil
                        self.setNeedUpdateOrientations()
                        self.setNeedUpdateStatusBar()
                        completion?()
                    }
                )
            } else {
                dialog.container.finishHide(interactive: false)
                self._layout.state = .idle
                self._layout.dialogItem = nil
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
                completion?()
            }
        } else {
            self._layout.state = .idle
            self._layout.dialogItem = nil
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
            completion?()
        }
    }
    
}

#if os(iOS)

private extension QDialogContainer {
    
    func _beginInteractiveGesture() {
        guard let current = self._current else { return }
        self._interactiveBeginLocation = self._interactiveGesture.location(in: self._view)
        self._interactiveDialogItem = self._layout.dialogItem
        self._interactiveDialogSize = self._layout.dialogSize
        current.container.prepareHide(interactive: true)
    }
    
    func _changeInteractiveGesture() {
        guard let beginLocation = self._interactiveBeginLocation else { return }
        guard let dialogItem = self._interactiveDialogItem else { return }
        guard let dialogSize = self._interactiveDialogSize else { return }
        let currentLocation = self._interactiveGesture.location(in: self._view)
        let deltaLocation = currentLocation - beginLocation
        let progress = self._layout._progress(dialog: dialogItem, size: dialogSize, delta: deltaLocation)
        self._layout.state = .dismiss(progress: progress)
    }

    func _endInteractiveGesture(_ canceled: Bool) {
        guard let beginLocation = self._interactiveBeginLocation else { return }
        guard let dialogItem = self._interactiveDialogItem else { return }
        guard let dialogSize = self._interactiveDialogSize else { return }
        let currentLocation = self._interactiveGesture.location(in: self._view)
        let deltaLocation = currentLocation - beginLocation
        let size = self._layout._size(dialog: dialogItem, size: dialogSize)
        let offset = self._layout._offset(dialog: dialogItem, size: dialogSize, delta: deltaLocation)
        let baseProgress = self._layout._progress(dialog: dialogItem, size: dialogSize, delta: deltaLocation)
        if offset > self.interactiveLimit {
            let viewAlphable = self._layout.dialogItem?.container.view as? IQViewAlphable
            QAnimation.default.run(
                duration: size / self.animationVelocity,
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    if let view = viewAlphable {
                        view.alpha(1 - progress)
                    }
                    self._layout.state = .dismiss(progress: baseProgress + progress)
                    self._layout.updateIfNeeded()
                },
                completion: { [weak self] in
                    guard let self = self else { return }
                    if let view = viewAlphable {
                        view.alpha(1)
                    }
                    self._finishInteractiveAnimation()
                }
            )
        } else {
            QAnimation.default.run(
                duration: (size * abs(baseProgress)) / self.animationVelocity,
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._layout.state = .dismiss(progress: baseProgress * (1 - progress))
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
        self._resetInteractiveAnimation()
        if let current = self._current {
            current.container.finishHide(interactive: true)
            current.container.parent = nil
            if let index = self._items.firstIndex(where: { $0 === current }) {
                self._items.remove(at: index)
            }
            self._previous = self._items.first
            if let previous = self._previous {
                self._present(dialog: previous, animated: true, completion: nil)
            } else {
                self._current = nil
                self._layout.state = .idle
                self._layout.dialogItem = nil
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
            }
        } else {
            self._current = nil
            self._layout.state = .idle
            self._layout.dialogItem = nil
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
        }
    }
    
    func _cancelInteractiveAnimation() {
        self._resetInteractiveAnimation()
        if let current = self._current {
            current.container.cancelHide(interactive: true)
        }
        self._layout.state = .idle
        self.setNeedUpdateOrientations()
        self.setNeedUpdateStatusBar()
    }
    
    func _resetInteractiveAnimation() {
        self._interactiveBeginLocation = nil
        self._interactiveDialogItem = nil
        self._interactiveDialogSize = nil
    }
    
}
    
#endif

private extension QDialogContainer {
    
    class Item {
        
        var container: IQDialogContentContainer
        var item: QLayoutItem

        init(container: IQDialogContentContainer, available: QSize) {
            self.container = container
            self.item = QLayoutItem(view: container.view)
        }

    }
    
}

private extension QDialogContainer {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var parentView: IQView?
        var containerInset: QInset {
            didSet { self.setNeedUpdate() }
        }
        var contentItem: QLayoutItem {
            didSet { self.setNeedUpdate() }
        }
        var state: State {
            didSet { self.setNeedUpdate() }
        }
        var dialogItem: Item? {
            didSet { self.setNeedUpdate(true) }
        }
        var dialogSize: QSize? {
            self.updateIfNeeded()
            return self._dialogSize
        }
        
        private var _lastBoundsSize: QSize?
        private var _dialogSize: QSize?

        init(
            containerInset: QInset,
            contentItem: QLayoutItem,
            state: State
        ) {
            self.containerInset = containerInset
            self.contentItem = contentItem
            self.state = state
        }
        
        func invalidate() {
            self._dialogSize = nil
        }
        
        func layout(bounds: QRect) -> QSize {
            if let lastBoundsSize = self._lastBoundsSize {
                if lastBoundsSize != bounds.size {
                    self.invalidate()
                    self._lastBoundsSize = bounds.size
                }
            } else {
                self.invalidate()
                self._lastBoundsSize = bounds.size
            }
            self.contentItem.frame = bounds
            if let dialog = self.dialogItem {
                let size: QSize
                if let dialogSize = self._dialogSize {
                    size = dialogSize
                } else {
                    size = self._size(bounds: bounds, dialog: dialog)
                    self._dialogSize = size
                }
                switch self.state {
                case .idle:
                    dialog.item.frame = self._idleRect(bounds: bounds, dialog: dialog, size: size)
                case .present(let progress):
                    let beginRect = self._presentRect(bounds: bounds, dialog: dialog, size: size)
                    let endRect = self._idleRect(bounds: bounds, dialog: dialog, size: size)
                    dialog.item.frame = beginRect.lerp(endRect, progress: progress)
                case .dismiss(let progress):
                    let beginRect = self._idleRect(bounds: bounds, dialog: dialog, size: size)
                    let endRect = self._dismissRect(bounds: bounds, dialog: dialog, size: size)
                    dialog.item.frame = beginRect.lerp(endRect, progress: progress)
                }
            }
            return bounds.size
        }
        
        func size(_ available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            if let dialogItem = self.dialogItem {
                return [ self.contentItem, dialogItem.item ]
            }
            return [ self.contentItem ]
        }
        
    }
    
}

private extension QDialogContainer.Layout {
    
    enum State {
        case idle
        case present(progress: QFloat)
        case dismiss(progress: QFloat)
    }
    
    @inline(__always)
    func _size(bounds: QRect, dialog: QDialogContainer.Item) -> QSize {
        let width, height: QFloat
        if dialog.container.dialogWidth == .fit && dialog.container.dialogHeight == .fit {
            let size = dialog.item.size(bounds.size)
            width = size.width
            height = size.height
        } else if dialog.container.dialogWidth == .fit {
            switch dialog.container.dialogHeight {
            case .fill(let before, let after): height = bounds.size.height - (before + after)
            case .fixed(let value): height = value
            case .fit: height = bounds.height
            }
            let size = dialog.item.size(QSize(width: bounds.size.width, height: height))
            width = size.width
        } else if dialog.container.dialogHeight == .fit {
            switch dialog.container.dialogWidth {
            case .fill(let before, let after): width = bounds.size.width - (before + after)
            case .fixed(let value): width = value
            case .fit: width = bounds.width
            }
            let size = dialog.item.size(QSize(width: width, height: bounds.size.height))
            height = size.height
        } else {
            switch dialog.container.dialogWidth {
            case .fill(let before, let after): width = bounds.size.width - (before + after)
            case .fixed(let value): width = value
            case .fit: width = bounds.width
            }
            switch dialog.container.dialogHeight {
            case .fill(let before, let after): height = bounds.size.height - (before + after)
            case .fixed(let value): height = value
            case .fit: height = bounds.height
            }
        }
        return QSize(width: width, height: height)
    }
    
    @inline(__always)
    func _presentRect(bounds: QRect, dialog: QDialogContainer.Item, size: QSize) -> QRect {
        switch dialog.container.dialogAlignment {
        case .topLeft: return QRect(topRight: bounds.topLeft, size: size)
        case .top: return QRect(bottom: bounds.top, size: size)
        case .topRight: return QRect(topLeft: bounds.topRight, size: size)
        case .centerLeft: return QRect(right: bounds.left, size: size)
        case .center: return QRect(center: bounds.center - QPoint(x: 0, y: size.height), size: size)
        case .centerRight: return QRect(left: bounds.right, size: size)
        case .bottomLeft: return QRect(bottomRight: bounds.bottomLeft, size: size)
        case .bottom: return QRect(top: bounds.bottom, size: size)
        case .bottomRight: return QRect(bottomLeft: bounds.bottomRight, size: size)
        }
    }
    
    @inline(__always)
    func _idleRect(bounds: QRect, dialog: QDialogContainer.Item, size: QSize) -> QRect {
        switch dialog.container.dialogAlignment {
        case .topLeft: return QRect(topLeft: bounds.topLeft, size: size)
        case .top: return QRect(top: bounds.top, size: size)
        case .topRight: return QRect(topRight: bounds.topRight, size: size)
        case .centerLeft: return QRect(left: bounds.left, size: size)
        case .center: return QRect(center: bounds.center, size: size)
        case .centerRight: return QRect(right: bounds.right, size: size)
        case .bottomLeft: return QRect(bottomLeft: bounds.bottomLeft, size: size)
        case .bottom: return QRect(bottom: bounds.bottom, size: size)
        case .bottomRight: return QRect(bottomRight: bounds.bottomRight, size: size)
        }
    }
    
    @inline(__always)
    func _dismissRect(bounds: QRect, dialog: QDialogContainer.Item, size: QSize) -> QRect {
        switch dialog.container.dialogAlignment {
        case .topLeft: return QRect(topRight: bounds.topLeft, size: size)
        case .top: return QRect(bottom: bounds.top, size: size)
        case .topRight: return QRect(topLeft: bounds.topRight, size: size)
        case .centerLeft: return QRect(right: bounds.left, size: size)
        case .center: return QRect(center: bounds.center + QPoint(x: 0, y: size.height), size: size)
        case .centerRight: return QRect(left: bounds.right, size: size)
        case .bottomLeft: return QRect(bottomRight: bounds.bottomLeft, size: size)
        case .bottom: return QRect(top: bounds.bottom, size: size)
        case .bottomRight: return QRect(bottomLeft: bounds.bottomRight, size: size)
        }
    }
    
    @inline(__always)
    func _offset(dialog: QDialogContainer.Item, size: QSize, delta: QPoint) -> QFloat {
        switch dialog.container.dialogAlignment {
        case .topLeft: return -delta.x
        case .top: return -delta.y
        case .topRight: return delta.x
        case .centerLeft: return -delta.x
        case .center: return delta.y
        case .centerRight: return delta.x
        case .bottomLeft: return -delta.x
        case .bottom: return delta.y
        case .bottomRight: return delta.x
        }
    }
    
    @inline(__always)
    func _size(dialog: QDialogContainer.Item, size: QSize) -> QFloat {
        switch dialog.container.dialogAlignment {
        case .topLeft: return size.width
        case .top: return size.height
        case .topRight: return size.width
        case .centerLeft: return size.width
        case .center: return size.height
        case .centerRight: return size.width
        case .bottomLeft: return size.width
        case .bottom: return size.height
        case .bottomRight: return size.width
        }
    }
    
    @inline(__always)
    func _progress(dialog: QDialogContainer.Item, size: QSize, delta: QPoint) -> QFloat {
        let dialogOffset = self._offset(dialog: dialog, size: size, delta: delta)
        let dialogSize = self._size(dialog: dialog, size: size)
        if dialogOffset < 0 {
            return dialogOffset / pow(dialogSize, 1.25)
        }
        return dialogOffset / dialogSize
    }
    
}
