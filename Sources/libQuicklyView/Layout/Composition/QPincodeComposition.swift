//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QPincodeComposition< TitleView: IQView, PincodeView: IQView, ErrorView: IQView, ButtonView: IQView, AccessoryView: IQView > : IQLayout {
    
    public weak var delegate: IQLayoutDelegate?
    public weak var parentView: IQView?
    public var titleInset: QInset {
        didSet(oldValue) {
            guard self.titleInset != oldValue else { return }
            self.setNeedUpdate()
        }
    }
    public var titleView: TitleView {
        didSet(oldValue) {
            guard self.titleView !== oldValue else { return }
            self.titleItem = QLayoutItem(view: self.titleView)
            self.setNeedUpdate()
        }
    }
    public private(set) var titleItem: IQLayoutItem
    public var pincodeInset: QInset {
        didSet(oldValue) {
            guard self.pincodeInset != oldValue else { return }
            self.setNeedUpdate()
        }
    }
    public var pincodeView: PincodeView {
        didSet(oldValue) {
            guard self.pincodeView !== oldValue else { return }
            self.pincodeItem = QLayoutItem(view: self.pincodeView)
            self.setNeedUpdate()
        }
    }
    public private(set) var pincodeItem: IQLayoutItem
    public var errorInset: QInset {
        didSet(oldValue) {
            guard self.errorInset != oldValue else { return }
            self.setNeedUpdate()
        }
    }
    public var errorView: ErrorView? {
        didSet(oldValue) {
            guard self.errorView !== oldValue else { return }
            if let view = self.errorView {
                self.errorItem = QLayoutItem(view: view)
            } else {
                self.errorItem = nil
            }
            self.setNeedUpdate()
        }
    }
    public private(set) var errorItem: IQLayoutItem?
    public var buttonsInset: QInset {
        didSet(oldValue) {
            guard self.buttonsInset != oldValue else { return }
            self.setNeedUpdate()
        }
    }
    public var buttonsSpacing: QPoint {
        didSet(oldValue) {
            guard self.buttonsSpacing != oldValue else { return }
            self.setNeedUpdate()
        }
    }
    public var buttonsAspectRatio: QFloat {
        didSet(oldValue) {
            guard self.buttonsAspectRatio != oldValue else { return }
            self.setNeedUpdate()
        }
    }
    public var buttonOneView: ButtonView {
        didSet(oldValue) {
            guard self.buttonOneView !== oldValue else { return }
            self.buttonOneItem = QLayoutItem(view: self.buttonOneView)
            self.setNeedUpdate()
        }
    }
    public private(set) var buttonOneItem: IQLayoutItem
    public var buttonTwoView: ButtonView {
        didSet(oldValue) {
            guard self.buttonTwoView !== oldValue else { return }
            self.buttonTwoItem = QLayoutItem(view: self.buttonTwoView)
            self.setNeedUpdate()
        }
    }
    public private(set) var buttonTwoItem: IQLayoutItem
    public var buttonThreeView: ButtonView {
        didSet(oldValue) {
            guard self.buttonThreeView !== oldValue else { return }
            self.buttonThreeItem = QLayoutItem(view: self.buttonThreeView)
            self.setNeedUpdate()
        }
    }
    public private(set) var buttonThreeItem: IQLayoutItem
    public var buttonFourView: ButtonView {
        didSet(oldValue) {
            guard self.buttonFourView !== oldValue else { return }
            self.buttonFourItem = QLayoutItem(view: self.buttonFourView)
            self.setNeedUpdate()
        }
    }
    public private(set) var buttonFourItem: IQLayoutItem
    public var buttonFiveView: ButtonView {
        didSet(oldValue) {
            guard self.buttonFiveView !== oldValue else { return }
            self.buttonFiveItem = QLayoutItem(view: self.buttonFiveView)
            self.setNeedUpdate()
        }
    }
    public private(set) var buttonFiveItem: IQLayoutItem
    public var buttonSixView: ButtonView {
        didSet(oldValue) {
            guard self.buttonSixView !== oldValue else { return }
            self.buttonSixItem = QLayoutItem(view: self.buttonSixView)
            self.setNeedUpdate()
        }
    }
    public private(set) var buttonSixItem: IQLayoutItem
    public var buttonEightView: ButtonView {
        didSet(oldValue) {
            guard self.buttonEightView !== oldValue else { return }
            self.buttonEightItem = QLayoutItem(view: self.buttonEightView)
            self.setNeedUpdate()
        }
    }
    public private(set) var buttonEightItem: IQLayoutItem
    public var buttonNineView: ButtonView {
        didSet(oldValue) {
            guard self.buttonNineView !== oldValue else { return }
            self.buttonNineItem = QLayoutItem(view: self.buttonNineView)
            self.setNeedUpdate()
        }
    }
    public private(set) var buttonNineItem: IQLayoutItem
    public var buttonZeroView: ButtonView {
        didSet(oldValue) {
            guard self.buttonZeroView !== oldValue else { return }
            self.buttonZeroItem = QLayoutItem(view: self.buttonZeroView)
            self.setNeedUpdate()
        }
    }
    public private(set) var buttonZeroItem: IQLayoutItem
    public var accessoryLeftView: AccessoryView? {
        didSet(oldValue) {
            guard self.accessoryLeftView !== oldValue else { return }
            if let view = self.accessoryLeftView {
                self.accessoryLeftItem = QLayoutItem(view: view)
            } else {
                self.accessoryLeftItem = nil
            }
            self.setNeedUpdate()
        }
    }
    public private(set) var accessoryLeftItem: IQLayoutItem?
    public var accessoryRightView: AccessoryView? {
        didSet(oldValue) {
            guard self.accessoryRightView !== oldValue else { return }
            if let view = self.accessoryRightView {
                self.accessoryRightItem = QLayoutItem(view: view)
            } else {
                self.accessoryRightItem = nil
            }
            self.setNeedUpdate()
        }
    }
    public private(set) var accessoryRightItem: IQLayoutItem?
    public var items: [IQLayoutItem] {
        var items: [IQLayoutItem] = [
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
    public private(set) var size: QSize
    
    public init(
        titleInset: QInset = QInset(horizontal: 8, vertical: 4),
        titleView: TitleView,
        pincodeInset: QInset = QInset(horizontal: 8, vertical: 4),
        pincodeView: PincodeView,
        errorInset: QInset = QInset(horizontal: 8, vertical: 4),
        errorView: ErrorView? = nil,
        buttonsInset: QInset = QInset(horizontal: 8, vertical: 12),
        buttonsSpacing: QPoint = QPoint(x: 8, y: 8),
        buttonsAspectRatio: QFloat,
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
        self.size = QSize()
    }
    
    public func layout() {
        var size: QSize
        if let bounds = self.delegate?.bounds(self) {
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
            size = bounds.size
        } else {
            size = QSize()
        }
        self.size = size
    }
    
    public func size(_ available: QSize) -> QSize {
        guard available.width > 0 else {
            return QSize()
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
    
}
