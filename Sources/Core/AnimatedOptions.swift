//
//  AnimatedOptions.swift
//  ImageX
//
//  Created by Condy on 2023/2/28.
//

import Foundation
@_exported import Harbeth
@_exported import Lemons

/// Other parameters related to GIF playback.
/// Represents gif playback creating options used in ImageX.
public struct AnimatedOptions {
    
    public static var `default` = AnimatedOptions()
    
    public typealias FailedCallback = ((_ response: URLResponse?, _ error: Error?) -> Void)
    
    /// Desired number of loops. Default is ``forever``.
    public var loop: ImageX.Loop = .forever
    
    /// 如果遇见设置`original`以外其他模式显示无效`铺满屏幕`的情况，
    /// 请将承载控件``view.contentMode = .scaleAspectFit``
    /// Content mode used for resizing the frames. Default is ``original``.
    public var contentMode: ImageX.ContentMode = .original
    
    /// The number of frames to buffer. Default is 50. A high number will result in more memory usage and less CPU load, and vice versa.
    public var bufferCount: Int = 50
    
    /// Weather or not we should cache the URL response. Default is ``diskAndMemory``.
    public var cacheOption: Lemons.CachedOptions = .diskAndMemory
    
    /// Placeholder image. default gray picture.
    public var placeholder: ImageX.Placeholder = .none
    
    /// Network data cache naming encryption method, Default is ``md5``.
    public var cacheCrypto: Lemons.CryptoType = .md5
    
    /// Network data compression or decompression method, default ``gzip``.
    /// This operation is done in the subthread.
    public var cacheDataZip: ImageX.ZipType = .gzip
    
    /// Network max retry count and retry interval, default max retry count is ``3`` and retry ``3s`` interval mechanism.
    public var retry: ImageX.DelayRetry = .default
    
    /// Confirm the size to facilitate follow-up processing, Default display control size.
    public var confirmSize: CGSize = .zero
    
    /// 做组件化操作时刻，解决本地GIF或本地图片所处于另外模块从而读不出数据问题。😤
    /// Do the component operation to solve the problem that the local GIF or Image cannot read the data in another module.
    public let moduleName: String
    
    /// Instantiation of GIF configuration parameters.
    /// - Parameters:
    ///   - moduleName: Do the component operation to solve the problem that the local GIF cannot read the data in another module.
    public init(moduleName: String = "ImageX") {
        self.moduleName = moduleName
    }
    
    internal var preparation: ((_ res: ImageX.GIFResponse) -> Void)?
    /// Ready to play time callback.
    /// - Parameter block: Prepare to play the callback.
    public mutating func setPreparationBlock(block: @escaping ((_ res: ImageX.GIFResponse) -> Void)) {
        self.preparation = block
    }
    
    internal var animated: ((_ loopDuration: TimeInterval) -> Void)?
    /// GIF animation playback completed.
    /// - Parameter block: Complete the callback.
    public mutating func setAnimatedBlock(block: @escaping ((_ loopDuration: TimeInterval) -> Void)) {
        self.animated = block
    }
    
    internal var failed: AnimatedOptions.FailedCallback?
    /// Network download task failure information
    /// - Parameter block: Failed the callback.
    public mutating func setNetworkFailed(block: @escaping AnimatedOptions.FailedCallback) {
        self.failed = block
    }
    
    internal var displayed: Bool = false // 防止重复设置占位信息
    internal func setDisplayed(placeholder displayed: Bool) -> Self {
        var options = self
        options.displayed = displayed
        return options
    }
}
