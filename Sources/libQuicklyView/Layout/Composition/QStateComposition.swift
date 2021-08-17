//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QStateComposition< State : Hashable > : IQLayout {
    
    public unowned var delegate: IQLayoutDelegate?
    public unowned var view: IQView?
    public var state: State {
        didSet { self.setNeedForceUpdate() }
    }
    public var inset: QInset {
        didSet { self.setNeedForceUpdate() }
    }
    public private(set) var items: [State : QLayoutItem] {
        didSet { self.setNeedForceUpdate() }
    }

    public init(
        state: State,
        inset: QInset,
        items: [State : QLayoutItem]
    ) {
        self.state = state
        self.inset = inset
        self.items = items
    }
    
    public convenience init(
        state: State,
        inset: QInset,
        views: [State : IQView]
    ) {
        self.init(
            state: state,
            inset: inset,
            items: views.compactMapValues({ QLayoutItem(view: $0) })
        )
    }
    
    public func set(state: State, view: IQView?) {
        self.items[state] = view.flatMap({ QLayoutItem(view: $0) })
    }
    
    public func get(state: State) -> IQView? {
        guard let item = self.items[state] else { return nil }
        return item.view
    }
    
    public func layout(bounds: QRect) -> QSize {
        guard let item = self.items[self.state] else { return .zero }
        let availableSize = bounds.size.apply(inset: self.inset)
        let size = item.size(availableSize)
        item.frame = QRect(
            x: bounds.origin.x + self.inset.left,
            y: bounds.origin.y + self.inset.top,
            width: size.width,
            height: size.height
        )
        return size.apply(inset: -self.inset)
    }
    
    public func size(_ available: QSize) -> QSize {
        guard let item = self.items[self.state] else { return .zero }
        let availableSize = available.apply(inset: self.inset)
        let size = item.size(availableSize)
        return size.apply(inset: -self.inset)
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        guard let item = self.items[self.state] else { return [] }
        return [ item ]
    }
    
}
