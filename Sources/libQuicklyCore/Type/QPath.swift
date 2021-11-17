//
//  libQuicklyCore
//

import Foundation

public struct QPath : Hashable {
    
    public let string: String
    
    @inline(__always)
    private init(string: String) {
        self.string = string
    }
    
    public init?(_ string: String) {
        guard string.isEmpty == false else { return nil }
        let compoments = string.components(separatedBy: "/")
        switch string.first {
        case "/":
            if compoments.isEmpty == true {
                self.string = "/"
            } else {
                self.string = Self._join(prefix: "/", components: compoments)
            }
        #if os(macOS)
        case "~":
            let home = Self._home
            if compoments.isEmpty == true {
                self.string = home
            } else {
                self.string = Self._join(prefix: home, components: compoments.dropFirst())
            }
        #endif
        default:
            return nil
        }
    }
    
}

extension QPath : ExpressibleByStringLiteral {
    
    public init(extendedGraphemeClusterLiteral path: StringLiteralType) {
        self.init(stringLiteral: path)
    }
    
    public init(unicodeScalarLiteral path: StringLiteralType) {
        self.init(stringLiteral: path)
    }
    
    public init(stringLiteral value: StringLiteralType) {
        self.init(string: value)
    }
    
}

extension QPath : Comparable {
    
    @inlinable
    public static func > (lhs: Self, rhs: Self) -> Bool {
        return lhs.string.compare(rhs.string) == .orderedDescending
    }
    
    @inlinable
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.string.compare(rhs.string) == .orderedAscending
    }
    
    @inlinable
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.string.compare(rhs.string) == .orderedSame
    }
    
}

public extension QPath {
    
    static var root: QPath {
        return QPath(string: "/")
    }
    
    #if os(macOS)
    
    static var home: QPath {
        return QPath(string: Self._home)
    }
    
    #endif
    
    static var current: QPath {
        return QPath(string: Self._current)
    }

    var isAbsolute: Bool {
        return self.string.hasPrefix("/")
    }
    
    var isRelative: Bool {
        return self.isAbsolute == false
    }
    
    var url: URL {
        return URL(fileURLWithPath: self.string)
    }
    
    var components: [String] {
        return self.string.components(separatedBy: "/")
    }
    
    func join< Compoment : StringProtocol >(_ component: Compoment) -> QPath {
        return QPath(string: Self._join(prefix: self.string, component: component))
    }
    
    func relative(to base: QPath) -> String {
        let pathComponents = Self._components(self.string)
        let baseComponents = Self._components(base.string)
        if pathComponents.starts(with: baseComponents) == true {
            let relComponents = pathComponents.dropFirst(baseComponents.count)
            return relComponents.joined(separator: "/")
        } else {
            var newPathComponents = ArraySlice(pathComponents)
            var newBaseComponents = ArraySlice(baseComponents)
            while newPathComponents.prefix(1) == newBaseComponents.prefix(1) {
                newPathComponents = newPathComponents.dropFirst()
                newBaseComponents = newBaseComponents.dropFirst()
            }
            var relComponents = Array(repeating: "..", count: newBaseComponents.count)
            relComponents.append(contentsOf: newPathComponents)
            return relComponents.joined(separator: "/")
        }
    }
    
}

private extension QPath {
    
    static var _current: String {
        return FileManager.default.currentDirectoryPath
    }
    
    #if os(macOS)
    
    static var _home: String {
        return FileManager.default.homeDirectoryForCurrentUser.path
    }
    
    #endif
    
    @inline(__always)
    static func _join< Compoment: StringProtocol >(prefix: String, component: Compoment) -> String {
        return Self._join(prefix: prefix, components: component.split(separator: "/"))
    }
    
    static func _join< Compoments: Sequence >(prefix: String, components: Compoments) -> String where Compoments.Element: StringProtocol {
        var buffer = prefix
        for component in components {
            switch component {
            case "..":
                let start = buffer.indices.startIndex
                let index = buffer.lastIndex(of: "/")!
                if start == index {
                    buffer = "/"
                } else {
                    buffer = String(buffer[start..<index])
                }
            case ".":
                break
            default:
                if buffer == "/" {
                    buffer = "/\(component)"
                } else {
                    buffer = "\(buffer)/\(component)"
                }
            }
        }
        return buffer
    }
    
    static func _components(_ string: String) -> [String] {
        let parts = string.components(separatedBy: "/")
        switch string.first {
        case "/": return [ "/" ] + parts
        default: return parts
        }
    }
    
}
