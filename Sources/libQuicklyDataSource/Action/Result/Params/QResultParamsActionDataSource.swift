//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQResultParamsActionDataLoader {
    
    associatedtype Params
    associatedtype Result
    associatedtype Error
    
    func perform(
        params: Params,
        success: @escaping (_ result: Result) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) -> IQCancellable
    
}

open class QResultParamsActionDataSource< Loader : IQResultParamsActionDataLoader > : IQResultParamsActionDataSource {
    
    public typealias Params = Loader.Params
    public typealias Result = Loader.Result
    public typealias Error = Loader.Error
    
    public private(set) var result: Result?
    public private(set) var error: Error?
    public var isPerforming: Bool {
        return self._query != nil
    }
    
    private var _loader: Loader
    private var _query: IQCancellable?
    
    public init(loader: Loader) {
        self._loader = loader
    }
    
    deinit {
        self.cancel()
    }

    public func perform(_ params: Params) {
        guard self.isPerforming == false else { return }
        self._query = self._loader.perform(
            params: params,
            success: { [weak self] result in self?._didPerform(result: result) },
            failure: { [weak self] error in self?._didPerform(error: error) }
        )
    }
    
    public func cancel() {
        self._query?.cancel()
        self._query = nil
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
        self.didPerform(result: result)
    }

    func _didPerform(error: Error) {
        self._query = nil
        self.error = error
        self.didPerform(error: error)
    }
    
}
