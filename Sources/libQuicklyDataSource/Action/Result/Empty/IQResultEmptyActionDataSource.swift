//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQResultEmptyActionDataSource : IQActionDataSource {
    
    associatedtype Result
    
    var result: Result? { get }
    
    func perform()
    
}
