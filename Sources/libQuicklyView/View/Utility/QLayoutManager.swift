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
    unowned let delegate: IQLayoutDelegate
    var layout: IQLayout? {
        willSet(newValue) {
            self.layout?.delegate = nil
            self.clear()
        }
        didSet(oldValue) {
            self.layout?.delegate = self.delegate
        }
    }
    var size: QSize
    var items: [QLayoutItem]

    @inline(__always)
    init(contentView: QNativeView, delegate: IQLayoutDelegate) {
        self.contentView = contentView
        self.delegate = delegate
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
            let items = layout.items(bounds: bounds)
            let disappearing = self.items.filter({ item in
                return items.contains(where: { return item === $0 }) == false
            })
            if disappearing.count > 0 {
                for item in disappearing {
                    self._disappear(view: item.view)
                }
            }
            for (index, item) in items.enumerated() {
                item.view.native.frame = item.frame.cgRect
                if self.items.contains(where: { return item === $0 }) == false {
                    self.contentView.insertSubview(item.view.native, at: index)
                    item.view.appear(to: layout)
                }
            }
            self.items = items
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
    
}

private extension QLayoutManager {
    
    @inline(__always)
    func _disappear(view: IQView) {
        let native = view.native
        view.disappear()
        native.removeFromSuperview()
    }
    
}
