//
//  Storage.swift
//  Wintersweet
//
//  Created by Condy on 2023/3/23.
//  

import Foundation
import CoreFoundation

public final class Storage<T: Codable> {
    
    public lazy var disk: Disk = Disk()
    public lazy var memory: Memory = Memory()
    
    lazy var transformer = TransformerFactory.forCodable(ofType: T.self)
    let backgroundQueue: DispatchQueue
    
    init(queue: DispatchQueue? = nil) {
        self.backgroundQueue = queue ?? {
            /// Create a background thread.
            DispatchQueue(label: "com.condy.wintersweet.cached.queue", qos: .background, attributes: [.concurrent])
        }()
    }
    
    /// Caching object.
    public func storeCached(_ object: T, forKey key: String, options: CachedOptions = .all) {
        guard let data = try? transformer.toData(object) else {
            return
        }
        store(key: key, value: data, options: options)
    }
    
    /// Read cached object.
    public func fetchCached(forKey key: String, options: CachedOptions = .all) -> T? {
        /// 过期清除缓存
        if disk.isExpired(forKey: key), disk.removeObjectCache(key) {
            return nil
        }
        guard let data = read(key: key, options: options) else {
            return nil
        }
        return try? transformer.fromData(data)
    }
    
    /// Read disk data or memory data.
    public func read(key: String, options: CachedOptions = .all) -> Data? {
        switch options {
        case .none:
            return nil
        case .memory:
            return memory.memoryCacheData(key: key)
        case .disk:
            return disk.diskCacheData(key: key)
        case .all:
            if let data = memory.memoryCacheData(key: key) {
                return data
            } else {
                return disk.diskCacheData(key: key)
            }
        default:
            return nil
        }
    }
    
    /// Storage data asynchronously to disk and memory.
    public func store(key: String, value: Data, options: CachedOptions = .all) {
        backgroundQueue.async {
            switch options {
            case .none:
                break
            case .memory:
                self.memory.store2Memory(with: value, key: key)
            case .disk:
                self.disk.store2Disk(with: value, key: key)
            case .all:
                self.memory.store2Memory(with: value, key: key)
                self.disk.store2Disk(with: value, key: key)
            default:
                break
            }
        }
    }
    
    /// Remove disk cache and memory cache.
    public func removedDiskAndMemoryCached(completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        backgroundQueue.async {
            self.disk.removeAllDiskCache { isSuccess in
                DispatchQueue.main.async { completion?(isSuccess) }
            }
            self.memory.removeAllMemoryCache()
        }
    }
}
