//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQSyncDataSource : IQDataSource {
    
    associatedtype Result
    
    var result: Result? { get }
    var isSyncing: Bool { get }
    var isNeedSync: Bool { get }
    var syncAt: Date? { get }
    
    func setNeedSync(reset: Bool)
    func syncIfNeeded()
    
}

public extension IQSyncDataSource {
    
    func setNeedSync(reset: Bool = false) {
        self.setNeedSync(reset: reset)
    }
    
}
