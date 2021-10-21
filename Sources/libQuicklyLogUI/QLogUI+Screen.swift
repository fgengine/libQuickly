//
//  libQuicklyLogUI
//

import Foundation
import libQuicklyCore
import libQuicklyView

extension QLogUI {
    
    class Screen : IQScreen, IQScreenStackable, IQScreenViewable {
        
        let target: QLogUI.Target
        var onClose: (() -> Void)?
        
        var container: IQContainer?
        
        private(set) lazy var stackBarView = QStackBarView(
            inset: QInset(horizontal: 12, vertical: 8),
            leadingViews: [
                self._autoScrollButton
            ],
            leadingViewSpacing: 4,
            titleView: self._searchView,
            titleSpacing: 8,
            trailingViews: [
                self._closeButton
            ],
            trailingViewSpacing: 4,
            color: QColor(rgb: 0xffffff)
        )
        private(set) lazy var view: QScrollView< QListLayout > = {
            let view = QScrollView(
                direction: [ .vertical ],
                indicatorDirection: [ .vertical ],
                contentLayout: QListLayout(
                    direction: .vertical
                ),
                color: QColor(rgb: 0xffffff)
            )
            view.onBeginScrolling({ [unowned self] in
                self._autoScrollButton.isSelected = false
            })
            return view
        }()
        private(set) lazy var _searchView: QInputStringView = {
            let inputView = QInputStringView(
                width: .fill,
                height: .fixed(44),
                text: "",
                textFont: QFont(weight: .regular, size: 16),
                textColor: QColor(rgb: 0x000000),
                textInset: QInset(horizontal: 12, vertical: 4),
                editingColor: QColor(rgb: 0x000000),
                placeholder: QInputPlaceholder(
                    text: "Enter filter",
                    font: QFont(weight: .regular, size: 16),
                    color: QColor(rgb: 0xA9AEBA)
                ),
                alignment: .left,
                color: QColor(rgb: 0xffffff),
                border: .manual(width: 1, color: QColor(rgb: 0xA9AEBA)),
                cornerRadius: .manual(radius: 4)
            ).keyboard(QInputKeyboard(
                type: .default,
                appearance: .default,
                autocapitalization: .none,
                autocorrection: .no,
                spellChecking: .no,
                returnKey: .search,
                enablesReturnKeyAutomatically: false
            ))
            inputView.onPressedReturn({ [unowned self, unowned inputView] in
                self._search = inputView.text.lowercased()
                self._reload()
            })
            return inputView
        }()
        private(set) lazy var _autoScrollButton: QButtonView = {
            let backgroundView = QEmptyView(
                color: QColor(rgb: 0xFFCF38),
                cornerRadius: .manual(radius: 4)
            )
            let textView = QTextView(
                text: "▼",
                textFont: QFont(weight: .regular, size: 20),
                textColor: QColor(rgb: 0x000000)
            )
            let button = QButtonView(
                inset: QInset(horizontal: 12, vertical: 4),
                height: .fixed(44),
                backgroundView: backgroundView,
                textView: textView,
                isSelected: true
            )
            button.onChangeStyle({ [unowned button, unowned backgroundView] _ in
                if button.isSelected == true {
                    backgroundView.color = QColor(rgb: 0xFFCF38)
                } else {
                    backgroundView.color = QColor(rgb: 0xA9AEBA)
                }
            })
            button.onPressed({ [unowned button] in
                button.isSelected = !button.isSelected
                self._scrollToBottom()
            })
            return button
        }()
        private(set) lazy var _closeButton: QButtonView = {
            let backgroundView = QEmptyView(
                color: QColor(rgb: 0xA9AEBA),
                cornerRadius: .manual(radius: 4)
            )
            let textView = QTextView(
                text: "✕",
                textFont: QFont(weight: .regular, size: 20),
                textColor: QColor(rgb: 0x000000)
            )
            let button = QButtonView(
                inset: QInset(horizontal: 12, vertical: 4),
                height: .fixed(44),
                backgroundView: backgroundView,
                textView: textView
            )
            return button
        }()
        private var _entities: [Entity]
        private var _search: String?
        
        init(
            target: QLogUI.Target
        ) {
            self.target = target
            self._entities = []
        }
        
        func setup() {
            self.target.add(observer: self, priority: .userInitiated)
            
            self._closeButton.onPressed({ [unowned self] in self._pressedClose() })
        }
        
        func destroy() {
            self.target.remove(observer: self)
        }
        
        func didChangeInsets() {
            let inheritedInsets = self.inheritedInsets()
            self.view.contentInset = inheritedInsets
            self._scrollToBottom()
        }
        
        func finishShow(interactive: Bool) {
            self._reload()
        }

    }
    
}

private extension QLogUI.Screen {
    
    struct Entity {
        
        let item: QLogUI.Target.Item
        let cell: IQCellView
        
    }
    
}

private extension QLogUI.Screen {
    
    func _pressedClose() {
        self.onClose?()
    }
    
    func _scrollToBottom() {
        guard self._autoScrollButton.isSelected == true else { return }
        guard let view = self.view.contentLayout.views.last else { return }
        guard let contentOffset = self.view.contentOffset(with: view, horizontal: .leading, vertical: .trailing) else { return }
        self.view.contentOffset = contentOffset
    }
    
}

private extension QLogUI.Screen {
    
    func _reload() {
        self._entities = self._entities(self.target.items.filter({ self._filter($0) }))
        self.view.contentLayout.views = self._entities.compactMap({ $0.cell })
        self.view.layoutIfNeeded()
        self._scrollToBottom()
    }
    
    func _filter(_ item: QLogUI.Target.Item) -> Bool {
        guard let search = self._search else { return true }
        if search.count > 0 {
            if item.category.lowercased().contains(search) == true {
                return true
            } else if item.message.lowercased().contains(search) == true {
                return true
            } else {
                return false
            }
        }
        return true
    }
    
    func _entities(_ items: [QLogUI.Target.Item]) -> [Entity] {
        return items.compactMap({ self._entity($0) })
    }
    
    func _entity(_ item: QLogUI.Target.Item) -> Entity {
        return Entity(item: item, cell: self._cell(item))
    }
    
    func _cell(_ item: QLogUI.Target.Item) -> IQCellView {
        return QCellView(
            contentView: QCustomView(
                contentLayout: QCompositionLayout(
                    inset: QInset(horizontal: 12, vertical: 8),
                    entity: QCompositionLayout.HAccessory(
                        leading: QCompositionLayout.View(QEmptyView(
                            width: .fixed(4),
                            height: .fill,
                            color: self._color(item),
                            cornerRadius: .auto
                        )),
                        center: QCompositionLayout.Inset(
                            inset: QInset.init(top: 0, left: 8, right: 0, bottom: 0),
                            entity: QCompositionLayout.VStack(
                                alignment: .fill,
                                spacing: 4,
                                entities: [
                                    QCompositionLayout.View(QTextView(
                                        text: item.category,
                                        textFont: QFont(weight: .regular, size: 16),
                                        textColor: QColor(rgb: 0x000000)
                                    )),
                                    QCompositionLayout.View(QTextView(
                                        text: item.message,
                                        textFont: QFont(weight: .regular, size: 14),
                                        textColor: QColor(rgb: 0x000000)
                                    ))
                                ]
                            )
                        ),
                        filling: true
                    )
                )
            )
        )
    }
    
    func _color(_ item: QLogUI.Target.Item) -> QColor {
        switch item.level {
        case .debug: return QColor(rgb: 0x808080)
        case .info: return QColor(rgb: 0xffff00)
        case .error: return QColor(rgb: 0xff0000)
        }
    }
    
}

extension QLogUI.Screen : IQLogUITargetObserver {
    
    func append(_ target: QLogUI.Target, item: QLogUI.Target.Item) {
        let entity = self._entity(item)
        self._entities.append(entity)
        if self._filter(entity.item) == true {
            self.view.contentLayout.insert(
                index: self.view.contentLayout.items.count - 1,
                views: [ entity.cell ]
            )
            self.view.layoutIfNeeded()
            self._scrollToBottom()
        }
    }
    
    func remove(_ target: QLogUI.Target, item: QLogUI.Target.Item) {
        guard let index = self._entities.firstIndex(where: { $0.item == item }) else { return }
        let entity = self._entities.remove(at: index)
        self.view.contentLayout.delete(views: [ entity.cell ])
        self.view.layoutIfNeeded()
        self._scrollToBottom()
    }

}
