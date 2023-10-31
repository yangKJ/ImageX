//
//  Cached.swift
//  ImageX
//
//  Created by Condy on 2023/1/6.
//

import Foundation
import CacheX

public struct CachedCodable: Codable { }

/// For the use of caching modules, please refer to CacheX for more information.
/// See: https://github.com/yangKJ/CacheX
public struct Cached {
    
    /// A singleton cache object.
    public static let shared = Cached()
    
    /// Storage container.
    public let storage: CacheX.Storage<CachedCodable>
    
    /// The name of disk storage, this will be used as folder name within directory.
    public var cachedName: String = "ImageXCached" {
        didSet {
            Cached.shared.storage.disk.named = cachedName
        }
    }
    
    /// The longest time duration in second of the cache being stored in disk. default is an week.
    public var expiry: Expiry = CacheX.Expiry.week {
        didSet {
            Cached.shared.storage.disk.expiry = expiry
        }
    }
    
    /// The largest disk size can be taken for the cache. It is the total allocated size of cached files in bytes. default 20kb.
    public var maxCountLimit: CacheX.Disk.Byte = 20 * 1024 {
        didSet {
            Cached.shared.storage.disk.maxCountLimit = maxCountLimit
        }
    }
    
    /// The largest cache cost of memory cache. The total cost is pixel count of all cached images in memory.
    /// Memory cache will be purged automatically when a memory warning notification is received.
    public var maxCostLimit: UInt = 0 {
        didSet {
            Cached.shared.storage.memory.maxCostLimit = maxCostLimit
        }
    }
    
    private init() {
        /// Create a unified background processing thread.
        let background = DispatchQueue(label: "com.condy.ImageX.cached.queue", qos: .background, attributes: [.concurrent])
        storage = Storage<CachedCodable>.init(queue: background)
        storage.disk.named = cachedName
        storage.disk.expiry = expiry
        storage.disk.maxCountLimit = maxCountLimit
        storage.memory.maxCostLimit = maxCostLimit
    }
    
    /// Clean up the data before the expiration time.
    /// - Parameters:
    ///   - expiry: Expiration time.
    ///   - completion: Clean up and complete the callback.
    public func removeExpiriedURLs(expiry: Expiry, completion: @escaping ((_ expiredURLs: [URL]) -> Void)) {
        Cached.shared.storage.backgroundQueue.async {
            let lastExpiry = Cached.shared.storage.disk.expiry
            Cached.shared.storage.disk.expiry = expiry
            Cached.shared.storage.disk.removeExpiredURLsFromDisk(completion: completion)
            Cached.shared.storage.disk.expiry = lastExpiry
        }
    }
    
    /// Have you cleaned up the disk cache in your spare time?
    private(set) static var cleanedUpDiskCached: Bool = false
    /// Clear the disk data from a week ago in your spare time.
    public static func openRunloopOptimizeTimeRemoveDiskCached() {
        if cleanedUpDiskCached {
            return
        }
        Cached.shared.storage.backgroundQueue.async {
            RunloopOptimize.default.commit { oneself in
                if Cached.cleanedUpDiskCached {
                    oneself.removeAllTasks()
                } else {
                    Cached.shared.storage.disk.removeExpiredURLsFromDisk { _ in
                        Cached.cleanedUpDiskCached = true
                    }
                }
            }
        }
    }
}
