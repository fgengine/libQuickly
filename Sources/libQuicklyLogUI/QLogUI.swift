//
//  libQuicklyLogUI
//

import Foundation
import libQuicklyCore
import libQuicklyView

public struct QLogUI {
    
    public static func container(
        target: Target
    ) -> IQModalContentContainer {
        let screen = Screen(target: target)
        let stackScreen = StackScreen()
        screen.onClose = { [unowned stackScreen] in
            stackScreen.dismiss()
        }
        return QStackContainer(
            screen: stackScreen,
            rootContainer: QScreenContainer(screen: screen)
        )
    }
    
}

extension QLogUI {
    
    class StackScreen : IQStackScreen, IQScreenModalable {
        
        var container: IQContainer?
        var modalPresentation: QScreenModalPresentation {
            return .sheet(
                info: QScreenModalPresentation.Sheet(
                    inset: QInset(top: 80, left: 0, right: 0, bottom: 0),
                    backgroundView: self._backgroundView
                )
            )
        }
        
        private let _backgroundView: QEmptyView
        
        init() {
            self._backgroundView = QEmptyView(
                color: QColor(rgba: 0x0000007a)
            )
        }
        
    }
    
}
