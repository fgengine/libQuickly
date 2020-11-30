//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

open class QCellView : QControlView {
    
    public typealias SimpleClosure = (_ cellView: QCellView) -> Void
    
    public var onChangeStyle: SimpleClosure?
    public var onPressed: SimpleClosure?
    
    public var contentLayout: IQLayout {
        set(value) { self.layout = value }
        get { return self.layout }
    }
    
    public init(
        contentLayout: IQLayout,
        shouldHighlighting: Bool = false,
        shouldPressed: Bool = false,
        isOpaque: Bool = true,
        alpha: QFloat = 1,
        onChangeStyle: SimpleClosure? = nil,
        onPressed: SimpleClosure? = nil
    ) {
        self.onChangeStyle = onChangeStyle
        self.onPressed = onPressed
        super.init(
            layout: contentLayout,
            shouldHighlighting: shouldHighlighting,
            shouldPressed: shouldPressed,
            isOpaque: isOpaque,
            alpha: alpha
        )
    }
    
}
