//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QStateLayout< State : Hashable > : IQLayout {
    
    public unowned var delegate: IQLayoutDelegate?
    public unowned var view: IQView?
    public var state: State {
        didSet(oldValue) {
            guard self.state != oldValue else { return }
            self.setNeedForceUpdate()
        }
    }
    public var insets: [State : QInset] {
        return self._insets
    }
    public var alignments: [State : Alignment] {
        return self._alignments
    }
    public var items: [State : QLayoutItem] {
        return self._items
    }
    
    private var _insets: [State : QInset]
    private var _alignments: [State : Alignment]
    private var _items: [State : QLayoutItem]

    public init(
        state: State,
        insets: [State : QInset] = [:],
        alignments: [State : Alignment] = [:],
        items: [State : QLayoutItem]
    ) {
        self.state = state
        self._insets = insets
        self._alignments = alignments
        self._items = items
    }
    
    public convenience init(
        state: State,
        insets: [State : QInset] = [:],
        alignments: [State : Alignment] = [:],
        views: [State : IQView]
    ) {
        self.init(
            state: state,
            insets: insets,
            alignments: alignments,
            items: views.compactMapValues({ QLayoutItem(view: $0) })
        )
    }
    
    public func set(state: State, inset: QInset?) {
        self._insets[state] = inset
        if self.state == state {
            self.setNeedForceUpdate()
        }
    }
    
    public func get(state: State) -> QInset? {
        return self._insets[state]
    }
    
    public func set(state: State, alignment: Alignment?) {
        self._alignments[state] = alignment
        if self.state == state {
            self.setNeedForceUpdate()
        }
    }
    
    public func get(state: State) -> Alignment? {
        return self._alignments[state]
    }
    
    public func set(state: State, view: IQView?) {
        self._items[state] = view.flatMap({ QLayoutItem(view: $0) })
        if self.state == state {
            self.setNeedForceUpdate()
        }
    }
    
    public func get(state: State) -> IQView? {
        return self._items[state].flatMap({ $0.view })
    }
    
    public func layout(bounds: QRect) -> QSize {
        guard let item = self._items[self.state] else { return .zero }
        let inset = self._insets[self.state] ?? .zero
        let alignment = self._alignments[self.state] ?? .topLeft
        let availableBounds = bounds.apply(inset: inset)
        let itemSize = item.size(availableBounds.size)
        switch alignment {
        case .topLeft:
            item.frame = QRect(topLeft: availableBounds.topLeft, size: itemSize)
        case .top:
            item.frame = QRect(top: availableBounds.top, size: itemSize)
        case .topRight:
            item.frame = QRect(topRight: availableBounds.topRight, size: itemSize)
        case .left:
            item.frame = QRect(left: availableBounds.left, size: itemSize)
        case .center:
            item.frame = QRect(center: availableBounds.center, size: itemSize)
        case .right:
            item.frame = QRect(right: availableBounds.right, size: itemSize)
        case .bottomLeft:
            item.frame = QRect(bottomLeft: availableBounds.bottomLeft, size: itemSize)
        case .bottom:
            item.frame = QRect(bottom: availableBounds.bottom, size: itemSize)
        case .bottomRight:
            item.frame = QRect(bottomRight: availableBounds.bottomRight, size: itemSize)
        }
        return bounds.size
    }
    
    public func size(_ available: QSize) -> QSize {
        guard let item = self._items[self.state] else { return .zero }
        let inset = self._insets[self.state] ?? .zero
        let availableSize = available.apply(inset: inset)
        let size = item.size(availableSize)
        return size.apply(inset: -inset)
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        guard let item = self._items[self.state] else { return [] }
        return [ item ]
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
    }
    
}
