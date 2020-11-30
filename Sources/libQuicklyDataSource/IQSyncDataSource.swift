//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQSyncDataSource : IQDataSource {
    
    var isNeedSync: Bool { get }
    var isSyncing: Bool { get }
    var syncAt: Date? { get }
    
    func setNeedSync()
    func syncIfNeeded()
    
}

public extension IQSyncDataSource {
    
    var isNeedSync: Bool {
        return self.syncAt == nil
    }
    
}
