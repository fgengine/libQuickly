//
//  libQuicklyRemoteImageView
//

import Foundation
import libQuicklyCore
import libQuicklyApi
import libQuicklyView

public class QRemoteImageQuery : IQRemoteImageQuery {
    
    public let url: URL
    public var key: String {
        guard let sha256 = self.url.absoluteString.sha256 else {
            return self.url.lastPathComponent
        }
        return sha256
    }
    public var isLocal: Bool {
        return self.url.isFileURL
    }
    
    public init(url: URL) {
        self.url = url
    }
    
    public func localData() throws -> Data {
        return try Data(contentsOf: self.url)
    }
    
    public func download(
        provider: IQApiProvider,
        download: @escaping (_ progress: Progress) -> Void,
        success: @escaping (_ data: Data, _ image: QImage) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) -> IQCancellable {
        return provider.send(
            request: Request(url: self.url),
            response: Response(),
            download: download,
            completed: { request, response in
                if let error = response.error {
                    failure(error)
                } else {
                    success(response.data, response.image)
                }
            }
        )
    }
    
}

private extension QRemoteImageQuery {
    
    class Request : QApiRequest {
        
        init(url: URL) {
            super.init(method: "GET", path: .absolute(url))
        }
        
    }
    
}

private extension QRemoteImageQuery {
    
    class Response : QApiResponse {
        
        var data: Data!
        var image: QImage!
        
        override func parse() throws {
            throw QApiError.invalidResponse
        }

        override func parse(data: Data) throws {
            guard let image = QImage(data: data) else {
                throw QApiError.invalidResponse
            }
            self.data = data
            self.image = image
        }
        
    }
    
}
