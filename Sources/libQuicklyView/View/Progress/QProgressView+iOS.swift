//
//  libQuicklyView
//

#if os(iOS)

import UIKit

extension QProgressView {
    
    final class ProgressView : UIProgressView {
        
        var qProgressColor: QColor {
            set(value) { self._progress.progressTintColor = value.native }
            get { return QColor(self._progress.progressTintColor!) }
        }
        var qTrackColor: QColor {
            set(value) { self._progress.trackTintColor = value.native }
            get { return QColor(self._progress.trackTintColor!) }
        }
        var qProgress: QFloat {
            set(value) { self._progress.progress = value }
            get { return QFloat(self._progress.progress) }
        }
        var qAlpha: QFloat {
            set(value) { self.alpha = CGFloat(value) }
            get { return QFloat(self.alpha) }
        }
        var qIsAppeared: Bool {
            return self.superview != nil
        }
        
        private var _progress: UIProgressView!
        
        init() {
            super.init(frame: .zero)
            
            self.isUserInteractionEnabled = false
            self.clipsToBounds = true
            
            self._progress = UIProgressView()
            self.addSubview(self._progress)
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            let bounds = self.bounds
            let progressSize = self._progress.sizeThatFits(bounds.size)
            self._progress.frame = CGRect(
                x: bounds.midX - (progressSize.width / 2),
                y: bounds.midY - (progressSize.height / 2),
                width: progressSize.width,
                height: progressSize.height
            )
        }
        
    }
    
}

extension QProgressView.ProgressView : IQNativeBlendingView {
    
    func allowBlending() -> Bool {
        return self.alpha < 1
    }
    
    func updateBlending(superview: QNativeView) {
        if self.allowBlending() == true || superview.allowBlending() == true {
            self._progress.backgroundColor = .clear
            self._progress.isOpaque = false
            self.backgroundColor = .clear
            self.isOpaque = false
        } else {
            self._progress.backgroundColor = superview.backgroundColor
            self._progress.isOpaque = true
            self.backgroundColor = superview.backgroundColor
            self.isOpaque = true
        }
    }
    
}

extension QProgressView.ProgressView : IQReusable {
    
    typealias View = QProgressView
    typealias Item = QProgressView.ProgressView

    static var reuseIdentificator: String {
        return "QProgressView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item()
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.qProgressColor = view.progressColor
        item.qTrackColor = view.trackColor
        item.qProgress = view.progress
        item.qAlpha = view.alpha
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
