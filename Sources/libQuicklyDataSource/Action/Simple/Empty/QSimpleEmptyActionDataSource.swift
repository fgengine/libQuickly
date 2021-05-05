//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQSimpleEmptyActionDataLoader {
    
    associatedtype Error
    
    mutating func perform(
        success: @escaping () -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) -> IQCancellable
    
    mutating func didPerform()
    mutating func didPerform(error: Error)
    
}

public extension IQSimpleEmptyActionDataLoader {
    
    func didPerform() {
    }

    func didPerform(error: Error) {
    }

}

open class QSimpleEmptyActionDataSource< Loader : IQSimpleEmptyActionDataLoader > : IQSimpleEmptyActionDataSource {
    
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

    public func perform() {
        guard self.isPerforming == false else { return }
        self._query = self._loader.perform(
            success: { [unowned self] in self._didPerform() },
            failure: { [unowned self] error in self._didPerform(error: error) }
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

private extension QSimpleEmptyActionDataSource {

    func _didPerform() {
        self._query = nil
        self._loader.didPerform()
        self.didPerform()
    }

    func _didPerform(error: Error) {
        self._query = nil
        self.error = error
        self._loader.didPerform(error: error)
        self.didPerform(error: error)
    }
    
}
