//
//  libQuicklyView
//

#if os(OSX)

import AppKit
import libQuicklyCore

extension QImageView {
    
    final class ImageView : NSView {
        
        var qImage: QImage {
            set(value) { self.layer!.contents = value.native }
            get { return QImage(self.layer!.contents as! NSImage) }
        }
        var qMode: Mode {
            set(value) { self.layer!.contentsGravity = value.caLayerContentsGravity }
            get { return Mode(self.layer!.contentsGravity) }
        }
        var qAlpha: QFloat {
            set(value) { self.alphaValue = CGFloat(value) }
            get { return QFloat(self.alphaValue) }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        
        init() {
            super.init(frame: .zero)
            
            self.wantsLayer = true
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func hitTest(_ point: NSPoint) -> NSView? {
            return nil
        }
        
    }
        
}

extension QImageView.Mode {
    
    var caLayerContentsGravity: CALayerContentsGravity {
        switch self {
        case .origin: return .center
        case .aspectFit: return .resizeAspect
        case .aspectFill: return .resizeAspectFill
        }
    }
    
    init(_ caLayerContentsGravity: CALayerContentsGravity) {
        switch caLayerContentsGravity {
        case .resizeAspect: self = .aspectFit
        case .resizeAspectFill: self = .aspectFill
        default: self = .origin
        }
    }
    
}

extension QImageView.ImageView : IQReusable {
    
    typealias View = QImageView
    typealias Item = QImageView.ImageView

    static var reuseIdentificator: String {
        return "QImageView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item()
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qImage = view.image
        item.qMode = view.mode
        item.qAlpha = view.alpha
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
