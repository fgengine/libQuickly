//
//  libQuicklyRemoteImageView
//

import Foundation
import libQuicklyCore
import libQuicklyApi
import libQuicklyView

public protocol IQRemoteImageQuery : AnyObject {
    
    var key: String { get }
    var isLocal: Bool { get }
    
    func localData() throws -> Data
    
    func download(
        provider: IQApiProvider,
        download: @escaping (_ progress: Progress) -> Void,
        success: @escaping (_ data: Data, _ image: QImage) -> Void,
        failure: @escaping (_ error: Error) -> Void
    ) -> IQCancellable
    
}
