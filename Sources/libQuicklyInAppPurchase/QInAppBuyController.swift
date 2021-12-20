//
//  libQuicklyInAppStore
//

import Foundation
import StoreKit
import TPInAppReceipt
import libQuicklyCore
import libQuicklyObserver

public protocol IQInAppBuyControllerObserver : AnyObject {
    
    func didPurchasing(_ controller: QInAppBuyController)
    func didPurchased(_ controller: QInAppBuyController)
    func didDeferred(_ controller: QInAppBuyController)
    func didFailure(_ controller: QInAppBuyController, error: Error)
    func didCancelled(_ controller: QInAppBuyController)
    
}

public class QInAppBuyController {
    
    public let purchase: QInAppPurchase
    public let options: QInAppPayment.Options
    public private(set) var isLoading: Bool
    public private(set) var isBuying: Bool
    
    private var _observer: QObserver< IQInAppBuyControllerObserver >

    public init(
        purchase: QInAppPurchase,
        options: QInAppPayment.Options
    ) {
        self.purchase = purchase
        self.options = options
        self.isLoading = false
        self.isBuying = false
        self._observer = QObserver()
        self._subscribe()
    }
    
    deinit {
        self._unsubscribe()
    }
    
    public func add(observer: IQInAppBuyControllerObserver, priority: QObserverPriority) {
        self._observer.add(observer, priority: priority)
    }
    
    public func remove(observer: IQInAppBuyControllerObserver) {
        self._observer.remove(observer)
    }
    
    public func buy() {
        guard self.isLoading == false && self.isBuying == false else { return }
        if let product = self.purchase.product {
            self._buy(product: product)
        } else {
            self._load()
        }
    }
    
}

private extension QInAppBuyController {
    
    func _subscribe() {
        self.purchase.add(observer: self, priority: .utility)
    }
    
    func _unsubscribe() {
        self.purchase.remove(observer: self)
    }
    
    func _load() {
        self.isLoading = true
        self.purchase.load()
    }
    
    func _buy(product: QInAppProduct) {
        self.isBuying = true
        self.purchase.buy(
            product: product,
            options: self.options
        )
    }
    
}

extension QInAppBuyController : IQInAppPurchaseObserver {
    
    public func didUpdate(_ purchase: QInAppPurchase) {
        if self.isLoading == true {
            if let product = self.purchase.product {
                self.isLoading = false
                self._buy(product: product)
            }
        } else if self.isBuying == true {
            if let payment = self.purchase.payment {
                switch payment.status {
                case .unknown: break
                case .purchasing:
                    self._observer.notify({ $0.didPurchasing(self) })
                case .purchased:
                    switch self.purchase.status {
                    case .unknown, .empty:
                        break
                    case .piece, .subcription:
                        self.isBuying = false
                        self._observer.notify({ $0.didPurchased(self) })
                    }
                case .deferred:
                    self.isBuying = false
                    self._observer.notify({ $0.didDeferred(self) })
                case .failure(let error):
                    self.isBuying = false
                    self._observer.notify({ $0.didFailure(self, error: error) })
                case .cancelled:
                    self.isBuying = false
                    self._observer.notify({ $0.didCancelled(self) })
                }
            }
        }
    }
    
}
