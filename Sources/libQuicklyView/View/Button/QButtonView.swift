//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

open class QButtonView< BackgroundView: IQView > : QControlView {
    
    public typealias SimpleClosure = (_ buttonView: QButtonView) -> Void
    
    public var inset: QInset {
        set(value) {
            self._layout.inset = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.inset }
    }
    public private(set) var backgroundView: BackgroundView
    public var spinnerPosition: SpinnerPosition {
        set(value) {
            self._layout.spinnerPosition = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.spinnerPosition }
    }
    public var spinnerAnimating: Bool {
        set(value) {
            self._layout.spinnerAnimating = value
            self.spinnerView?.isAnimating = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.spinnerAnimating }
    }
    public private(set) var spinnerView: IQSpinnerView?
    public var imagePosition: ImagePosition {
        set(value) {
            self._layout.imagePosition = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.imagePosition }
    }
    public var imageInset: QInset {
        set(value) {
            self._layout.imageInset = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.imageInset }
    }
    public private(set) var imageView: QImageView?
    public var textInset: QInset {
        set(value) {
            self._layout.textInset = value
            self._layout.setNeedUpdate()
        }
        get { return self._layout.textInset }
    }
    public private(set) var textView: QTextView?
    public var onChangeStyle: SimpleClosure?
    public var onPressed: SimpleClosure
    
    private var _layout: Layout
    
    public init(
        inset: QInset = QInset(horizontal: 4, vertical: 4),
        backgroundView: BackgroundView,
        spinnerPosition: SpinnerPosition = .fill,
        spinnerView: IQSpinnerView? = nil,
        spinnerAnimating: Bool = false,
        imagePosition: ImagePosition = .left,
        imageInset: QInset = QInset(horizontal: 4, vertical: 4),
        imageView: QImageView? = nil,
        textInset: QInset = QInset(horizontal: 4, vertical: 4),
        textView: QTextView? = nil,
        alpha: QFloat = 1,
        onChangeStyle: SimpleClosure? = nil,
        onPressed: @escaping SimpleClosure
    ) {
        self.backgroundView = backgroundView
        self.spinnerView = spinnerView
        self.imageView = imageView
        self.textView = textView
        self.onChangeStyle = onChangeStyle
        self.onPressed = onPressed
        self._layout = Layout(
            inset: inset,
            backgroundItem: QLayoutItem(view: backgroundView),
            spinnerPosition: spinnerPosition,
            spinnerItem: spinnerView.flatMap({ return QLayoutItem(view: $0) }),
            spinnerAnimating: spinnerAnimating,
            imagePosition: imagePosition,
            imageInset: imageInset,
            imageItem: imageView.flatMap({ return QLayoutItem(view: $0) }),
            textInset: textInset,
            textItem: textView.flatMap({ return QLayoutItem(view: $0) })
        )
        super.init(
            layout: self._layout,
            shouldHighlighting: true,
            shouldPressed: true,
            isOpaque: false,
            alpha: alpha
        )
    }
    
    public override func didChange(highlighted: Bool, userIteraction: Bool) {
        self.onChangeStyle?(self)
    }
    
    public override func didPressed() {
        self.onPressed(self)
    }
    
}

public extension QButtonView {
    
    enum SpinnerPosition {
        case fill
        case image
    }
    
    enum ImagePosition {
        case top
        case left
        case right
        case bottom
    }
    
}

extension QButtonView {
    
    class Layout : IQLayout {
        
        weak var delegate: IQLayoutDelegate?
        weak var parentView: IQView?
        var inset: QInset
        var spinnerPosition: SpinnerPosition
        var spinnerItem: IQLayoutItem?
        var spinnerAnimating: Bool
        var backgroundItem: IQLayoutItem
        var imagePosition: ImagePosition
        var imageInset: QInset
        var imageItem: IQLayoutItem?
        var textInset: QInset
        var textItem: IQLayoutItem?
        var items: [IQLayoutItem] {
            var items: [IQLayoutItem] = [ self.backgroundItem ]
            if self.spinnerAnimating == true {
                if let item = self.spinnerItem {
                    items.append(item)
                }
            } else {
                if let item = self.imageItem {
                    items.append(item)
                }
                if let item = self.textItem {
                    items.append(item)
                }
            }
            return items
        }
        var size: QSize

        init(
            inset: QInset,
            backgroundItem: IQLayoutItem,
            spinnerPosition: SpinnerPosition,
            spinnerItem: IQLayoutItem?,
            spinnerAnimating: Bool,
            imagePosition: ImagePosition,
            imageInset: QInset,
            imageItem: IQLayoutItem?,
            textInset: QInset,
            textItem: IQLayoutItem?
        ) {
            self.inset = inset
            self.backgroundItem = backgroundItem
            self.spinnerPosition = spinnerPosition
            self.spinnerItem = spinnerItem
            self.spinnerAnimating = spinnerAnimating
            self.imagePosition = imagePosition
            self.imageInset = imageInset
            self.imageItem = imageItem
            self.textInset = textInset
            self.textItem = textItem
            self.size = QSize()
        }
        
        func layout() {
            var size: QSize
            if let bounds = self.delegate?.bounds(self) {
                size = bounds.size
                self.backgroundItem.frame = bounds
                if self.spinnerAnimating == true, let spinnerItem = self.spinnerItem {
                    let spinnerSize = spinnerItem.size(bounds.size)
                    switch self.spinnerPosition {
                    case .fill:
                        spinnerItem.frame = QRect(center: bounds.center, size: spinnerSize)
                    case .image:
                        if self.imageItem != nil, let textItem = self.textItem {
                            let textSize = textItem.size(bounds.size)
                            let frames = self.imagePosition._frame(
                                bounds: bounds,
                                primarySize: spinnerSize,
                                primaryInset: self.imageInset,
                                secondarySize: textSize,
                                secondaryInset: self.textInset
                            )
                            spinnerItem.frame = frames.primary
                            textItem.frame = frames.secondary
                        } else {
                            spinnerItem.frame = QRect(center: bounds.center, size: spinnerSize)
                        }
                    }
                } else if let imageItem = self.imageItem, let textItem = self.textItem {
                    let imageSize = imageItem.size(bounds.size)
                    let textSize = textItem.size(bounds.size)
                    let frames = self.imagePosition._frame(
                        bounds: bounds,
                        primarySize: imageSize,
                        primaryInset: self.imageInset,
                        secondarySize: textSize,
                        secondaryInset: self.textInset
                    )
                    imageItem.frame = frames.primary
                    textItem.frame = frames.secondary
                } else if let imageItem = self.imageItem {
                    let imageSize = imageItem.size(bounds.size)
                    imageItem.frame = QRect(center: bounds.center, size: imageSize)
                } else if let textItem = self.textItem {
                    let textSize = textItem.size(bounds.size)
                    textItem.frame = QRect(center: bounds.center, size: textSize)
                }
            } else {
                size = QSize()
            }
            self.size = size
        }
        
        func size(_ available: QSize) -> QSize {
            var size = QSize(width: 0, height: 0)
            let spinnerSize = self.spinnerItem.flatMap({ return $0.size(available) })
            let imageSize = self.imageItem.flatMap({ return $0.size(available) })
            let textSize = self.textItem.flatMap({ return $0.size(available) })
            if self.spinnerAnimating == true, let spinnerSize = spinnerSize {
                switch self.spinnerPosition {
                case .fill:
                    size.width = self.inset.left + spinnerSize.width + self.inset.right
                    size.height = self.inset.top + spinnerSize.height + self.inset.bottom
                case .image:
                    if imageSize != nil, let textSize = textSize {
                        switch self.imagePosition {
                        case .top:
                            size.width = self.inset.left + max(spinnerSize.width, textSize.width) + self.inset.right
                            size.height = self.inset.top + spinnerSize.height + self.imageInset.bottom + self.textInset.top + textSize.height + self.inset.bottom
                        case .left:
                            size.width += self.inset.left + spinnerSize.width + self.imageInset.right + self.textInset.left + textSize.width + self.inset.right
                            size.height = self.inset.top + max(spinnerSize.height, textSize.height) + self.inset.bottom
                        case .right:
                            size.width = self.inset.left + textSize.width + self.textInset.right + self.imageInset.left + spinnerSize.width + self.inset.right
                            size.height = self.inset.top + max(spinnerSize.height, textSize.height) + self.inset.bottom
                        case .bottom:
                            size.width = self.inset.left + max(spinnerSize.width, textSize.width) + self.inset.right
                            size.height = self.inset.top + textSize.height + self.textInset.bottom + self.imageInset.top + spinnerSize.height + self.inset.bottom
                        }
                    } else {
                        size.width = self.inset.left + spinnerSize.width + self.inset.right
                        size.height = self.inset.top + spinnerSize.height + self.inset.bottom
                    }
                }
            } else if let imageSize = imageSize, let textSize = textSize {
                switch self.imagePosition {
                case .top:
                    size.width = self.inset.left + max(imageSize.width, textSize.width) + self.inset.right
                    size.height = self.inset.top + imageSize.height + self.imageInset.bottom + self.textInset.top + textSize.height + self.inset.bottom
                case .left:
                    size.width = self.inset.left + imageSize.width + self.imageInset.right + self.textInset.left + textSize.width + self.inset.right
                    size.height = self.inset.top + max(imageSize.height, textSize.height) + self.inset.bottom
                case .right:
                    size.width = self.inset.left + textSize.width + self.textInset.right + self.imageInset.left + imageSize.width + self.inset.right
                    size.height = self.inset.top + max(imageSize.height, textSize.height) + self.inset.bottom
                case .bottom:
                    size.width = self.inset.left + max(imageSize.width, textSize.width) + self.inset.right
                    size.height = self.inset.top + textSize.height + self.textInset.bottom + self.imageInset.top + imageSize.height + self.inset.bottom
                }
            } else if let imageSize = imageSize {
                size.width = self.inset.left + imageSize.width + self.inset.right
                size.height = self.inset.top + imageSize.height + self.inset.bottom
            } else if let textSize = textSize {
                size.width = self.inset.left + textSize.width + self.inset.right
                size.height = self.inset.top + textSize.height + self.inset.bottom
            }
            return size
        }
        
        func items(bounds: QRect) -> [IQLayoutItem] {
            return self.items
        }
        
        func insert(item: IQLayoutItem, at index: UInt) {
        }
        
        func delete(item: IQLayoutItem) {
        }
        
    }
    
}

private extension QButtonView.ImagePosition {
    
    func _frame(bounds: QRect, primarySize: QSize, primaryInset: QInset, secondarySize: QSize, secondaryInset: QInset) -> (primary: QRect, secondary: QRect) {
        var primary = QRect(topLeft: QPoint(), size: primarySize)
        var secondary = QRect(topLeft: QPoint(), size: secondarySize)
        switch self {
        case .top: secondary.origin.y = primaryInset.bottom + secondaryInset.top
        case .left: secondary.origin.x = primaryInset.right + secondaryInset.left
        case .right: primary.origin.x = secondaryInset.right + primaryInset.left
        case .bottom: primary.origin.y = secondaryInset.bottom + primaryInset.top
        }
        switch self {
        case .top, .bottom:
            let width = max(primary.size.width, secondary.size.width)
            primary.origin.x = (width - primary.size.width) / 2
            secondary.origin.x = (width - secondary.size.width) / 2
        case .left, .right:
            let height = max(primary.size.height, secondary.size.height)
            primary.origin.y = (height - primary.size.height) / 2
            secondary.origin.y = (height - secondary.size.height) / 2
        }
        let union = primary.union(secondary)
        let offset = QRect(center: bounds.center, size: union.size).origin
        return (
            primary: primary.offset(point: offset),
            secondary: secondary.offset(point: offset)
        )
    }
    
}
