//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQResultParamsActionDataSource : IQActionDataSource {
    
    associatedtype Params
    associatedtype Result
    
    var result: Result? { get }

    func perform(_ params: Params)
    
}
