//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

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
        
        private unowned var _view: QProgressView?
        private var _progress: UIProgressView!
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
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

extension QProgressView.ProgressView {
    
    func update(view: QProgressView) {
        self._view = view
        self.update(progressColor: view.progressColor)
        self.update(trackColor: view.trackColor)
        self.update(progress: view.progress)
        self.update(color: view.color)
        self.update(border: view.border)
        self.update(cornerRadius: view.cornerRadius)
        self.update(shadow: view.shadow)
        self.update(alpha: view.alpha)
        self.updateShadowPath()
    }
    
    func update(progressColor: QColor) {
        self._progress.progressTintColor = progressColor.native
    }
    
    func update(trackColor: QColor) {
        self._progress.trackTintColor = trackColor.native
    }
    
    func update(progress: QFloat) {
        self._progress.progress = progress
    }
    
}

extension QProgressView.ProgressView : IQReusable {
    
    typealias View = QProgressView
    typealias Item = QProgressView.ProgressView

    static var reuseIdentificator: String {
        return "QProgressView"
    }
    
    static func createReuseItem(view: View) -> Item {
        return Item(frame: .zero)
    }
    
    static func configureReuseItem(view: View, item: Item) {
        item.update(view: view)
    }
    
    static func cleanupReuseItem(view: View, item: Item) {
    }
    
}

#endif
