//
//  Cached.swift
//  Wintersweet
//
//  Created by Condy on 2023/1/6.
//

import Foundation
import CoreFoundation

public struct Cached {
    
    /// A singleton shared memory cache.
    fileprivate static var memory: NSCache<AnyObject, AnyObject> {
        struct SharedCache {
            static var shared: NSCache<AnyObject, AnyObject> = NSCache()
        }
        return SharedCache.shared
    }
    /// A singleton shared disk cache.
    fileprivate static var disk: FileManager {
        struct SharedCache {
            static var shared: FileManager = FileManager()
        }
        return SharedCache.shared
    }
    
    fileprivate static var ioQueue: DispatchQueue {
        struct SharedCache {
            static var shared: DispatchQueue = DispatchQueue(label: "com.condy.wintersweet.cached.queue")
        }
        return SharedCache.shared
    }
    
    public struct Options: OptionSet, Hashable {
        /// Returns a raw value.
        public let rawValue: UInt16
        
        /// Initialializes options with a given raw values.
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
        
        /// Do not use any cache.
        public static let none = Options(rawValue: 1 << 0)
        /// Cache the data in memory.
        public static let memory = Options(rawValue: 1 << 1)
        /// Cache the data in disk, Use ``GZip`` to compress data.
        public static let disk = Options(rawValue: 1 << 2)
        /// Use memory and disk cache at the same time to read memory first.
        public static let all: Options = [.memory, .disk]
    }
    
    /// Disk document path.
    static let diskCacheDoc: String? = {
        let domains = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)
        guard let prefix = domains.first else {
            return nil
        }
        return (prefix as NSString).appendingPathComponent("wintersweet_data_cache")
    }()
    
    /// The full path of the md5 encrypted file.
    /// - Parameter url: Link.
    /// - Returns: Cache path.
    static func diskCachePath(url: URL) -> String? {
        guard let docPath = diskCacheDoc else {
            return nil
        }
        let cacheName = Crypto.MD5.md5(string: url.absoluteString)
        let cachePath = (docPath as NSString).appendingPathComponent(cacheName)
        return (cachePath as NSString).appendingPathExtension(url.pathExtension) ?? cachePath
    }
}

extension Cached.Options {
    
    /// The longest time duration in second of the cache being stored in disk.
    /// Default is 1 week ``60 * 60 * 24 * 7 seconds``.
    /// Setting this to a negative value will make the disk cache never expiring.
    public static var maxCachePeriodInSecond: TimeInterval = 60 * 60 * 24 * 7
    
    /// The largest disk size can be taken for the cache. It is the total allocated size of cached files in bytes. Default is no limit.
    public static var maxDiskCacheSize: UInt = 0
    
    /// The largest cache cost of memory cache. The total cost is pixel count of all cached images in memory.
    /// Default is unlimited. Memory cache will be purged automatically when a memory warning notification is received.
    public static var maxMemoryCost: UInt = 0 {
        didSet {
            Cached.memory.totalCostLimit = Int(maxMemoryCost)
        }
    }
    
    /// Clear the memory cache.
    public static func cleanupMemoryCache() {
        Cached.memory.removeAllObjects()
    }
    
    /// Clear the disk cache.
    /// - Parameter completion: Complete the callback.
    public static func cleanupDiskCache(completion: (() -> Void)? = nil) {
        Cached.ioQueue.async {
            guard let docPath = Cached.diskCacheDoc else {
                return
            }
            do {
                try Cached.disk.removeItem(atPath: docPath)
                try Cached.disk.createDirectory(atPath: docPath, withIntermediateDirectories: true, attributes: nil)
            } catch { }
            DispatchQueue.main.async { completion?() }
        }
    }
}

extension Cached.Options {
    
    func read(key: URL) -> Data? {
        switch self {
        case .none:
            return nil
        case .memory:
            return Cached.memory.object(forKey: key as AnyObject) as? Data
        case .disk:
            if let cachePath = Cached.diskCachePath(url: key),
               let data = try? Data(contentsOf: URL(fileURLWithPath: cachePath)) {
                return Queen<GZip>.decompress(data: data)
            }
            return nil
        case .all:
            if let data = Cached.memory.object(forKey: key as AnyObject) as? Data {
                return data
            }
            if let cachePath = Cached.diskCachePath(url: key),
               let data = try? Data(contentsOf: URL(fileURLWithPath: cachePath)) {
                return Queen<GZip>.decompress(data: data)
            }
            return nil
        default:
            return nil
        }
    }
    
    func write(key: URL, value: Data) {
        func store2Memory(with data: Data, url: URL) {
            Cached.memory.setObject(data as NSData, forKey: url as AnyObject, cost: data.count)
        }
        func store2Disk(with data: Data, url: URL) {
            if let docPath = Cached.diskCacheDoc, !Cached.disk.fileExists(atPath: docPath) {
                let url = URL(fileURLWithPath: docPath, isDirectory: true)
                try? Cached.disk.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
            }
            guard let cachePath = Cached.diskCachePath(url: url) else {
                return
            }
            let data = Queen<GZip>.compress(data: data)
            Cached.disk.createFile(atPath: cachePath, contents: data, attributes: nil)
        }
        Cached.ioQueue.async {
            switch self {
            case .none:
                break
            case .memory:
                store2Memory(with: value, url: key)
            case .disk:
                store2Disk(with: value, url: key)
            case .all:
                store2Memory(with: value, url: key)
                store2Disk(with: value, url: key)
            default:
                break
            }
        }
    }
}
