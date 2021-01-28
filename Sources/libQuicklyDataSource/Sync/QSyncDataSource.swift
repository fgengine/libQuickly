//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQSyncDataLoader {
    
    associatedtype Result
    associatedtype Error
    
    func perform(
        success: @escaping (_ result: Result) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) -> IQCancellable
    
}

open class QSyncDataSource< Loader : IQSyncDataLoader > : IQSyncDataSource {
    
    public typealias Result = Loader.Result
    public typealias Error = Loader.Error
     
    public private(set) var result: Result?
    public private(set) var error: Error?
    public var isSyncing: Bool {
        return self._query != nil
    }
    public private(set) var isNeedSync: Bool
    
    private var _loader: Loader
    private var _query: IQCancellable?
    
    public init(loader: Loader) {
        self.isNeedSync = true
        self._loader = loader
    }
    
    deinit {
        self.cancel()
    }
    
    public func setNeedSync() {
        self.isNeedSync = true
    }
    
    public func syncIfNeeded() {
        guard self.isSyncing == false && self.isNeedSync == true else { return }
        self._query = self._loader.perform(
            success: { [weak self] result in self?._didSync(result: result) },
            failure: { [weak self] error in self?._didSync(error: error) }
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
        self.isNeedSync = false
        self.didSync(result: result)
    }

    func _didSync(error: Error) {
        self._query = nil
        self.error = error
        self.didSync(error: error)
    }
    
}
