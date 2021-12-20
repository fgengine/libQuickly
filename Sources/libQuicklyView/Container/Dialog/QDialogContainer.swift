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
            guard self.parent !== oldValue else { return }
            guard self.isPresented == true else { return }
            self.didChangeInsets()
        }
    }
    public var shouldInteractive: Bool {
        return self.contentContainer?.shouldInteractive ?? false
    }
    #if os(iOS)
    public var statusBarHidden: Bool {
        guard let current = self._current else {
            return self.contentContainer?.statusBarHidden ?? false
        }
        return current.container.statusBarHidden
    }
    public var statusBarStyle: UIStatusBarStyle {
        guard let current = self._current else {
            return self.contentContainer?.statusBarStyle ?? .default
        }
        return current.container.statusBarStyle
    }
    public var statusBarAnimation: UIStatusBarAnimation {
        guard let current = self._current else {
            return self.contentContainer?.statusBarAnimation ?? .fade
        }
        return current.container.statusBarAnimation
    }
    public var supportedOrientations: UIInterfaceOrientationMask {
        guard let current = self._current else {
            return self.contentContainer?.supportedOrientations ?? .all
        }
        return current.container.supportedOrientations
    }
    #endif
    public private(set) var isPresented: Bool
    public var view: IQView {
        return self._view
    }
    public var contentContainer: (IQContainer & IQContainerParentable)? {
        didSet(oldValue) {
            if let contentContainer = self.contentContainer {
                if self.isPresented == true {
                    contentContainer.prepareHide(interactive: false)
                    contentContainer.finishHide(interactive: false)
                }
                contentContainer.parent = nil
            }
            self._view.contentLayout.contentItem = self.contentContainer.flatMap({ QLayoutItem(view: $0.view) })
            if let contentContainer = self.contentContainer {
                contentContainer.parent = self
                if self.isPresented == true {
                    contentContainer.prepareHide(interactive: false)
                    contentContainer.finishHide(interactive: false)
                }
            }
        }
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
    public var animationVelocity: Float
    #if os(iOS)
    public var interactiveLimit: Float
    #endif
    
    private var _view: QCustomView< Layout >
    #if os(iOS)
    private var _interactiveGesture: QPanGesture
    private var _interactiveBeginLocation: QPoint?
    private var _interactiveDialogItem: Item?
    private var _interactiveDialogSize: QSize?
    #endif
    private var _items: [Item]
    private var _previous: Item?
    private var _current: Item? {
        didSet {
            #if os(iOS)
            self._interactiveGesture.isEnabled = self._current != nil
            #endif
        }
    }
    
    public init(
        contentContainer: (IQContainer & IQContainerParentable)? = nil
    ) {
        self.isPresented = false
        #if os(iOS)
        self.animationVelocity = 1200
        self.interactiveLimit = 20
        #endif
        self.contentContainer = contentContainer
        #if os(iOS)
        self._interactiveGesture = QPanGesture(
            isEnabled: false
        )
        self._view = QCustomView(
            gestures: [ self._interactiveGesture ],
            contentLayout: Layout(
                containerInset: .zero,
                contentItem: contentContainer.flatMap({ QLayoutItem(view: $0.view) }),
                state: .idle
            )
        )
        #else
        self._view = QCustomView(
            contentLayout: Layout(
                containerInset: .zero,
                contentItem: contentContainer.flatMap({ QLayoutItem(view: $0.view) }),
                state: .idle
            )
        )
        #endif
        self._items = []
        self._init()
    }
    
    public func insets(of container: IQContainer, interactive: Bool) -> QInset {
        return self.inheritedInsets(interactive: interactive)
    }
    
    public func didChangeInsets() {
        self._view.contentLayout.containerInset = self.inheritedInsets(interactive: true)
        self.contentContainer?.didChangeInsets()
        for container in self.containers {
            container.didChangeInsets()
        }
    }
    
    public func activate() -> Bool {
        if let current = self._current {
            if current.container.activate() == true {
                return true
            }
        }
        if let contentContainer = self.contentContainer {
            return contentContainer.activate()
        }
        return false
    }
    
    public func didChangeAppearance() {
        for container in self.containers {
            container.didChangeAppearance()
        }
        if let contentContainer = self.contentContainer {
            contentContainer.didChangeAppearance()
        }
    }
    
    public func prepareShow(interactive: Bool) {
        self.didChangeInsets()
        self.contentContainer?.prepareShow(interactive: interactive)
        self.currentContainer?.prepareShow(interactive: interactive)
    }
    
    public func finishShow(interactive: Bool) {
        self.isPresented = true
        self.contentContainer?.finishShow(interactive: interactive)
        self.currentContainer?.finishShow(interactive: interactive)
    }
    
    public func cancelShow(interactive: Bool) {
        self.contentContainer?.cancelShow(interactive: interactive)
        self.currentContainer?.cancelShow(interactive: interactive)
    }
    
    public func prepareHide(interactive: Bool) {
        self.contentContainer?.prepareHide(interactive: interactive)
        self.currentContainer?.prepareHide(interactive: interactive)
    }
    
    public func finishHide(interactive: Bool) {
        self.isPresented = false
        self.contentContainer?.finishHide(interactive: interactive)
        self.currentContainer?.finishHide(interactive: interactive)
    }
    
    public func cancelHide(interactive: Bool) {
        self.contentContainer?.cancelHide(interactive: interactive)
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
        #if os(iOS)
        self._interactiveGesture.onShouldBeRequiredToFailBy({ [unowned self] gesture -> Bool in
            guard let contentContainer = self.contentContainer else { return true }
            guard let view = gesture.view else { return false }
            return contentContainer.view.native.isChild(of: view, recursive: true)
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
        self.contentContainer?.parent = self
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
        self._view.contentLayout.dialogItem = dialog
        self._view.contentLayout.state = .present(progress: 0)
        if let dialogSize = self._view.contentLayout.dialogSize {
            dialog.container.prepareShow(interactive: false)
            if animated == true {
                let size = self._view.contentLayout._size(dialog: dialog, size: dialogSize)
                QAnimation.default.run(
                    duration: TimeInterval(size / self.animationVelocity),
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._view.contentLayout.state = .present(progress: progress)
                        self._view.contentLayout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        dialog.container.finishShow(interactive: false)
                        self._view.contentLayout.state = .idle
                        self.setNeedUpdateOrientations()
                        self.setNeedUpdateStatusBar()
                        completion?()
                    }
                )
            } else {
                dialog.container.finishShow(interactive: false)
                self._view.contentLayout.state = .idle
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
                completion?()
            }
        } else {
            self._view.contentLayout.state = .idle
            self._view.contentLayout.dialogItem = nil
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
        self._view.contentLayout.dialogItem = dialog
        self._view.contentLayout.state = .dismiss(progress: 0)
        if let dialogSize = self._view.contentLayout.dialogSize {
            dialog.container.prepareHide(interactive: false)
            if animated == true {
                let size = self._view.contentLayout._size(dialog: dialog, size: dialogSize)
                QAnimation.default.run(
                    duration: TimeInterval(size / self.animationVelocity),
                    ease: QAnimation.Ease.QuadraticInOut(),
                    processing: { [weak self] progress in
                        guard let self = self else { return }
                        self._view.contentLayout.state = .dismiss(progress: progress)
                        self._view.contentLayout.updateIfNeeded()
                    },
                    completion: { [weak self] in
                        guard let self = self else { return }
                        dialog.container.finishHide(interactive: false)
                        self._view.contentLayout.state = .idle
                        self._view.contentLayout.dialogItem = nil
                        self.setNeedUpdateOrientations()
                        self.setNeedUpdateStatusBar()
                        completion?()
                    }
                )
            } else {
                dialog.container.finishHide(interactive: false)
                self._view.contentLayout.state = .idle
                self._view.contentLayout.dialogItem = nil
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
                completion?()
            }
        } else {
            self._view.contentLayout.state = .idle
            self._view.contentLayout.dialogItem = nil
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
        self._interactiveDialogItem = self._view.contentLayout.dialogItem
        self._interactiveDialogSize = self._view.contentLayout.dialogSize
        current.container.prepareHide(interactive: true)
    }
    
    func _changeInteractiveGesture() {
        guard let beginLocation = self._interactiveBeginLocation else { return }
        guard let dialogItem = self._interactiveDialogItem else { return }
        guard let dialogSize = self._interactiveDialogSize else { return }
        let currentLocation = self._interactiveGesture.location(in: self._view)
        let deltaLocation = currentLocation - beginLocation
        let progress = self._view.contentLayout._progress(dialog: dialogItem, size: dialogSize, delta: deltaLocation)
        self._view.contentLayout.state = .dismiss(progress: progress)
    }

    func _endInteractiveGesture(_ canceled: Bool) {
        guard let beginLocation = self._interactiveBeginLocation else { return }
        guard let dialogItem = self._interactiveDialogItem else { return }
        guard let dialogSize = self._interactiveDialogSize else { return }
        let currentLocation = self._interactiveGesture.location(in: self._view)
        let deltaLocation = currentLocation - beginLocation
        let size = self._view.contentLayout._size(dialog: dialogItem, size: dialogSize)
        let offset = self._view.contentLayout._offset(dialog: dialogItem, size: dialogSize, delta: deltaLocation)
        let baseProgress = self._view.contentLayout._progress(dialog: dialogItem, size: dialogSize, delta: deltaLocation)
        if offset > self.interactiveLimit {
            let viewAlphable = self._view.contentLayout.dialogItem?.container.view as? IQViewAlphable
            QAnimation.default.run(
                duration: TimeInterval(size / self.animationVelocity),
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    if let view = viewAlphable {
                        view.alpha(1 - progress)
                    }
                    self._view.contentLayout.state = .dismiss(progress: baseProgress + progress)
                    self._view.contentLayout.updateIfNeeded()
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
                duration: TimeInterval((size * abs(baseProgress)) / self.animationVelocity),
                processing: { [weak self] progress in
                    guard let self = self else { return }
                    self._view.contentLayout.state = .dismiss(progress: baseProgress * (1 - progress))
                    self._view.contentLayout.updateIfNeeded()
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
                self._view.contentLayout.state = .idle
                self._view.contentLayout.dialogItem = nil
                self.setNeedUpdateOrientations()
                self.setNeedUpdateStatusBar()
            }
        } else {
            self._current = nil
            self._view.contentLayout.state = .idle
            self._view.contentLayout.dialogItem = nil
            self.setNeedUpdateOrientations()
            self.setNeedUpdateStatusBar()
        }
    }
    
    func _cancelInteractiveAnimation() {
        self._resetInteractiveAnimation()
        if let current = self._current {
            current.container.cancelHide(interactive: true)
        }
        self._view.contentLayout.state = .idle
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
        var backgroundView: (IQView & IQViewAlphable)?
        var backgroundItem: QLayoutItem?

        init(container: IQDialogContentContainer, available: QSize) {
            self.container = container
            self.item = QLayoutItem(view: container.view)
            if let backgroundView = container.dialogBackgroundView {
                self.backgroundView = backgroundView
                self.backgroundItem = QLayoutItem(view: backgroundView)
            }
        }

    }
    
}

private extension QDialogContainer {
    
    class Layout : IQLayout {
        
        unowned var delegate: IQLayoutDelegate?
        unowned var view: IQView?
        var containerInset: QInset {
            didSet { self.setNeedUpdate() }
        }
        var contentItem: QLayoutItem? {
            didSet { self.setNeedUpdate() }
        }
        var state: State {
            didSet { self.setNeedUpdate() }
        }
        var dialogItem: Item? {
            didSet(oldValue) {
                guard self.dialogItem !== oldValue else { return }
                self._dialogSize = nil
                self.setNeedUpdate()
            }
        }
        var dialogSize: QSize? {
            self.updateIfNeeded()
            return self._dialogSize
        }
        
        private var _lastBoundsSize: QSize?
        private var _dialogSize: QSize?

        init(
            containerInset: QInset,
            contentItem: QLayoutItem?,
            state: State
        ) {
            self.containerInset = containerInset
            self.contentItem = contentItem
            self.state = state
        }
        
        func invalidate(item: QLayoutItem) {
            if self.dialogItem?.item === item {
                self._dialogSize = nil
            }
        }
        
        func layout(bounds: QRect) -> QSize {
            if let lastBoundsSize = self._lastBoundsSize {
                if lastBoundsSize != bounds.size {
                    self._dialogSize = nil
                    self._lastBoundsSize = bounds.size
                }
            } else {
                self._dialogSize = nil
                self._lastBoundsSize = bounds.size
            }
            if let contentItem = self.contentItem {
                contentItem.frame = bounds
            }
            if let dialog = self.dialogItem {
                if let backgroundItem = dialog.backgroundItem {
                    backgroundItem.frame = bounds
                }
                let availableBounds = bounds.apply(inset: dialog.container.dialogInset)
                let size: QSize
                if let dialogSize = self._dialogSize {
                    size = dialogSize
                } else {
                    size = self._size(bounds: availableBounds, dialog: dialog)
                    self._dialogSize = size
                }
                switch self.state {
                case .idle:
                    dialog.item.frame = self._idleRect(bounds: availableBounds, dialog: dialog, size: size)
                case .present(let progress):
                    let beginRect = self._presentRect(bounds: availableBounds, dialog: dialog, size: size)
                    let endRect = self._idleRect(bounds: availableBounds, dialog: dialog, size: size)
                    dialog.item.frame = beginRect.lerp(endRect, progress: progress)
                    if let view = dialog.item.view as? IQViewAlphable {
                        view.alpha = progress
                    }
                    if let backgroundView = dialog.backgroundView {
                        backgroundView.alpha = progress
                    }
                case .dismiss(let progress):
                    let beginRect = self._idleRect(bounds: availableBounds, dialog: dialog, size: size)
                    let endRect = self._dismissRect(bounds: availableBounds, dialog: dialog, size: size)
                    dialog.item.frame = beginRect.lerp(endRect, progress: progress)
                    if let view = dialog.item.view as? IQViewAlphable {
                        view.alpha = 1 - progress
                    }
                    if let backgroundView = dialog.backgroundView {
                        backgroundView.alpha = 1 - progress
                    }
                }
            }
            return bounds.size
        }
        
        func size(available: QSize) -> QSize {
            return available
        }
        
        func items(bounds: QRect) -> [QLayoutItem] {
            var items: [QLayoutItem] = []
            if let contentItem = self.contentItem {
                items.append(contentItem)
            }
            if let dialogItem = self.dialogItem {
                if let backgroundItem = dialogItem.backgroundItem {
                    items.append(backgroundItem)
                }
                items.append(dialogItem.item)
            }
            return items
        }
        
    }
    
}

private extension QDialogContainer.Layout {
    
    enum State {
        case idle
        case present(progress: Float)
        case dismiss(progress: Float)
    }
    
    @inline(__always)
    func _size(bounds: QRect, dialog: QDialogContainer.Item) -> QSize {
        let width, height: Float
        if dialog.container.dialogWidth == .fit && dialog.container.dialogHeight == .fit {
            let size = dialog.item.size(available: bounds.size)
            width = min(size.width, bounds.width)
            height = min(size.height, bounds.height)
        } else if dialog.container.dialogWidth == .fit {
            switch dialog.container.dialogHeight {
            case .fill(let before, let after): height = bounds.size.height - (before + after)
            case .fixed(let value): height = value
            case .fit: height = bounds.height
            }
            let size = dialog.item.size(available: QSize(width: bounds.size.width, height: height))
            width = min(size.width, bounds.width)
        } else if dialog.container.dialogHeight == .fit {
            switch dialog.container.dialogWidth {
            case .fill(let before, let after): width = bounds.size.width - (before + after)
            case .fixed(let value): width = value
            case .fit: width = bounds.width
            }
            let size = dialog.item.size(available: QSize(width: width, height: bounds.size.height))
            height = min(size.height, bounds.height)
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
    func _offset(dialog: QDialogContainer.Item, size: QSize, delta: QPoint) -> Float {
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
    func _size(dialog: QDialogContainer.Item, size: QSize) -> Float {
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
    func _progress(dialog: QDialogContainer.Item, size: QSize, delta: QPoint) -> Float {
        let dialogOffset = self._offset(dialog: dialog, size: size, delta: delta)
        let dialogSize = self._size(dialog: dialog, size: size)
        if dialogOffset < 0 {
            return dialogOffset / pow(dialogSize, 1.25)
        }
        return dialogOffset / dialogSize
    }
    
}
