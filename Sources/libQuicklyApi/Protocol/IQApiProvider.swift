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
