//
//  libQuicklyCore
//

import Foundation

public extension String {

    func remove(_ characterSet: CharacterSet) -> String {
        return self.components(separatedBy: characterSet).joined()
    }

    func replace(keys: [String : String]) -> String {
        var result = self
        keys.forEach { (key: String, value: String) in
            if let range = result.range(of: key) {
                result.replaceSubrange(range, with: value)
            }
        }
        return result
    }

    func applyMask(mask: String) -> String {
        var result = String()
        var maskIndex = mask.startIndex
        let maskEndIndex = mask.endIndex
        if self.count > 0 {
            var selfIndex = self.startIndex
            let selfEndIndex = self.endIndex
            while maskIndex < maskEndIndex {
                if mask[maskIndex] == "#" {
                    result.append(self[selfIndex])
                    selfIndex = self.index(selfIndex, offsetBy: 1)
                    if selfIndex >= selfEndIndex {
                        break
                    }
                } else {
                    result.append(mask[maskIndex])
                }
                maskIndex = mask.index(maskIndex, offsetBy: 1)
            }
            while selfIndex < selfEndIndex {
                result.append(self[selfIndex])
                selfIndex = self.index(selfIndex, offsetBy: 1)
            }
        } else {
            while maskIndex < maskEndIndex {
                if mask[maskIndex] != "#" {
                    result.append(mask[maskIndex])
                } else {
                    break
                }
                maskIndex = mask.index(maskIndex, offsetBy: 1)
            }
        }
        return result
    }

    var md2: String? {
        if let data = self.data(using: .utf8) {
            return data.md2.hexString
        }
        return nil
    }

    var md4: String? {
        if let data = self.data(using: .utf8) {
            return data.md4.hexString
        }
        return nil
    }

    var md5: String? {
        if let data = self.data(using: .utf8) {
            return data.md5.hexString
        }
        return nil
    }

    var sha1: String? {
        if let data = self.data(using: .utf8) {
            return data.sha1.hexString
        }
        return nil
    }

    var sha224: String? {
        if let data = self.data(using: .utf8) {
            return data.sha224.hexString
        }
        return nil
    }

    var sha256: String? {
        if let data = self.data(using: .utf8) {
            return data.sha256.hexString
        }
        return nil
    }

    var sha384: String? {
        if let data = self.data(using: .utf8) {
            return data.sha384.hexString
        }
        return nil
    }
    
    var sha512: String? {
        if let data = self.data(using: .utf8) {
            return data.sha512.hexString
        }
        return nil
    }

    func components(pairSeparatedBy: String, valueSeparatedBy: String) -> [String: Any] {
        var components: [String: Any] = [:]
        for keyValuePair in self.components(separatedBy: pairSeparatedBy) {
            let pair = keyValuePair.components(separatedBy: valueSeparatedBy)
            if pair.count > 1 {
                guard
                    let key = pair.first!.removingPercentEncoding,
                    let value = pair.last!.removingPercentEncoding else {
                    continue
                }
                let existValue = components[key]
                if let existValue = existValue {
                    if var existValueArray = existValue as? [String] {
                        existValueArray.append(value)
                        components[key] = existValueArray
                    } else if let existValueString = existValue as? String {
                        components[key] = [existValueString, value]
                    }
                } else {
                    components[key] = value
                }
            }
        }
        return components
    }

    func range(from nsRange: NSRange) -> Range< Index >? {
        return Range< Index >(nsRange, in: self)
    }

    func nsRange(from range: Range< Index >) -> NSRange {
        guard
            let from = range.lowerBound.samePosition(in: utf16),
            let to = range.upperBound.samePosition(in: utf16)
            else {
                return NSRange()
        }
        return NSRange(
            location: utf16.distance(from: utf16.startIndex, to: from),
            length: utf16.distance(from: from, to: to)
        )
    }

}
