//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public final class QListLayout : IQLayout {
    
    public unowned var delegate: IQLayoutDelegate?
    public unowned var parentView: IQView?
    public var direction: Direction {
        didSet(oldValue) {
            guard self.direction != oldValue else { return }
            self.invalidate()
            self.setNeedUpdate()
        }
    }
    public var inset: QInset {
        didSet(oldValue) {
            guard self.inset != oldValue else { return }
            self.setNeedUpdate()
        }
    }
    public var spacing: QFloat {
        didSet(oldValue) {
            guard self.spacing != oldValue else { return }
            self.setNeedUpdate()
        }
    }
    public var items: [QLayoutItem] {
        didSet {
            self.invalidate()
            self.setNeedUpdate()
        }
    }
    public var views: [IQView] {
        set(value) { self.items = value.compactMap({ return QLayoutItem(view: $0) }) }
        get { return self.items.compactMap({ $0.view }) }
    }
    
    private var _cache: [Int : QSize]

    public init(
        direction: Direction,
        inset: QInset = QInset(),
        spacing: QFloat = 0,
        items: [QLayoutItem]
    ) {
        self.direction = direction
        self.inset = inset
        self.spacing = spacing
        self.items = items
        self._cache = [:]
    }

    public convenience init(
        direction: Direction,
        inset: QInset = QInset(),
        spacing: QFloat = 0,
        views: [IQView]
    ) {
        self.init(
            direction: direction,
            inset: inset,
            spacing: spacing,
            items: views.compactMap({ return QLayoutItem(view: $0) })
        )
    }
    
    public func invalidate() {
        self._cache.removeAll()
    }
    
    public func layout(bounds: QRect) -> QSize {
        return QStackLayoutHelper.layout(
            bounds: bounds,
            direction: QStackLayoutHelper.Direction(self.direction),
            origin: .forward,
            alignment: .fill,
            inset: self.inset,
            spacing: self.spacing,
            items: self.items,
            sizeCache: &self._cache
        )
    }
    
    public func size(_ available: QSize) -> QSize {
        return QStackLayoutHelper.size(
            available: available,
            direction: QStackLayoutHelper.Direction(self.direction),
            inset: self.inset,
            spacing: self.spacing,
            items: self.items
        )
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return self.visible(items: self.items, for: bounds)
    }
    
}

public extension QListLayout {
    
    enum Direction {
        case horizontal
        case vertical
    }
    
}

fileprivate extension QStackLayoutHelper.Direction {
    
    @inline(__always)
    init(_ direction: QListLayout.Direction) {
        switch direction {
        case .horizontal: self = .horizontal
        case .vertical: self = .vertical
        }
    }
    
}
