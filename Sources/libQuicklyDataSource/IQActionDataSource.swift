//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQActionDataSource : IQDataSource {
    
    var isPerforming: Bool { get }
    
}
