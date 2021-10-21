//
//  libQuicklyView
//

import Foundation
import libQuicklyCore

public class QStackBarView : QBarView, IQStackBarView {
    
    public var inset: QInset {
        set(value) { self._contentView.contentLayout.inset = value }
        get { return self._contentView.contentLayout.inset }
    }
    public var headerView: IQView? {
        didSet { self._relayout() }
    }
    public var headerSpacing: Float {
        didSet { self._relayout() }
    }
    public var leadingViews: [IQView] {
        didSet { self._relayout() }
    }
    public var leadingViewSpacing: Float {
        didSet { self._relayout() }
    }
    public var titleView: IQView? {
        didSet { self._relayout() }
    }
    public var titleSpacing: Float {
        didSet { self._relayout() }
    }
    public var trailingViews: [IQView] {
        didSet { self._relayout() }
    }
    public var trailingViewSpacing: Float {
        didSet { self._relayout() }
    }
    public var footerView: IQView? {
        didSet { self._relayout() }
    }
    public var footerSpacing: Float {
        didSet { self._relayout() }
    }

    private var _contentView: QCustomView< QCompositionLayout >
    
    public init(
        inset: QInset,
        headerView: IQView? = nil,
        headerSpacing: Float = 8,
        leadingViews: [IQView] = [],
        leadingViewSpacing: Float = 4,
        titleView: IQView? = nil,
        titleSpacing: Float = 4,
        trailingViews: [IQView] = [],
        trailingViewSpacing: Float = 4,
        footerView: IQView? = nil,
        footerSpacing: Float = 8,
        color: QColor? = nil,
        border: QViewBorder = .none,
        cornerRadius: QViewCornerRadius = .none,
        shadow: QViewShadow? = nil,
        alpha: Float = 1,
        isHidden: Bool = false
    ) {
        self.headerView = headerView
        self.headerSpacing = headerSpacing
        self.leadingViews = leadingViews
        self.leadingViewSpacing = leadingViewSpacing
        self.titleView = titleView
        self.titleSpacing = titleSpacing
        self.trailingViews = trailingViews
        self.trailingViewSpacing = trailingViewSpacing
        self.footerView = footerView
        self.footerSpacing = footerSpacing
        self._contentView = QCustomView(
            contentLayout: Self._layout(
                inset: inset,
                headerView: headerView,
                headerSpacing: headerSpacing,
                leadingViews: leadingViews,
                leadingViewSpacing: leadingViewSpacing,
                titleView: titleView,
                titleSpacing: titleSpacing,
                trailingViews: trailingViews,
                trailingViewSpacing: trailingViewSpacing,
                footerView: footerView,
                footerSpacing: footerSpacing
            )
        )
        super.init(
            placement: .top,
            contentView: self._contentView,
            color: color,
            border: border,
            cornerRadius: cornerRadius,
            shadow: shadow,
            alpha: alpha,
            isHidden: isHidden
        )
    }
    
    @discardableResult
    public func inset(_ value: QInset) -> Self {
        self.inset = value
        return self
    }
    
    @discardableResult
    public func headerView(_ value: IQView?) -> Self {
        self.headerView = value
        return self
    }
    
    @discardableResult
    public func headerSpacing(_ value: Float) -> Self {
        self.headerSpacing = value
        return self
    }
    
    @discardableResult
    public func leadingViews(_ value: [IQView]) -> Self {
        self.leadingViews = value
        return self
    }
    
    @discardableResult
    public func leadingViewSpacing(_ value: Float) -> Self {
        self.leadingViewSpacing = value
        return self
    }
    
    @discardableResult
    public func titleView(_ value: IQView?) -> Self {
        self.titleView = value
        return self
    }
    
    @discardableResult
    public func titleSpacing(_ value: Float) -> Self {
        self.titleSpacing = value
        return self
    }
    
    @discardableResult
    public func trailingViews(_ value: [IQView]) -> Self {
        self.trailingViews = value
        return self
    }
    
    @discardableResult
    public func trailingViewSpacing(_ value: Float) -> Self {
        self.trailingViewSpacing = value
        return self
    }
    
    @discardableResult
    public func footerView(_ value: IQView?) -> Self {
        self.footerView = value
        return self
    }
    
    @discardableResult
    public func footerSpacing(_ value: Float) -> Self {
        self.footerSpacing = value
        return self
    }
    
}

private extension QStackBarView {
    
    static func _layout(
        inset: QInset,
        headerView: IQView?,
        headerSpacing: Float,
        leadingViews: [IQView],
        leadingViewSpacing: Float,
        titleView: IQView?,
        titleSpacing: Float,
        trailingViews: [IQView],
        trailingViewSpacing: Float,
        footerView: IQView?,
        footerSpacing: Float
    ) -> QCompositionLayout {
        var vstack: [IQCompositionLayoutEntity] = []
        if let headerView = headerView {
            vstack.append(QCompositionLayout.Inset(
                inset: QInset(top: 0, left: 0, right: 0, bottom: headerSpacing),
                entity: QCompositionLayout.View(headerView)
            ))
        }
        vstack.append(QCompositionLayout.HAccessory(
            leading: QCompositionLayout.HStack(
                alignment: .fill,
                spacing: leadingViewSpacing,
                entities: leadingViews.compactMap({ QCompositionLayout.View($0) })
            ),
            center: QCompositionLayout.Inset(
                inset: QInset(
                    top: 0,
                    left: leadingViews.count > 0 ? titleSpacing : 0,
                    right: trailingViews.count > 0 ? titleSpacing : 0,
                    bottom: 0
                ),
                entity: titleView.flatMap({ QCompositionLayout.View($0) }) ?? QCompositionLayout.None()
            ),
            trailing: QCompositionLayout.HStack(
                alignment: .fill,
                spacing: trailingViewSpacing,
                entities: trailingViews.reversed().compactMap({ QCompositionLayout.View($0) })
            ),
            filling: true
        ))
        if let footerView = footerView {
            vstack.append(QCompositionLayout.Inset(
                inset: QInset(top: footerSpacing, left: 0, right: 0, bottom: 0),
                entity: QCompositionLayout.View(footerView)
            ))
        }
        return QCompositionLayout(
            inset: inset,
            entity: QCompositionLayout.VStack(
                alignment: .fill,
                entities: vstack
            )
        )
    }
    
    func _relayout() {
        self._contentView.contentLayout = Self._layout(
            inset: self.inset,
            headerView: self.headerView,
            headerSpacing: self.headerSpacing,
            leadingViews: self.leadingViews,
            leadingViewSpacing: self.leadingViewSpacing,
            titleView: self.titleView,
            titleSpacing: self.titleSpacing,
            trailingViews: self.trailingViews,
            trailingViewSpacing: self.trailingViewSpacing,
            footerView: self.footerView,
            footerSpacing: self.footerSpacing
        )
    }
    
}
