//
//  libQuicklyApi
//

import Foundation
import libQuicklyCore

public protocol IQApiQuery : IQCancellable {

    var provider: IQApiProvider { get }
    var createAt: Date { get }

    func start()
    func redirect(request: URLRequest) -> URLRequest?

}
