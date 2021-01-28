//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQSimpleParamsActionDataLoader {
    
    associatedtype Params
    associatedtype Error
    
    func perform(
        params: Params,
        success: @escaping () -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) -> IQCancellable
    
}

open class QSimpleParamsActionDataSource< Loader : IQSimpleParamsActionDataLoader > : IQSimpleParamsActionDataSource {
    
    public typealias Params = Loader.Params
    public typealias Error = Loader.Error
     
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
            success: { [weak self] in self?._didPerform() },
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

private extension QSimpleParamsActionDataSource {

    func _didPerform() {
        self._query = nil
        self.didPerform()
    }

    func _didPerform(error: Error) {
        self._query = nil
        self.error = error
        self.didPerform(error: error)
    }
    
}
