//
//  libQuicklyInAppStore
//

import Foundation
import StoreKit
import libQuicklyCore

public class QInAppPayment {
    
    public unowned let purchase: QInAppPurchase
    public let options: Options
    public private(set) var status: Status
    
    init(
        purchase: QInAppPurchase,
        options: Options
    ) {
        self.purchase = purchase
        self.options = options
        self.status = .unknown
    }
    
}

public extension QInAppPayment {

    enum Status {
        case unknown
        case purchasing
        case purchased
        case deferred
        case failure(_ error: Error)
        case cancelled
    }

}

public extension QInAppPayment {
    
    struct Options {
        
        public let quantity: Int
        public let applicationUsername: String?
        public let simulatesAskToBuyInSandbox: Bool
        
        public init(
            quantity: Int = 1,
            applicationUsername: String? = nil,
            simulatesAskToBuyInSandbox: Bool = false
        ) {
            self.quantity = quantity
            self.applicationUsername = applicationUsername
            self.simulatesAskToBuyInSandbox = simulatesAskToBuyInSandbox
        }
        
        init(
            payment: SKPayment
        ) {
            self.quantity = payment.quantity
            self.applicationUsername = payment.applicationUsername
            if #available(macOS 10.14, *) {
                self.simulatesAskToBuyInSandbox = payment.simulatesAskToBuyInSandbox
            } else {
                self.simulatesAskToBuyInSandbox = false
            }
        }
        
    }
    
}

public extension QInAppPayment {
    
    var error: Error? {
        switch self.status {
        case .failure(let error): return error
        default: return nil
        }
    }
    
}

extension QInAppPayment {
    
    func set(status: Status) {
        self.status = status
        self.purchase.didUpdate()
    }
    
}
