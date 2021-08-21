//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QPincodeLayout< TitleView: IQView, PincodeView: IQView, ErrorView: IQView, ButtonView: IQView, AccessoryView: IQView > : IQLayout {
    
    public unowned var delegate: IQLayoutDelegate?
    public unowned var view: IQView?
    public var titleInset: QInset {
        didSet { self.setNeedForceUpdate() }
    }
    public var titleView: TitleView {
        didSet { self.titleItem = QLayoutItem(view: self.titleView) }
    }
    public private(set) var titleItem: QLayoutItem {
        didSet { self.setNeedForceUpdate() }
    }
    public var pincodeInset: QInset {
        didSet { self.setNeedForceUpdate() }
    }
    public var pincodeView: PincodeView {
        didSet { self.pincodeItem = QLayoutItem(view: self.pincodeView) }
    }
    public private(set) var pincodeItem: QLayoutItem {
        didSet { self.setNeedForceUpdate() }
    }
    public var errorInset: QInset {
        didSet { self.setNeedForceUpdate() }
    }
    public var errorView: ErrorView? {
        didSet {
            if let view = self.errorView {
                self.errorItem = QLayoutItem(view: view)
            } else {
                self.errorItem = nil
            }
        }
    }
    public private(set) var errorItem: QLayoutItem? {
        didSet { self.setNeedForceUpdate() }
    }
    public var buttonsInset: QInset {
        didSet { self.setNeedForceUpdate() }
    }
    public var buttonsSpacing: QPoint {
        didSet { self.setNeedForceUpdate() }
    }
    public var buttonsAspectRatio: Float {
        didSet { self.setNeedForceUpdate() }
    }
    public var buttonOneView: ButtonView {
        didSet { self.buttonOneItem = QLayoutItem(view: self.buttonOneView) }
    }
    public private(set) var buttonOneItem: QLayoutItem {
        didSet { self.setNeedForceUpdate() }
    }
    public var buttonTwoView: ButtonView {
        didSet { self.buttonTwoItem = QLayoutItem(view: self.buttonTwoView) }
    }
    public private(set) var buttonTwoItem: QLayoutItem {
        didSet { self.setNeedForceUpdate() }
    }
    public var buttonThreeView: ButtonView {
        didSet { self.buttonThreeItem = QLayoutItem(view: self.buttonThreeView) }
    }
    public private(set) var buttonThreeItem: QLayoutItem {
        didSet { self.setNeedForceUpdate() }
    }
    public var buttonFourView: ButtonView {
        didSet { self.buttonFourItem = QLayoutItem(view: self.buttonFourView) }
    }
    public private(set) var buttonFourItem: QLayoutItem {
        didSet { self.setNeedForceUpdate() }
    }
    public var buttonFiveView: ButtonView {
        didSet { self.buttonFiveItem = QLayoutItem(view: self.buttonFiveView) }
    }
    public private(set) var buttonFiveItem: QLayoutItem {
        didSet { self.setNeedForceUpdate() }
    }
    public var buttonSixView: ButtonView {
        didSet { self.buttonSixItem = QLayoutItem(view: self.buttonSixView) }
    }
    public private(set) var buttonSixItem: QLayoutItem {
        didSet { self.setNeedForceUpdate() }
    }
    public var buttonEightView: ButtonView {
        didSet { self.buttonEightItem = QLayoutItem(view: self.buttonEightView) }
    }
    public private(set) var buttonEightItem: QLayoutItem {
        didSet { self.setNeedForceUpdate() }
    }
    public var buttonNineView: ButtonView {
        didSet { self.buttonNineItem = QLayoutItem(view: self.buttonNineView) }
    }
    public private(set) var buttonNineItem: QLayoutItem {
        didSet { self.setNeedForceUpdate() }
    }
    public var buttonZeroView: ButtonView {
        didSet { self.buttonZeroItem = QLayoutItem(view: self.buttonZeroView) }
    }
    public private(set) var buttonZeroItem: QLayoutItem {
        didSet { self.setNeedForceUpdate() }
    }
    public var accessoryLeftView: AccessoryView? {
        didSet {
            if let view = self.accessoryLeftView {
                self.accessoryLeftItem = QLayoutItem(view: view)
            } else {
                self.accessoryLeftItem = nil
            }
        }
    }
    public private(set) var accessoryLeftItem: QLayoutItem? {
        didSet { self.setNeedForceUpdate() }
    }
    public var accessoryRightView: AccessoryView? {
        didSet {
            if let view = self.accessoryRightView {
                self.accessoryRightItem = QLayoutItem(view: view)
            } else {
                self.accessoryRightItem = nil
            }
        }
    }
    public private(set) var accessoryRightItem: QLayoutItem? {
        didSet { self.setNeedForceUpdate() }
    }
    
    public init(
        titleInset: QInset,
        titleView: TitleView,
        pincodeInset: QInset,
        pincodeView: PincodeView,
        errorInset: QInset,
        errorView: ErrorView? = nil,
        buttonsInset: QInset,
        buttonsSpacing: QPoint,
        buttonsAspectRatio: Float,
        buttonOneView: ButtonView,
        buttonTwoView: ButtonView,
        buttonThreeView: ButtonView,
        buttonFourView: ButtonView,
        buttonFiveView: ButtonView,
        buttonSixView: ButtonView,
        buttonEightView: ButtonView,
        buttonNineView: ButtonView,
        buttonZeroView: ButtonView,
        accessoryLeftView: AccessoryView? = nil,
        accessoryRightView: AccessoryView? = nil
    ) {
        self.titleInset = titleInset
        self.titleView = titleView
        self.titleItem = QLayoutItem(view: titleView)
        self.pincodeInset = pincodeInset
        self.pincodeView = pincodeView
        self.pincodeItem = QLayoutItem(view: pincodeView)
        self.errorInset = errorInset
        self.errorView = errorView
        if let view = errorView {
            self.errorItem = QLayoutItem(view: view)
        }
        self.buttonsInset = buttonsInset
        self.buttonsSpacing = buttonsSpacing
        self.buttonsAspectRatio = buttonsAspectRatio
        self.buttonOneView = buttonOneView
        self.buttonOneItem = QLayoutItem(view: buttonOneView)
        self.buttonTwoView = buttonTwoView
        self.buttonTwoItem = QLayoutItem(view: buttonTwoView)
        self.buttonThreeView = buttonThreeView
        self.buttonThreeItem = QLayoutItem(view: buttonThreeView)
        self.buttonFourView = buttonFourView
        self.buttonFourItem = QLayoutItem(view: buttonFourView)
        self.buttonFiveView = buttonFiveView
        self.buttonFiveItem = QLayoutItem(view: buttonFiveView)
        self.buttonSixView = buttonSixView
        self.buttonSixItem = QLayoutItem(view: buttonSixView)
        self.buttonEightView = buttonEightView
        self.buttonEightItem = QLayoutItem(view: buttonEightView)
        self.buttonNineView = buttonNineView
        self.buttonNineItem = QLayoutItem(view: buttonNineView)
        self.buttonZeroView = buttonZeroView
        self.buttonZeroItem = QLayoutItem(view: buttonZeroView)
        self.accessoryLeftView = accessoryLeftView
        if let view = accessoryLeftView {
            self.accessoryLeftItem = QLayoutItem(view: view)
        }
        self.accessoryRightView = accessoryRightView
        if let view = accessoryRightView {
            self.accessoryRightItem = QLayoutItem(view: view)
        }
    }
    
    public func layout(bounds: QRect) -> QSize {
        var origin = bounds.origin.y
        do {
            let item = self.titleItem
            let inset = self.titleInset
            let size = item.size(bounds.size.apply(inset: inset))
            item.frame = QRect(
                x: bounds.origin.x + inset.left,
                y: origin + inset.top,
                width: bounds.size.width - (inset.left + inset.right),
                height: size.height
            )
            origin += inset.top + size.height + inset.bottom
        }
        do {
            let item = self.pincodeItem
            let inset = self.pincodeInset
            let size = item.size(bounds.size.apply(inset: inset))
            item.frame = QRect(
                x: bounds.origin.x + inset.left,
                y: origin + inset.top,
                width: bounds.size.width - (inset.left + inset.right),
                height: size.height
            )
            origin += inset.top + size.height + inset.bottom
        }
        if let item = self.errorItem {
            let inset = self.errorInset
            let size = item.size(bounds.size.apply(inset: inset))
            item.frame = QRect(
                x: bounds.origin.x + inset.left,
                y: origin + inset.top,
                width: bounds.size.width - (inset.left + inset.right),
                height: size.height
            )
            origin += inset.top + size.height + inset.bottom
        }
        do {
            let inset = self.buttonsInset
            let rect = QRect(
                x: bounds.origin.x + inset.left,
                y: origin + inset.top,
                width: bounds.size.width - (inset.left + inset.right),
                height: bounds.size.height - origin - (inset.left + inset.right)
            )
            let grid = rect.grid(rows: 4, columns: 3, spacing: self.buttonsSpacing)
            self.buttonOneItem.frame = grid[0]
            self.buttonTwoItem.frame = grid[1]
            self.buttonThreeItem.frame = grid[3]
            self.buttonFourItem.frame = grid[4]
            self.buttonFiveItem.frame = grid[5]
            self.buttonSixItem.frame = grid[6]
            self.buttonEightItem.frame = grid[7]
            self.buttonNineItem.frame = grid[8]
            self.buttonZeroItem.frame = grid[10]
            if let item = self.accessoryLeftItem {
                item.frame = grid[9]
            }
            if let item = self.accessoryRightItem {
                item.frame = grid[11]
            }
        }
        return bounds.size
    }
    
    public func size(_ available: QSize) -> QSize {
        guard available.width > 0 else {
            return .zero
        }
        var result = QSize(
            width: available.width,
            height: 0
        )
        let titleSize = self.titleItem.size(available.apply(inset: self.titleInset))
        result.height += self.titleInset.top + titleSize.height + self.titleInset.bottom
        let pincodeSize = self.pincodeItem.size(available.apply(inset: self.pincodeInset))
        result.height += self.pincodeInset.top + pincodeSize.height + self.pincodeInset.bottom
        if let errorItem = self.errorItem {
            let errorSize = errorItem.size(available.apply(inset: self.errorInset))
            result.height += self.errorInset.top + errorSize.height + self.errorInset.bottom
        }
        let availableButtonsWidth = available.width - (self.buttonsInset.left + self.buttonsInset.right)
        let buttonsWidth = (availableButtonsWidth / 3) - (self.buttonsSpacing.x * 2)
        let buttonsHeight = buttonsWidth * self.buttonsAspectRatio
        result.height += self.buttonsInset.top + (buttonsHeight * 3) + (self.buttonsSpacing.y * 3) + self.buttonsInset.bottom
        return result
    }
    
    public func items(bounds: QRect) -> [QLayoutItem] {
        var items: [QLayoutItem] = [
            self.titleItem,
            self.pincodeItem,
        ]
        if let item = self.errorItem {
            items.append(item)
        }
        items.append(contentsOf: [
            self.buttonOneItem,
            self.buttonTwoItem,
            self.buttonThreeItem,
            self.buttonFourItem,
            self.buttonFiveItem,
            self.buttonSixItem,
            self.buttonEightItem,
            self.buttonNineItem,
            self.buttonZeroItem
        ])
        if let item = self.accessoryLeftItem {
            items.append(item)
        }
        if let item = self.accessoryRightItem {
            items.append(item)
        }
        return items
    }
    
}
