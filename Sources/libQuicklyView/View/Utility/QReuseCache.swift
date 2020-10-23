//
//  libQuicklyView
//

import Foundation

public protocol IQReusable {
    
    associatedtype View
    associatedtype Item: QNativeView
    
    static var reuseIdentificator: String { get }
    
    static func createReuseItem(view: View) -> Item
    static func configureReuseItem(view: View, item: Item)
    static func cleanupReuseItem(view: View, item: Item)
    
}

public final class QReuseCache {
    
    public static let shared: QReuseCache = QReuseCache()
    
    private var _items: [String : [Any]]
    
    fileprivate init() {
        self._items = [:]
    }
    
    public func set< Reusable: IQReusable >(_ reusable: Reusable.Type, view: Reusable.View, item: Reusable.Item) {
        let identificator = reusable.reuseIdentificator
        if let items = self._items[identificator] {
            self._items[identificator] = items + [ item ]
        } else {
            self._items[identificator] = [ item ]
        }
        reusable.cleanupReuseItem(view: view, item: item)
    }
    
    public func get< Reusable: IQReusable >(_ reusable: Reusable.Type, view: Reusable.View) -> Reusable.Item {
        let identificator = Reusable.reuseIdentificator
        let item: Reusable.Item
        if let items = self._items[identificator] {
            if let lastItem = items.last as? Reusable.Item {
                self._items[identificator] = items.dropLast()
                item = lastItem
            } else {
                item = reusable.createReuseItem(view: view)
            }
        } else {
            item = reusable.createReuseItem(view: view)
        }
        reusable.configureReuseItem(view: view, item: item)
        return item
    }
    
}
