//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQDataSource {
    
    associatedtype Error
    
    var error: Error? { get }
    
}
