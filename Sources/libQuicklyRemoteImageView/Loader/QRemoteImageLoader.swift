//
//  libQuicklyRemoteImageView
//

import Foundation
import libQuicklyCore
import libQuicklyApi
import libQuicklyView

protocol IQRemoteImageLoaderDelegate : AnyObject {
    
    func didFinish(_ task: QRemoteImageLoader.Task)
    
}

public class QRemoteImageLoader {
    
    public let provider: QApiProvider
    public let cache: QRemoteImageCache

    private var _queue: DispatchQueue
    private var _tasks: [Task]

    public init(
        provider: QApiProvider,
        cache: QRemoteImageCache,
        queue: DispatchQueue = DispatchQueue.global(qos: .background)
    ) throws {
        self.provider = provider
        self.cache = cache
        self._queue = queue
        self._tasks = []
    }
    
}

public extension QRemoteImageLoader {
    
    static let shared: QRemoteImageLoader = {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 30
        sessionConfiguration.timeoutIntervalForResource = 30
        
        let sessionQueue = OperationQueue()
        sessionQueue.maxConcurrentOperationCount = 1
        
        return try! QRemoteImageLoader(
            provider: QApiProvider(
                allowInvalidCertificates: true,
                sessionConfiguration: sessionConfiguration,
                sessionQueue: sessionQueue
            ),
            cache: QRemoteImageCache.shared
        )
    }()
    
    func isExist(query: IQRemoteImageQuery, filter: IQRemoteImageFilter? = nil) -> Bool {
        return self.cache.isExist(query: query, filter: filter)
    }

    func download(query: IQRemoteImageQuery, filter: IQRemoteImageFilter?, target: IQRemoteImageTarget) {
        if let task = self._tasks.first(where: { return $0.query === query && $0.filter === filter }) {
            task.add(target: target)
        } else {
            let task = Task(delegate: self, provider: self.provider, cache: self.cache, query: query, filter: filter, target: target)
            self._tasks.append(task)
            task.execute(queue: self._queue)
        }
    }

    func cancel(target: IQRemoteImageTarget) {
        self._tasks.removeAll(where: { task in
            if task.remove(target: target) == true {
                task.cancel()
            }
            return task.isEmptyTargets()
        })
    }
    
    func cleanup(before: TimeInterval) {
        self.cache.cleanup(before: before)
    }
    
}

extension QRemoteImageLoader : IQRemoteImageLoaderDelegate {
    
    func didFinish(_ task: QRemoteImageLoader.Task) {
        self._tasks.removeAll(where: { return $0 === task })
    }
    
}
