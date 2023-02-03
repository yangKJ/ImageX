//
//  Cached.swift
//  Wintersweet
//
//  Created by Condy on 2023/1/6.
//

import Foundation
import CoreFoundation

public struct Cached {
    public struct Options: OptionSet, Hashable, Sendable {
        /// Returns a raw value.
        public let rawValue: UInt16
        
        /// Initialializes options with a given raw values.
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
        
        /// Disables memory cache reads.
        public static let disableMemoryCacheReads = Options(rawValue: 1 << 0)
        /// Disables memory cache writes.
        public static let disableMemoryCacheWrites = Options(rawValue: 1 << 1)
        /// Read and write memory cache.
        public static let usedMemoryCache = Options(rawValue: 1 << 2)
        /// Disables both memory cache reads and writes.
        public static let disableMemoryCache: Options = [.disableMemoryCacheReads, .disableMemoryCacheWrites]
    }
}

extension Cached.Options {
    public func read<T>(key: AnyObject) -> T? {
        read(key: key) as? T
    }
    
    public func read(key: AnyObject) -> AnyObject? {
        switch self {
        case .disableMemoryCacheReads, .disableMemoryCache:
            return nil
        default:
            return Cached.Shared.shared.object(forKey: key)
        }
    }
    
    public func write(key: AnyObject, value: AnyObject) {
        switch self {
        case .disableMemoryCacheWrites, .disableMemoryCache:
            break
        default:
            Cached.Shared.shared.setObject(value, forKey: key)
        }
    }
}

private extension Cached {
    private struct Shared {
        /// A singleton shared NSURL cache used for GIF from URL.
        static var shared: NSCache<AnyObject, AnyObject> {
            struct StaticSharedCache {
                static var shared: NSCache<AnyObject, AnyObject>? = NSCache()
            }
            return StaticSharedCache.shared!
        }
    }
}
