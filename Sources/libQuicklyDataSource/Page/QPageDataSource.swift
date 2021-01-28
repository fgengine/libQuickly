//
//  libQuicklyData
//

import Foundation
import libQuicklyCore

public protocol IQPageDataLoader {
    
    associatedtype Result : RangeReplaceableCollection
    associatedtype Error
    
    func perform(
        reload: Bool,
        success: @escaping (_ result: Result, _ canMore: Bool) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) -> IQCancellable
    
}

open class QPageDataSource< Loader : IQPageDataLoader > : IQPageDataSource {
    
    public typealias Result = Loader.Result
    public typealias Error = Loader.Error
     
    public private(set) var result: Result?
    public private(set) var error: Error?
    public var isLoading: Bool {
        return self._query != nil
    }
    public private(set) var canMore: Bool
    
    private var _loader: Loader
    private var _query: IQCancellable?
    
    public init(loader: Loader) {
        self.canMore = true
        self._loader = loader
    }
    
    deinit {
        self.cancel()
    }

    public func load(reload: Bool) {
        guard self.isLoading == false else { return }
        let isFirst = reload == true || self.result == nil
        self._query = self._loader.perform(
            reload: reload,
            success: { [weak self] result, canMore in self?._didLoad(isFirst: isFirst, result: result, canMore: canMore) },
            failure: { [weak self] error in self?._didLoad(error: error) }
        )
    }
    
    public func cancel() {
        self._query?.cancel()
        self._query = nil
    }

    open func didLoad(isFirst: Bool, result: Result, canMore: Bool) {
    }

    open func didLoad(error: Error) {
    }

}

private extension QPageDataSource {

    func _didLoad(isFirst: Bool, result: Result, canMore: Bool) {
        self._query = nil
        if isFirst == true || self.result == nil {
            self.result = result
        } else {
            self.result?.append(contentsOf: result)
        }
        self.canMore = canMore
        self.didLoad(isFirst: isFirst, result: result, canMore: canMore)
    }

    func _didLoad(error: Error) {
        self._query = nil
        self.error = error
        self.didLoad(error: error)
    }
    
}
