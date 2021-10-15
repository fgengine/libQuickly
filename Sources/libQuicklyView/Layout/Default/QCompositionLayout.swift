//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public protocol IQCompositionLayoutEntity {
    
    var items: [QLayoutItem] { get }
    
    @discardableResult
    func layout(bounds: QRect) -> QSize
    
    func size(available: QSize) -> QSize
    
    
}

public class QCompositionLayout : IQLayout {
    
    public unowned var delegate: IQLayoutDelegate?
    public unowned var view: IQView?
    public var inset: QInset {
        didSet(oldValue) {
            guard self.inset != oldValue else { return }
            self.setNeedForceUpdate()
        }
    }
    public var entity: IQCompositionLayoutEntity {
        didSet { self.setNeedForceUpdate() }
    }

    public init(
        inset: QInset = .zero,
        entity: IQCompositionLayoutEntity
    ) {
        self.inset = inset
        self.entity = entity
    }
    
    @discardableResult
    public func layout(bounds: QRect) -> QSize {
        let size = self.entity.layout(
            bounds: bounds.apply(inset: self.inset)
        )
        return size.apply(inset: -self.inset)
    }
    
    public func size(available: QSize) -> QSize {
        let size = self.entity.size(
            available: available.apply(inset: self.inset)
        )
        return size.apply(inset: -self.inset)
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        return self.entity.items
    }
    
}
