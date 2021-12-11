//
//  libQuicklyInAppStore
//

import Foundation
import StoreKit
import TPInAppReceipt
import libQuicklyCore
import libQuicklyObserver

public protocol IQInAppRestorePurchaseObserver : AnyObject {
    
    func didFinish(_ restorePurchase: QInAppRestorePurchase, purchases: [QInAppPurchase], error: Error?)
    
}

public class QInAppRestorePurchase {
    
    private var _observer: QObserver< IQInAppRestorePurchaseObserver >
    private var _purchases: [QInAppPurchase]

    public init() {
        self._observer = QObserver()
        self._purchases = []
        QInAppManager.shared.register(self)
    }
    
    deinit {
        QInAppManager.shared.unregister(self)
    }
    
    public func add(observer: IQInAppRestorePurchaseObserver, priority: QObserverPriority) {
        self._observer.add(observer, priority: priority)
    }
    
    public func remove(observer: IQInAppRestorePurchaseObserver) {
        self._observer.remove(observer)
    }
    
    public func restore(
        applicationUsername: String? = nil
    ) {
        QInAppManager.shared.restore(
            applicationUsername: applicationUsername
        )
    }
    
}

extension QInAppRestorePurchase {
    
    func restore(purchase: QInAppPurchase) {
        if self._purchases.contains(where: { $0.id == purchase.id }) == false {
            self._purchases.append(purchase)
        }
    }
    
    func finish(error: Error?) {
        self._observer.notify({ $0.didFinish(self, purchases: self._purchases, error: error) })
        self._purchases.removeAll()
    }
    
}
