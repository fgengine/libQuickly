//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public extension QCompositionLayout {
    
    struct HAccessory : IQCompositionLayoutEntity {
        
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
                width: bounds.width - (leadingSize.width + trailingSize.width),
                height: max(leadingSize.height, bounds.height, trailingSize.height)
            ))
            let base = QRect(
                x: bounds.x,
                y: bounds.y,
                width: bounds.width,
                height: max(leadingSize.height, centerSize.height, trailingSize.height)
            )
            if let leading = self.leading {
                leading.layout(bounds: QRect(
                    topLeft: base.topLeft,
                    width: leadingSize.width,
                    height: base.height
                ))
            }
            if let trailing = self.trailing {
                trailing.layout(bounds: QRect(
                    topRight: base.topRight,
                    width: trailingSize.width,
                    height: base.height
                ))
            }
            if self.filling == true {
                self.center.layout(bounds: QRect(
                    x: base.x + leadingSize.width,
                    y: base.y,
                    width: base.width - (leadingSize.width + trailingSize.width),
                    height: base.height
                ))
            } else {
                self.center.layout(bounds: QRect(
                    center: base.center,
                    width: bounds.width - (max(leadingSize.width, trailingSize.width) * 2),
                    height: base.height
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
                width: available.width - (leadingSize.width + trailingSize.width),
                height: max(leadingSize.height, available.height, trailingSize.height)
            ))
            return QSize(
                width: available.width,
                height: max(leadingSize.height, centerSize.height, trailingSize.height)
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
    
}
