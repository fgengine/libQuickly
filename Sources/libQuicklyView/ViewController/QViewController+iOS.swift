//
//  libQuicklyView
//

#if os(iOS)

import UIKit
import libQuicklyCore

public class QViewController : UIViewController {
    
    public let container: IQRootContainer
    public private(set) var virtualKeyboardHeight: Float {
        didSet(oldValue) {
            guard self.virtualKeyboardHeight != oldValue else { return }
            self._updateSafeArea()
        }
    }
    public override var prefersStatusBarHidden: Bool {
        return self.container.statusBarHidden
    }
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.container.statusBarStyle
    }
    public override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return self.container.statusBarAnimation
    }
    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return self.container.supportedOrientations
    }
    public override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return self._interfaceOrientation()
    }
    public override var shouldAutorotate: Bool {
        return true
    }
    
    private var _virtualKeyboard: QVirtualKeyboard
    
    public init(
        container: IQRootContainer
    ) {
        self.container = container
        self.virtualKeyboardHeight = 0
        self._virtualKeyboard = QVirtualKeyboard()
        
        super.init(nibName: nil, bundle: nil)
        
        self.container.delegate = self
        self._virtualKeyboard.add(observer: self, priority: .userInitiated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self._didChangeStatusBarFrame(_:)), name: UIApplication.didChangeStatusBarFrameNotification, object: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self._virtualKeyboard.remove(observer: self)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func loadView() {
        self.view = self.container.view.native
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.container.safeArea = self._safeArea()
        if let statusBarView = self.container.statusBarView {
            statusBarView.height = self._statusBarHeight()
        }
        self.container.prepareShow(interactive: false)
        self.container.finishShow(interactive: false)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self._updateStatusBarHeight()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self._updateSafeArea()
    }
    
    @available(iOS 11.0, *)
    public override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        self._updateSafeArea()
    }
    
}

extension QViewController : IQRootContainerDelegate {
    
    public func updateOrientations() {
        let interfaceOrientation = self._interfaceOrientation()
        var deviceOrientation = UIDevice.current.orientation
        switch interfaceOrientation {
        case .portrait: deviceOrientation = UIDeviceOrientation.portrait
        case .portraitUpsideDown: deviceOrientation = UIDeviceOrientation.portraitUpsideDown
        case .landscapeLeft: deviceOrientation = UIDeviceOrientation.landscapeLeft
        case .landscapeRight: deviceOrientation = UIDeviceOrientation.landscapeRight
        case .unknown: break
        @unknown default: break
        }
        if deviceOrientation != UIDevice.current.orientation {
            UIDevice.current.setValue(deviceOrientation.rawValue, forKey: "orientation")
        }
    }
    
    public func updateStatusBar() {
        self.setNeedsStatusBarAppearanceUpdate()
        self._updateStatusBarHeight()
    }
    
}

extension QViewController : IQVirtualKeyboardObserver {
    
    public func willShow(virtualKeyboard: QVirtualKeyboard, info: QVirtualKeyboard.Info) {
        self._updateVirtualKeyboardHeight(duration: info.duration, height: info.endFrame.height)
    }
    
    public func didShow(virtualKeyboard: QVirtualKeyboard, info: QVirtualKeyboard.Info) {
    }

    public func willHide(virtualKeyboard: QVirtualKeyboard, info: QVirtualKeyboard.Info) {
        self._updateVirtualKeyboardHeight(duration: info.duration, height: 0)
    }
    
    public func didHide(virtualKeyboard: QVirtualKeyboard, info: QVirtualKeyboard.Info) {
    }
    
}

private extension QViewController {
    
    @objc
    func _didChangeStatusBarFrame(_ notification: Any) {
        self._updateStatusBarHeight()
    }
    
    func _updateStatusBarHeight() {
        if let statusBarView = self.container.statusBarView {
            statusBarView.height = self._statusBarHeight()
        }
    }
    
    func _statusBarHeight() -> Float {
        let height: Float
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            height = Float(window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0)
        } else {
            height = Float(UIApplication.shared.statusBarFrame.height)
        }
        return height
    }
    
    func _updateSafeArea() {
        self.container.safeArea = self._safeArea()
        self.container.view.layoutIfNeeded()
    }
    
    func _safeArea() -> QInset {
        let safeArea: QInset
        if #available(iOS 11.0, *) {
            safeArea = QInset(self.view.safeAreaInsets)
        } else {
            safeArea = QInset(
                top: Float(self.topLayoutGuide.length),
                left: 0,
                right: 0,
                bottom: Float(self.bottomLayoutGuide.length)
            )
        }
        return QInset(
            top: safeArea.top,
            left: safeArea.left,
            right: safeArea.right,
            bottom: max(safeArea.bottom, self.virtualKeyboardHeight)
        )
    }
    
    func _updateVirtualKeyboardHeight(duration: TimeInterval, height: Float) {
        guard abs(self.virtualKeyboardHeight - height) > .leastNonzeroMagnitude else { return }
        QAnimation.default.run(
            duration: duration,
            processing: { [unowned self] progress in
                self.virtualKeyboardHeight = self.virtualKeyboardHeight.lerp(height, progress: progress)
            },
            completion: { [unowned self] in
                self.virtualKeyboardHeight = height
            }
        )
    }
    
    func _interfaceOrientation() -> UIInterfaceOrientation {
        let supportedOrientations = self.supportedInterfaceOrientations
        switch UIDevice.current.orientation {
        case .unknown, .portrait, .faceUp, .faceDown:
            if supportedOrientations.contains(.portrait) == true {
                return .portrait
            } else if supportedOrientations.contains(.portraitUpsideDown) == true {
                return .portraitUpsideDown
            } else if supportedOrientations.contains(.landscapeLeft) == true {
                return .landscapeLeft
            } else if supportedOrientations.contains(.landscapeRight) == true {
                return .landscapeRight
            }
            break
        case .portraitUpsideDown:
            if supportedOrientations.contains(.portraitUpsideDown) == true {
                return .portraitUpsideDown
            } else if supportedOrientations.contains(.portrait) == true {
                return .portrait
            } else if supportedOrientations.contains(.landscapeLeft) == true {
                return .landscapeLeft
            } else if supportedOrientations.contains(.landscapeRight) == true {
                return .landscapeRight
            }
            break
        case .landscapeLeft:
            if supportedOrientations.contains(.landscapeLeft) == true {
                return .landscapeLeft
            } else if supportedOrientations.contains(.landscapeRight) == true {
                return .landscapeRight
            } else if supportedOrientations.contains(.portrait) == true {
                return .portrait
            } else if supportedOrientations.contains(.portraitUpsideDown) == true {
                return .portraitUpsideDown
            }
            break
        case .landscapeRight:
            if supportedOrientations.contains(.landscapeRight) == true {
                return .landscapeRight
            } else if supportedOrientations.contains(.landscapeLeft) == true {
                return .landscapeLeft
            } else if supportedOrientations.contains(.portrait) == true {
                return .portrait
            } else if supportedOrientations.contains(.portraitUpsideDown) == true {
                return .portraitUpsideDown
            }
            break
        @unknown default:
            break
        }
        return .unknown
    }
    
}

#endif
