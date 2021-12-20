//
//  libQuicklyInAppStore
//

import Foundation
import StoreKit
import TPInAppReceipt
import libQuicklyCore
import libQuicklyObserver

public protocol IQInAppProductsControllerObserver : AnyObject {
    
    func didFinish(_ controller: QInAppProductsController)
    
}

public class QInAppProductsController {
    
    public let purchases: [QInAppPurchase]
    public var isNeedLoading: Bool {
        let count = self.purchases.count(where: {
            guard let product = $0.product else { return true }
            switch product.status {
            case .unknown, .failure: return true
            default: return false
            }
        })
        return count > 0
    }
    public private(set) var isLoading: Bool
    public var isLoaded: Bool {
        let count = self.purchases.count(where: {
            guard let product = $0.product else { return false }
            switch product.status {
            case .success, .failure, .missing: return true
            default: return false
            }
        })
        return count == self.purchases.count
    }
    
    private var _observer: QObserver< IQInAppProductsControllerObserver >

    public init(
        purchases: [QInAppPurchase]
    ) {
        self.purchases = purchases
        self.isLoading = false
        self._observer = QObserver()
        self._subscribe()
    }
    
    deinit {
        self._unsubscribe()
    }
    
    public func add(observer: IQInAppProductsControllerObserver, priority: QObserverPriority) {
        self._observer.add(observer, priority: priority)
    }
    
    public func remove(observer: IQInAppProductsControllerObserver) {
        self._observer.remove(observer)
    }
    
    public func load() {
        guard self.isLoading == false && self.isNeedLoading == true else { return }
        self.isLoading = true
        for purchases in self.purchases {
            purchases.load()
        }
    }
    
}

private extension QInAppProductsController {
    
    func _subscribe() {
        for purchase in self.purchases {
            purchase.add(observer: self, priority: .utility)
        }
    }
    
    func _unsubscribe() {
        for purchase in self.purchases {
            purchase.remove(observer: self)
        }
    }
    
}

extension QInAppProductsController : IQInAppPurchaseObserver {
    
    public func didUpdate(_ purchase: QInAppPurchase) {
        guard self.isLoading == true else { return }
        if self.isLoaded == true {
            if self.isNeedLoading == true {
                for purchases in self.purchases {
                    purchases.load()
                }
            } else {
                self.isLoading = false
                self._observer.notify({ $0.didFinish(self) })
            }
        }
    }
    
}
