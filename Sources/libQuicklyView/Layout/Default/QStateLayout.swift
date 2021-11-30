//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QStateLayout< State : Equatable & Hashable > : IQLayout {
    
    public unowned var delegate: IQLayoutDelegate?
    public unowned var view: IQView?
    public var state: State {
        set(value) {
            self._internalState = .idle(state: value)
        }
        get {
            switch self._internalState {
            case .idle(let state): return state
            case .animation(_, let from, let to, let progress):
                if progress > 0.5 {
                    return to
                }
                return from
            }
        }
    }
    public var insets: [State : QInset] {
        return self.data.mapValues({ $0.inset })
    }
    public var alignments: [State : Alignment] {
        return self.data.mapValues({ $0.alignment })
    }
    public var items: [State : QLayoutItem] {
        var result: [State : QLayoutItem] = [:]
        for data in self.data {
            guard let item = data.value.item else { continue }
            result[data.key] = item
        }
        return result
    }
    public private(set) var data: [State : Data]
    
    private var _internalState: InternalState {
        didSet(oldValue) {
            guard self._internalState != oldValue else { return }
            self.setNeedForceUpdate()
        }
    }

    public init(
        state: State,
        data: [State : Data] = [:]
    ) {
        self._internalState = .idle(state: state)
        self.data = data
    }
    
    public convenience init(
        state: State,
        insets: [State : QInset] = [:],
        alignments: [State : Alignment] = [:],
        items: [State : QLayoutItem]
    ) {
        self.init(
            state: state,
            data: [:]
        )
        insets.forEach({
            self.set(state: $0.key, inset: $0.value)
        })
        alignments.forEach({
            self.set(state: $0.key, alignment: $0.value)
        })
        items.forEach({
            self.set(state: $0.key, item: $0.value)
        })
    }
    
    public convenience init(
        state: State,
        insets: [State : QInset] = [:],
        alignments: [State : Alignment] = [:],
        views: [State : IQView]
    ) {
        self.init(
            state: state,
            data: [:]
        )
        insets.forEach({
            self.set(state: $0.key, inset: $0.value)
        })
        alignments.forEach({
            self.set(state: $0.key, alignment: $0.value)
        })
        views.forEach({
            self.set(state: $0.key, view: $0.value)
        })
    }
    
    public func set(state: State, inset: QInset) {
        self._data(state: state, update: { $0.inset = inset })
        if self._internalState.contains(state: state) == true {
            self.setNeedForceUpdate()
        }
    }
    
    public func inset(state: State) -> QInset? {
        return self.data[state]?.inset
    }
    
    public func set(state: State, alignment: Alignment) {
        self._data(state: state, update: { $0.alignment = alignment })
        if self._internalState.contains(state: state) == true {
            self.setNeedForceUpdate()
        }
    }
    
    public func alignment(state: State) -> Alignment? {
        return self.data[state]?.alignment
    }
    
    public func set(state: State, item: QLayoutItem?) {
        self._data(state: state, update: { $0.item = item })
        if self._internalState.contains(state: state) == true {
            self.setNeedForceUpdate()
        }
    }
    
    public func item(state: State) -> QLayoutItem? {
        return self.data[state]?.item
    }
    
    public func set(state: State, view: IQView?) {
        self._data(state: state, update: { $0.view = view })
        if self._internalState.contains(state: state) == true {
            self.setNeedForceUpdate()
        }
    }
    
    public func view(state: State) -> IQView? {
        return self.data[state]?.view
    }
    
    public func set(state: State, data: Data?) {
        self.data[state] = data
        if self._internalState.contains(state: state) == true {
            self.setNeedForceUpdate()
        }
    }
    
    public func data(state: State) -> Data? {
        return self.data[state]
    }
    
    public func animate(
        duration: TimeInterval,
        ease: IQAnimationEase = QAnimation.Ease.Linear(),
        transition: Transition,
        state: State,
        completion: (() -> Void)? = nil
    ) {
        let fromState = self.state
        QAnimation.default.run(
            duration: duration,
            ease: ease,
            processing: { [unowned self] progress in
                self._internalState = .animation(transition: transition, from: fromState, to: state, progress: progress)
                self.setNeedForceUpdate()
                self.updateIfNeeded()
            },
            completion: { [unowned self] in
                self._internalState = .idle(state: state)
                self.setNeedForceUpdate()
                self.updateIfNeeded()
                completion?()
            }
        )
    }
    
    public func layout(bounds: QRect) -> QSize {
        switch self._internalState {
        case .idle(let state):
            return self._layout(bounds: bounds, state: state)
        case .animation(let transition, let from, let to, let progress):
            let fromBeginBounds = self._fromBeginBounds(bounds: bounds, transition: transition)
            let fromEndBounds = self._fromEndBounds(bounds: bounds, transition: transition)
            let fromBounds = fromBeginBounds.lerp(fromEndBounds, progress: progress)
            let toBeginBounds = self._toBeginBounds(bounds: bounds, transition: transition)
            let toEndBounds = self._toEndBounds(bounds: bounds, transition: transition)
            let toBounds = toBeginBounds.lerp(toEndBounds, progress: progress)
            let fromSize = self._layout(bounds: fromBounds, state: from)
            let toSize = self._layout(bounds: toBounds, state: to)
            return fromSize.lerp(toSize, progress: progress)
        }
    }
    
    public func size(available: QSize) -> QSize {
        switch self._internalState {
        case .idle(let state):
            return self._size(available: available, state: state)
        case .animation(_, let from, let to, let progress):
            let fromSize = self._size(available: available, state: from)
            let toSize = self._size(available: available, state: to)
            return fromSize.lerp(toSize, progress: progress)
        }
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        var items: [QLayoutItem] = []
        switch self._internalState {
        case .idle(let state):
            if let item = self.data[state]?.item {
                items.append(item)
            }
        case .animation(_, let from, let to, _):
            if let item = self.data[from]?.item {
                items.append(item)
            }
            if let item = self.data[to]?.item {
                items.append(item)
            }
        }
        return items
    }
    
}

public extension QStateLayout {
    
    enum Alignment {
        case topLeft
        case top
        case topRight
        case left
        case center
        case right
        case bottomLeft
        case bottom
        case bottomRight
        case fill
    }
    
    enum Transition {
        case slideFromTop
        case slideFromLeft
        case slideFromRight
        case slideFromBottom
    }
    
    struct Data {
        
        public var inset: QInset
        public var alignment: Alignment
        public var item: QLayoutItem?
        public var view: IQView? {
            set(value) { self.item = value.flatMap({ QLayoutItem(view: $0) }) }
            get { return self.item?.view }
        }
        
        public init(
            inset: QInset = .zero,
            alignment: Alignment = .topLeft,
            item: QLayoutItem? = nil
        ) {
            self.inset = inset
            self.alignment = alignment
            self.item = item
        }
        
        public init(
            inset: QInset = .zero,
            alignment: Alignment = .topLeft,
            view: IQView
        ) {
            self.inset = inset
            self.alignment = alignment
            self.item = QLayoutItem(view: view)
        }
        
    }
    
}

private extension QStateLayout {
    
    enum InternalState : Equatable {
        case idle(state: State)
        case animation(transition: Transition, from: State, to: State, progress: Float)
        
        func contains(state: State) -> Bool {
            switch self {
            case .idle(let currentState): return currentState == state
            case .animation(_, let from, let to, _): return from == state || to == state
            }
        }
        
    }
    
}

private extension QStateLayout {
    
    @inline(__always)
    func _data(state: State, update: (_ data: inout Data) -> Void) {
        if var data = self.data[state] {
            update(&data)
            self.data[state] = data
        } else {
            var data = Data()
            update(&data)
            self.data[state] = data
        }
    }
    
    @inline(__always)
    func _fromBeginBounds(bounds: QRect, transition: Transition) -> QRect {
        return bounds
    }
    
    @inline(__always)
    func _fromEndBounds(bounds: QRect, transition: Transition) -> QRect {
        switch transition {
        case .slideFromTop: return QRect(topLeft: bounds.bottomLeft, size: bounds.size)
        case .slideFromLeft: return QRect(topLeft: bounds.topRight, size: bounds.size)
        case .slideFromRight: return QRect(topRight: bounds.topLeft, size: bounds.size)
        case .slideFromBottom: return QRect(bottomLeft: bounds.topLeft, size: bounds.size)
        }
    }
    
    @inline(__always)
    func _toBeginBounds(bounds: QRect, transition: Transition) -> QRect {
        switch transition {
        case .slideFromTop: return QRect(bottomLeft: bounds.topLeft, size: bounds.size)
        case .slideFromLeft: return QRect(topRight: bounds.topLeft, size: bounds.size)
        case .slideFromRight: return QRect(topLeft: bounds.topRight, size: bounds.size)
        case .slideFromBottom: return QRect(topLeft: bounds.bottomLeft, size: bounds.size)
        }
    }
    
    @inline(__always)
    func _toEndBounds(bounds: QRect, transition: Transition) -> QRect {
        return bounds
    }
    
    @inline(__always)
    func _layout(bounds: QRect, state: State) -> QSize {
        guard let data = self.data[state] else { return .zero }
        guard let item = data.item else { return .zero }
        let availableBounds = bounds.apply(inset: data.inset)
        switch data.alignment {
        case .topLeft:
            let size = item.size(available: availableBounds.size)
            item.frame = QRect(topLeft: availableBounds.topLeft, size: size)
            return size
        case .top:
            let size = item.size(available: availableBounds.size)
            item.frame = QRect(top: availableBounds.top, size: size)
            return size
        case .topRight:
            let size = item.size(available: availableBounds.size)
            item.frame = QRect(topRight: availableBounds.topRight, size: size)
            return size
        case .left:
            let size = item.size(available: availableBounds.size)
            item.frame = QRect(left: availableBounds.left, size: size)
            return size
        case .center:
            let size = item.size(available: availableBounds.size)
            item.frame = QRect(center: availableBounds.center, size: size)
            return size
        case .right:
            let size = item.size(available: availableBounds.size)
            item.frame = QRect(right: availableBounds.right, size: size)
            return size
        case .bottomLeft:
            let size = item.size(available: availableBounds.size)
            item.frame = QRect(bottomLeft: availableBounds.bottomLeft, size: size)
            return size
        case .bottom:
            let size = item.size(available: availableBounds.size)
            item.frame = QRect(bottom: availableBounds.bottom, size: size)
            return size
        case .bottomRight:
            let size = item.size(available: availableBounds.size)
            item.frame = QRect(bottomRight: availableBounds.bottomRight, size: size)
            return size
        case .fill:
            item.frame = availableBounds
            return availableBounds.size
        }
    }
    
    @inline(__always)
    func _size(available: QSize, state: State) -> QSize {
        guard let data = self.data[state] else { return .zero }
        guard let item = data.item else { return .zero }
        let availableSize = available.apply(inset: data.inset)
        switch data.alignment {
        case .topLeft, .top, .topRight, .left, .center, .right, .bottomLeft, .bottom, .bottomRight:
            let size = item.size(available: availableSize)
            return size.apply(inset: -data.inset)
        case .fill:
            return availableSize
        }
    }
    
}
