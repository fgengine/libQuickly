//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQSyncDataLoader {
    
    associatedtype Result
    associatedtype Error
    
    mutating func perform(
        success: @escaping (_ result: Result) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) -> IQCancellable
    
    mutating func didPerform(result: Result)
    mutating func didPerform(error: Error)
    
}

public extension IQSyncDataLoader {
    
    func didPerform(result: Result) {
    }

    func didPerform(error: Error) {
    }

}

open class QSyncDataSource< Loader : IQSyncDataLoader > : IQSyncDataSource {
    
    public typealias Result = Loader.Result
    public typealias Error = Loader.Error
     
    public private(set) var result: Result?
    public private(set) var error: Error?
    public var isSyncing: Bool {
        return self._query != nil
    }
    public var isNeedSync: Bool {
        return self._syncAt == nil
    }
    
    private var _loader: Loader
    private var _query: IQCancellable?
    private var _syncAt: Date?
    
    public init(loader: Loader) {
        self._loader = loader
    }
    
    deinit {
        self.cancel()
    }
    
    public func setNeedSync() {
        self._syncAt = nil
    }
    
    public func syncIfNeeded() {
        guard self.isSyncing == false && self.isNeedSync == true else { return }
        self._query = self._loader.perform(
            success: { [unowned self] result in self._didSync(result: result) },
            failure: { [unowned self] error in self._didSync(error: error) }
        )
    }
    
    public func cancel() {
        self._query?.cancel()
        self._query = nil
    }

    open func didSync(result: Result) {
    }

    open func didSync(error: Error) {
    }

}

private extension QSyncDataSource {

    func _didSync(result: Result) {
        self._query = nil
        self.result = result
        self._syncAt = Date()
        self._loader.didPerform(result: result)
        self.didSync(result: result)
    }

    func _didSync(error: Error) {
        self._query = nil
        self.error = error
        self._loader.didPerform(error: error)
        self.didSync(error: error)
    }
    
}
