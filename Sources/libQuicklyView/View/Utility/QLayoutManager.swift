//
//  libQuicklyView
//

import Foundation
import libQuicklyCore
#if os(iOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

struct QLayoutManager {
    
    unowned let contentView: QNativeView
    var layout: IQLayout?
    var size: QSize
    var items: [QLayoutItem]

    @inline(__always)
    init(contentView: QNativeView) {
        self.contentView = contentView
        self.size = QSize()
        self.items = []
    }
    
    @inline(__always)
    mutating func layout(bounds: QRect) {
        if let layout = self.layout {
            self.size = layout.layout(bounds: bounds)
        } else {
            self.size = QSize()
        }
    }
    
    @inline(__always)
    mutating func visible(bounds: QRect) {
        if let layout = self.layout {
            let visible = layout.items(bounds: bounds)
            let unvisible = self.items.filter({ item in
                return visible.contains(where: { return item === $0 }) == false
            })
            for item in unvisible {
                self._disappear(view: item.view)
            }
            if self.size.width > 0 || self.size.height > 0 {
                for item in visible {
                    item.view.native.frame = item.frame.cgRect
                    self._appear(view: item.view, layout: layout)
                }
            }
            self.items = visible
        } else {
            self.clear()
        }
    }
    
    @inline(__always)
    mutating func clear() {
        for item in self.items {
            self._disappear(view: item.view)
        }
        self.items.removeAll()
    }
    
    @inline(__always)
    func setNeedUpdate(_ isResized: Bool = false) {
        self.layout?.setNeedUpdate(isResized)
    }
    
    @inline(__always)
    func updateIfNeeded() {
        self.layout?.updateIfNeeded()
    }
    
}

private extension QLayoutManager {
    
    @inline(__always)
    func _appear(view: IQView, layout: IQLayout) {
        self.contentView.addSubview(view.native)
        if view.isAppeared == false {
            view.appear(to: layout)
        }
    }
    
    @inline(__always)
    func _disappear(view: IQView) {
        view.native.removeFromSuperview()
        if view.isAppeared == true {
            view.disappear()
        }
    }
    
}
