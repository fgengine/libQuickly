//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct VAccessory {
        
        public var leading: IQCompositionLayoutEntity?
        public var center: IQCompositionLayoutEntity
        public var trailing: IQCompositionLayoutEntity?
        public var filling: Bool
        
        public init(
            leading: IQCompositionLayoutEntity? = nil,
            center: IQCompositionLayoutEntity,
            trailing: IQCompositionLayoutEntity? = nil,
            filling: Bool
        ) {
            self.leading = leading
            self.center = center
            self.trailing = trailing
            self.filling = filling
        }
        
    }
    
}

extension QCompositionLayout.VAccessory : IQCompositionLayoutEntity {
    
    public func invalidate(item: QLayoutItem) {
        self.leading?.invalidate(item: item)
        self.center.invalidate(item: item)
        self.trailing?.invalidate(item: item)
    }
    
    @discardableResult
    public func layout(bounds: QRect) -> QSize {
        let leadingSize: QSize
        if let leading = self.leading {
            leadingSize = leading.size(available: bounds.size)
        } else {
            leadingSize = .zero
        }
        let trailingSize: QSize
        if let trailing = self.trailing {
            trailingSize = trailing.size(available: bounds.size)
        } else {
            trailingSize = .zero
        }
        let centerSize = self.center.size(available: QSize(
            width: max(leadingSize.width, bounds.width, trailingSize.width),
            height: bounds.height - (leadingSize.height + trailingSize.height)
        ))
        let base = QRect(
            x: bounds.x,
            y: bounds.y,
            width: max(leadingSize.width, centerSize.width, trailingSize.width),
            height: bounds.height
        )
        if let leading = self.leading {
            leading.layout(bounds: QRect(
                topLeft: base.topLeft,
                width: base.width,
                height: leadingSize.height
            ))
        }
        if let trailing = self.trailing {
            trailing.layout(bounds: QRect(
                bottomLeft: base.bottomLeft,
                width: base.width,
                height: trailingSize.height
            ))
        }
        if self.filling == true {
            self.center.layout(bounds: QRect(
                x: base.x,
                y: base.y + leadingSize.height,
                width: base.width,
                height: base.height - (leadingSize.height + trailingSize.height)
            ))
        } else {
            self.center.layout(bounds: QRect(
                center: base.center,
                width: base.width,
                height: bounds.height - (max(leadingSize.height, trailingSize.height) * 2)
            ))
        }
        return base.size
    }
    
    public func size(available: QSize) -> QSize {
        let leadingSize: QSize
        if let leading = self.leading {
            leadingSize = leading.size(available: available)
        } else {
            leadingSize = .zero
        }
        let trailingSize: QSize
        if let trailing = self.trailing {
            trailingSize = trailing.size(available: available)
        } else {
            trailingSize = .zero
        }
        let centerSize = self.center.size(available: QSize(
            width: max(leadingSize.width, available.width, trailingSize.width),
            height: available.height - (leadingSize.height + trailingSize.height)
        ))
        return QSize(
            width: max(leadingSize.width, centerSize.width, trailingSize.width),
            height: available.height
        )
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        var items: [QLayoutItem] = []
        if let leading = self.leading {
            items.append(contentsOf: leading.items(bounds: bounds))
        }
        if let trailing = self.trailing {
            items.append(contentsOf: trailing.items(bounds: bounds))
        }
        items.append(contentsOf: self.center.items(bounds: bounds))
        return items
    }
    
}
