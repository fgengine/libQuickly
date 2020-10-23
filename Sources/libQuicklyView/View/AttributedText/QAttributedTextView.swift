//
//  libQuicklyView
//

import Foundation

public class QAttributedTextView : IQView {
    
    public private(set) weak var parentLayout: IQLayout?
    public weak var item: IQLayoutItem?
    public var width: QDimensionBehaviour? {
        didSet {
            guard self.isLoaded == true else { return }
            self.parentLayout?.setNeedUpdate()
        }
    }
    public var height: QDimensionBehaviour? {
        didSet {
            guard self.isLoaded == true else { return }
            self.parentLayout?.setNeedUpdate()
        }
    }
    public var text: NSAttributedString {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qText = self.text
            self.parentLayout?.setNeedUpdate()
        }
    }
    public var alignment: QTextAlignment {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qAlignment = self.alignment
            self.parentLayout?.setNeedUpdate()
        }
    }
    public var lineBreak: QTextLineBreak {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qLineBreak = self.lineBreak
            self.parentLayout?.setNeedUpdate()
        }
    }
    public var numberOfLines: UInt {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qNumberOfLines = self.numberOfLines
            self.parentLayout?.setNeedUpdate()
        }
    }
    public var alpha: QFloat {
        didSet {
            guard self.isLoaded == true else { return }
            self._view.qAlpha = self.alpha
        }
    }
    public var isLoaded: Bool {
        return self._reuseView.isLoaded
    }
    public var isAppeared: Bool {
        guard self.isLoaded == true else { return false }
        return self._view.qIsAppeared
    }
    public var native: QNativeView {
        return self._view
    }
    
    private var _view: AttributedTextView {
        if self.isLoaded == false { self._reuseView.load(view: self) }
        return self._reuseView.item!
    }
    private var _reuseView: QReuseView< AttributedTextView >
    
    public init(
        width: QDimensionBehaviour? = nil,
        height: QDimensionBehaviour? = nil,
        text: NSAttributedString,
        alignment: QTextAlignment = .left,
        lineBreak: QTextLineBreak = .wordWrapping,
        numberOfLines: UInt = 0,
        alpha: QFloat = 1
    ) {
        self.width = width
        self.height = height
        self.text = text
        self.alignment = alignment
        self.lineBreak = lineBreak
        self.numberOfLines = numberOfLines
        self.alpha = alpha
        self._reuseView = QReuseView()
    }
    
    public func onAppear(to layout: IQLayout) {
        self.parentLayout = layout
    }
    
    public func onDisappear() {
        self._reuseView.unload(view: self)
        self.parentLayout = nil
    }
    
    public func size(_ available: QSize) -> QSize {
        if let width = self.width, let height = self.height {
            return available.apply(width: width, height: height)
        } else if let width = self.width {
            return self.text.size(available: QSize(
                width: available.width.apply(width),
                height: available.height
            ))
        } else if let height = self.height {
            return self.text.size(available: QSize(
                width: available.width,
                height: available.height.apply(height)
            ))
        }
        return self.text.size(available: available)
    }

}
