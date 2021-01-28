//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public final class QListLayout : IQLayout {
    
    public weak var delegate: IQLayoutDelegate?
    public weak var parentView: IQView?
    public private(set) var mode: Mode
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
    public var items: [IQLayoutItem] {
        didSet(oldValue) {
            self.setNeedUpdate()
        }
    }
    public var views: [IQView] {
        set(value) { self.items = value.compactMap({ return QLayoutItem(view: $0) }) }
        get { return self.items.compactMap({ $0.view }) }
    }

    public init(
        mode: Mode,
        inset: QInset = QInset(),
        spacing: QFloat = 0,
        items: [IQLayoutItem]
    ) {
        self.mode = mode
        self.inset = inset
        self.spacing = spacing
        self.items = items
    }

    public convenience init(
        mode: Mode,
        inset: QInset = QInset(),
        spacing: QFloat = 0,
        views: [IQView]
    ) {
        self.init(
            mode: mode,
            inset: inset,
            spacing: spacing,
            items: views.compactMap({ return QLayoutItem(view: $0) })
        )
    }
    
    public func layout(bounds: QRect) -> QSize {
        switch self.mode {
        case .horizontal: return self.items.horizontalLayout(bounds: bounds, inset: self.inset, spacing: self.spacing)
        case .vertical: return self.items.verticalLayout(bounds: bounds, inset: self.inset, spacing: self.spacing)
        }
    }
    
    public func size(_ available: QSize) -> QSize {
        guard self.items.count > 0 else { return QSize() }
        switch self.mode {
        case .horizontal: return self.items.horizontalSize(available: available, inset: self.inset, spacing: self.spacing)
        case .vertical: return self.items.verticalSize(available: available, inset: self.inset, spacing: self.spacing)
        }
    }
    
    public func items(bounds: QRect) -> [IQLayoutItem] {
        return self.visible(items: self.items, for: bounds)
    }
    
}

public extension QListLayout {
    
    enum Mode {
        case horizontal
        case vertical
    }
    
}
