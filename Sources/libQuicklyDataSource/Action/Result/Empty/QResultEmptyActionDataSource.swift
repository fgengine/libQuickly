//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQResultEmptyActionDataLoader {
    
    associatedtype Result
    associatedtype Error
    
    func perform(
        success: @escaping (_ result: Result) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) -> IQCancellable
    
}

open class QResultEmptyActionDataSource< Loader : IQResultEmptyActionDataLoader > : IQResultEmptyActionDataSource {
    
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

    public func perform() {
        guard self.isPerforming == false else { return }
        self._query = self._loader.perform(
            success: { [weak self] result in self?._didPerform(result: result) },
            failure: { [weak self] error in self?._didPerform(error: error) }
        )
    }
    
    public func cancel() {
        self._query?.cancel()
        self._query = nil
    }

    open func didPerform() {
    }

    open func didPerform(error: Error) {
    }

}

private extension QResultEmptyActionDataSource {

    func _didPerform(result: Result) {
        self._query = nil
        self.result = result
        self.didPerform()
    }

    func _didPerform(error: Error) {
        self._query = nil
        self.error = error
        self.didPerform(error: error)
    }
    
}
