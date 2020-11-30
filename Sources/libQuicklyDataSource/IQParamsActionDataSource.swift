//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQParamsActionDataSource : IQActionDataSource {
    
    associatedtype Params

    func perform(_ params: Params)
    
}
