//
//  libQuicklyApi
//

import Foundation

public protocol IQApiProvider : AnyObject {

    var url: URL? { get }
    var queryParams: [String: Any] { get }
    var headers: [String: String] { get }
    var bodyParams: [String: Any]? { get }
    #if DEBUG
    var logging: QApiLogging { get }
    #endif

    func send(query: IQApiQuery)

}

public extension IQApiProvider {

    func send< RequestType: IQApiRequest, ResponseType: IQApiResponse >(
        request: RequestType,
        response: ResponseType,
        queue: DispatchQueue = DispatchQueue.main,
        completed: @escaping QApiTaskQuery< RequestType, ResponseType >.CompleteClosure
    ) -> QApiTaskQuery< RequestType, ResponseType > {
        let query = QApiTaskQuery< RequestType, ResponseType >(
            provider: self,
            request: request,
            response: response,
            queue: queue,
            onCompleted: completed
        )
        self.send(query: query)
        return query
    }

    func send< RequestType: IQApiRequest, ResponseType: IQApiResponse >(
        request: RequestType,
        response: ResponseType,
        queue: DispatchQueue = DispatchQueue.main,
        download: @escaping QApiTaskQuery< RequestType, ResponseType >.ProgressClosure,
        completed: @escaping QApiTaskQuery< RequestType, ResponseType >.CompleteClosure
    ) -> QApiTaskQuery< RequestType, ResponseType > {
        let query = QApiTaskQuery< RequestType, ResponseType >(
            provider: self,
            request: request,
            response: response,
            queue: queue,
            onDownload: download,
            onCompleted: completed
        )
        self.send(query: query)
        return query
    }

    func send< RequestType: IQApiRequest, ResponseType: IQApiResponse >(
        request: RequestType,
        response: ResponseType,
        queue: DispatchQueue = DispatchQueue.main,
        upload: @escaping QApiTaskQuery< RequestType, ResponseType >.ProgressClosure,
        completed: @escaping QApiTaskQuery< RequestType, ResponseType >.CompleteClosure
    ) -> QApiTaskQuery< RequestType, ResponseType > {
        let query = QApiTaskQuery< RequestType, ResponseType >(
            provider: self,
            request: request,
            response: response,
            queue: queue,
            onUpload: upload,
            onCompleted: completed
        )
        self.send(query: query)
        return query
    }
    
}

public extension IQApiProvider {
    
    func send< ResponseType: IQApiResponse >(
        response: ResponseType,
        queue: DispatchQueue = DispatchQueue.main,
        prepare: @escaping QApiMockQuery< ResponseType >.PrepareClosure,
        completed: @escaping QApiMockQuery< ResponseType >.CompleteClosure
    ) -> QApiMockQuery<  ResponseType > {
        let query = QApiMockQuery< ResponseType >(
            provider: self,
            response: response,
            queue: queue,
            onPrepare: prepare,
            onCompleted: completed
        )
        self.send(query: query)
        return query
    }
    
}
