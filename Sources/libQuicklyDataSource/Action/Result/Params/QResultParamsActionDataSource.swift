//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQResultParamsActionDataLoader {
    
    associatedtype Params
    associatedtype Result
    associatedtype Error
    
    func shouldPerform() -> Bool
    
    func perform(params: Params, success: @escaping (_ result: Result) -> Void, failure: @escaping (_ error: Error) -> Void) -> IQCancellable
    
    mutating func didPerform(result: Result)
    
    mutating func didPerform(error: Error)
    
}

public extension IQResultParamsActionDataLoader {
    
    func shouldPerform() -> Bool {
        return true
    }
    
    func didPerform(result: Result) {
    }

    func didPerform(error: Error) {
    }

}

open class QResultParamsActionDataSource< Loader : IQResultParamsActionDataLoader > : IQResultParamsActionDataSource {
    
    public typealias Params = Loader.Params
    public typealias Result = Loader.Result
    public typealias Error = Loader.Error
    
    public var loader: Loader
    public private(set) var result: Result?
    public private(set) var error: Error?
    public var isPerforming: Bool {
        return self._query != nil
    }
    
    private var _query: IQCancellable?
    
    public init(loader: Loader) {
        self.loader = loader
    }
    
    deinit {
        self.cancel()
    }

    public func perform(_ params: Params) {
        guard self.isPerforming == false else { return }
        guard self.loader.shouldPerform() == true else { return }
        self.willPerform()
        self._query = self.loader.perform(
            params: params,
            success: { [unowned self] result in self._didPerform(result: result) },
            failure: { [unowned self] error in self._didPerform(error: error) }
        )
    }
    
    public func cancel() {
        self._query?.cancel()
        self._query = nil
    }
    
    open func willPerform() {
    }

    open func didPerform(result: Result) {
    }

    open func didPerform(error: Error) {
    }

}

private extension QResultParamsActionDataSource {

    func _didPerform(result: Result) {
        self._query = nil
        self.result = result
        self.loader.didPerform(result: result)
        self.didPerform(result: result)
    }

    func _didPerform(error: Error) {
        self._query = nil
        self.error = error
        self.loader.didPerform(error: error)
        self.didPerform(error: error)
    }
    
}
