//
//  libQuicklyView
//

import Foundation

public protocol IQCellComposition {
    
    var layout: IQDynamicLayout { get }
    var isOpaque: Bool { get }
    
}

open class QCellView< Composition: IQCellComposition > : QControlView {
    
    public typealias SimpleClosure = (_ cellView: QCellView< Composition >) -> Void
    
    public var composition: Composition {
        didSet {
            guard self.isLoaded == true else { return }
            self.layout = self.composition.layout
            self.isOpaque = self.composition.isOpaque
        }
    }
    public var onChangeStyle: SimpleClosure?
    public var onPressed: SimpleClosure?
    
    public init(
        composition: Composition,
        shouldHighlighting: Bool = false,
        shouldPressed: Bool = false,
        alpha: QFloat = 1,
        onChangeStyle: SimpleClosure? = nil,
        onPressed: SimpleClosure? = nil
    ) {
        self.composition = composition
        self.onChangeStyle = onChangeStyle
        self.onPressed = onPressed
        super.init(
            layout: composition.layout,
            shouldHighlighting: shouldHighlighting,
            shouldPressed: shouldPressed,
            isOpaque: composition.isOpaque,
            alpha: alpha
        )
    }
    
    public override func didChange(highlighted: Bool, userIteraction: Bool) {
        self.onChangeStyle?(self)
    }
    
    public override func didPressed() {
        self.onPressed?(self)
    }
    
}
