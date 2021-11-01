//
//  libQuicklyCore
//

import Foundation

public struct QSemaVersion : Codable, Equatable, Hashable {
    
    public var major: Int
    public var minor: Int
    public var patch: Int
    public var preRelease: String
    public var build: String

    public init(_ major: Int, _ minor: Int, _ patch: Int, _ preRelease: String = "", _ build: String = "") {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.preRelease = preRelease
        self.build = build
    }
    
}

public extension QSemaVersion {
    
    var isStable: Bool {
        return self.preRelease.isEmpty == true && self.build.isEmpty == true
    }
    
    var isPreRelease: Bool {
        return self.isStable == false
    }
    
    var isMajorRelease: Bool {
        return self.isStable == true && (self.major > 0 && self.minor == 0 && self.patch == 0)
    }
    
    var isMinorRelease: Bool {
        return self.isStable == true && (self.minor > 0 && self.patch == 0)
    }
    
    var isPatchRelease: Bool {
        return self.isStable == true && self.patch > 0
    }
    
}

extension QSemaVersion : LosslessStringConvertible {
    
    public init?(_ string: String) {
        guard let version = Self._parse(string) else { return nil }
        self = version
    }

    public var description: String {
        let pre = self.preRelease.isEmpty == true ? "" : "-" + self.preRelease
        let bld = self.build.isEmpty == true ? "" : "+" + self.build
        return "\(self.major).\(self.minor).\(self.patch)\(pre)\(bld)"
    }
    
}

extension QSemaVersion : Comparable {
    
    public static func < (lhs: QSemaVersion, rhs: QSemaVersion) -> Bool {
        if lhs.major != rhs.major { return lhs.major < rhs.major }
        if lhs.minor != rhs.minor { return lhs.minor < rhs.minor }
        if lhs.patch != rhs.patch { return lhs.patch < rhs.patch }
        if lhs.preRelease != rhs.preRelease {
            if lhs.isStable { return false }
            if rhs.isStable { return true }
            return lhs.preRelease < rhs.preRelease
        }
        return lhs.build < rhs.build
    }
    
}

private extension QSemaVersion {

    static func _parse(_ string: String) -> QSemaVersion? {
        let pattern = #"""
        ^
        v?
        (?<major>0|[1-9]\d*)
        \.
        (?<minor>0|[1-9]\d*)
        \.
        (?<patch>0|[1-9]\d*)
        (?:-
          (?<prerelease>
            (?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)
            (?:\.
              (?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)
            )
          *)
        )?
        (?:\+
          (?<buildmetadata>[0-9a-zA-Z-]+
            (?:\.[0-9a-zA-Z-]+)
          *)
        )?
        $
        """#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [ .allowCommentsAndWhitespace ]) else { return nil }
        guard let match = regex.firstMatch(in: string, options: [], range: NSRange(string.startIndex..., in: string)) else { return nil }
        let groups: [String] = (1...regex.numberOfCaptureGroups).map {
            if let r = Range(match.range(at: $0), in: string) {
                return String(string[r])
            }
            return ""
        }
        guard groups.count == regex.numberOfCaptureGroups else { return nil }
        guard let major = Int(groups[0]), let minor = Int(groups[1]), let patch = Int(groups[2]) else { return nil }
        return QSemaVersion(major, minor, patch, groups[3], groups[4])
    }
    
}
