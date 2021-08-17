//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQSimpleParamsActionDataLoader {
    
    associatedtype Params
    associatedtype Error
    
    typealias Success = () -> Void
    typealias Failure = (_ error: Error) -> Void
    
    func shouldPerform() -> Bool
    
    func perform(params: Params, success: @escaping Success, failure: @escaping Failure) -> IQCancellable
    
    mutating func didPerform()
    mutating func didPerform(error: Error)
    
}

public extension IQSimpleParamsActionDataLoader {
    
    func shouldPerform() -> Bool {
        return true
    }
    
    func didPerform() {
    }

    func didPerform(error: Error) {
    }

}

open class QSimpleParamsActionDataSource< Loader : IQSimpleParamsActionDataLoader > : IQSimpleParamsActionDataSource, IQCancellable {
    
    public typealias Params = Loader.Params
    public typealias Error = Loader.Error
    
    public var loader: Loader
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
            success: { [unowned self] in self._didPerform() },
            failure: { [unowned self] error in self._didPerform(error: error) }
        )
    }
    
    public func cancel() {
        self._query?.cancel()
        self._query = nil
    }
    
    open func willPerform() {
    }

    open func didPerform() {
    }

    open func didPerform(error: Error) {
    }

}

private extension QSimpleParamsActionDataSource {

    func _didPerform() {
        self._query = nil
        self.error = nil
        self.loader.didPerform()
        self.didPerform()
    }

    func _didPerform(error: Error) {
        self._query = nil
        self.error = error
        self.loader.didPerform(error: error)
        self.didPerform(error: error)
    }
    
}
