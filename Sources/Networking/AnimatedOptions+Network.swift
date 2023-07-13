//
//  AnimatedOptions+Network.swift
//  ImageX
//
//  Created by Condy on 2023/7/12.
//

import Foundation
import Lemons

extension AnimatedOptions {
    
    public struct Network {
        
        /// Weather or not we should cache the URL response. Default is ``diskAndMemory``.
        public var cacheOption: Lemons.CachedOptions = .diskAndMemory
        
        /// Network data cache naming encryption method, Default is ``md5``.
        public var cacheCrypto: Lemons.CryptoType = .md5
        
        /// Network data compression or decompression method, default ``gzip``.
        /// This operation is done in the subthread.
        public var cacheDataZip: ImageX.ZipType = .gzip
        
        /// Network max retry count and retry interval, default max retry count is ``3`` and retry ``3s`` interval mechanism.
        public var retry: ImageX.DelayRetry = .max3s
        
        /// Web images or GIFs link download priority.
        public var downloadPriority: Float = URLSessionTask.defaultPriority
        
        /// The timeout interval for the request. Defaults to 20.0
        public var timeoutInterval: TimeInterval = 20
        
        /// Network resource data download progress response interval.
        public var downloadInterval: TimeInterval = 0.02
        
        public init() { }
        
        internal var failed: ((_ error: Error) -> Void)?
        /// Network download task failure information.
        /// - Parameter block: Failed the callback.
        public mutating func setNetworkFailed(block: @escaping ((_ error: Error) -> Void)) {
            self.failed = block
        }
        
        internal var progressBlock: ((_ currentProgress: CGFloat) -> Void)?
        /// Network data task download progress.
        /// - Parameter block: Download the callback.
        public mutating func setNetworkProgress(block: @escaping ((_ currentProgress: CGFloat) -> Void)) {
            self.progressBlock = block
        }
    }
}
