//
//  libQuicklyRemoteImageView
//

import Foundation
import libQuicklyCore
import libQuicklyView

public class QRemoteImageCache {

    public private(set) var name: String
    public private(set) var memory: [String: QImage]
    public private(set) var url: URL
    
    private var _fileManager: FileManager
    private var _queue: DispatchQueue

    public init(name: String) throws {
        self.name = name
        self.memory = [:]
        self._fileManager = FileManager.default
        self._queue = DispatchQueue(label: name)
        if let cachePath = self._fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first {
            self.url = cachePath
        } else {
            self.url = URL(fileURLWithPath: NSHomeDirectory())
        }
        self.url.appendPathComponent(name)
        if self._fileManager.fileExists(atPath: self.url.path) == false {
            try self._fileManager.createDirectory(at: self.url, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
}

public extension QRemoteImageCache {
    
    static let shared: QRemoteImageCache = try! QRemoteImageCache(
        name: "QRemoteImageCache"
    )

    func isExist(query: IQRemoteImageQuery, filter: IQRemoteImageFilter? = nil) -> Bool {
        guard let key = self._key(query, filter) else {
            return false
        }
        let memoryImage = self._queue.sync(execute: { return self.memory[key] })
        if memoryImage != nil {
            return true
        }
        let url = self.url.appendingPathComponent(key)
        return self._fileManager.fileExists(atPath: url.path)
    }

    func image(query: IQRemoteImageQuery, filter: IQRemoteImageFilter? = nil) -> QImage? {
        guard let key = self._key(query, filter) else {
            return nil
        }
        let memoryImage = self._queue.sync(execute: { return self.memory[key] })
        if let image = memoryImage {
            return image
        }
        let url = self.url.appendingPathComponent(key)
        if let image = QImage(url: url) {
            self._queue.sync(execute: {
                self.memory[key] = image
            })
            return image
        }
        return nil
    }

    func set(data: Data, image: QImage, query: IQRemoteImageQuery, filter: IQRemoteImageFilter? = nil) throws {
        guard let key = self._key(query, filter) else {
            return
        }
        let url = self.url.appendingPathComponent(key)
        do {
            try data.write(to: url, options: .atomic)
            self._queue.sync(execute: {
                self.memory[key] = image
            })
        } catch let error {
            throw error
        }
    }

    func remove(query: IQRemoteImageQuery, filter: IQRemoteImageFilter? = nil) throws {
        guard let key = self._key(query, filter) else {
            return
        }
        self._queue.sync(execute: {
            _ = self.memory.removeValue(forKey: key)
        })
        let url = self.url.appendingPathComponent(key)
        if self._fileManager.fileExists(atPath: url.path) == true {
            do {
                try self._fileManager.removeItem(at: url)
            } catch let error {
                throw error
            }
        }
    }

    func cleanup(before: TimeInterval) {
        self._queue.sync(execute: {
            self.memory.removeAll()
        })
        let now = Date()
        if let urls = try? self._fileManager.contentsOfDirectory(at: self.url, includingPropertiesForKeys: nil, options: [ .skipsHiddenFiles ]) {
            for url in urls {
                guard
                    let attributes = try? self._fileManager.attributesOfItem(atPath: url.path),
                    let modificationDate = attributes[FileAttributeKey.modificationDate] as? Date
                else {
                    continue
                }
                let delta = now.timeIntervalSince1970 - modificationDate.timeIntervalSince1970
                if delta > before {
                    try? self._fileManager.removeItem(at: url)
                }
            }
        }
    }

    func didReceiveMemoryWarning() {
        self._queue.sync(execute: {
            self.memory.removeAll()
        })
    }

}

private extension QRemoteImageCache {
    
    func _key(_ query: IQRemoteImageQuery, _ filter: IQRemoteImageFilter?) -> String? {
        var key: String
        if let filter = filter {
            key = "{\(filter.name)}{\(query.key)}"
        } else {
            key = query.key
        }
        if let sha256 = key.sha256 {
            return sha256
        }
        return nil
    }
    
}
