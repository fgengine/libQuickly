//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public enum QDataSourceObserverPriority : UInt {
    case `internal`
    case userInterface
}

public protocol IQDataSource : AnyObject {
    
    associatedtype Success
    associatedtype Failure
    associatedtype Observer
    
    var result: Success? { get }
    var error: Failure? { get }
    
    func add(observer: Observer, priority: QDataSourceObserverPriority)
    func remove(observer: Observer)
    
    func cancel()
    
}
