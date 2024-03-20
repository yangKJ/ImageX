//
//  ImageXOptions.swift
//  ImageX
//
//  Created by Condy on 2023/2/28.
//

import Foundation
import Harbeth

public typealias ResizingMode = Harbeth.ResizingMode

/// Other parameters related to animated images playback.
/// Represents creating options used in ImageX.
public struct ImageXOptions {
    
    public static var `default` = ImageXOptions()
    
    /// Additional parameters that need to be set to play animated images.
    public var Animated: ImageXOptions.Animated = ImageXOptions.Animated.init()
    
    /// Download additional parameters that need to be configured to download network resources.
    public var Network: ImageXOptions.Network = ImageXOptions.Network.init()
    
    /// Caching data from the web need to be configured parameters.
    public var Cache: ImageXOptions.Cache = ImageXOptions.Cache.init()
    
    /// Appoint the decode or encode coder.
    public var appointCoder: ImageCodering?
    
    /// Placeholder image. default gray picture.
    public var placeholder: ImageX.Placeholder = .none
    
    /// Content mode used for resizing the frame image.
    /// When this property is `original`, modifying the thumbnail pixel size will not work.
    public var resizingMode: ImageX.ResizingMode = .original
    
    /// Whether or not to generate the thumbnail images.
    /// Defaults to CGSizeZero, Then take the size of the displayed control size as the thumbnail pixel size.
    public var thumbnailPixelSize: CGSize = .zero
    
    /// 做组件化操作时刻，解决本地GIF或本地图片所处于另外模块从而读不出数据问题。😤
    /// Do the component operation to solve the problem that the local GIF or Image cannot read the data in another module.
    public let moduleName: String
    
    /// Instantiation of configuration parameters.
    /// - Parameters:
    ///   - moduleName: Do the component operation to solve the problem that the local GIF or image cannot read the data in another module.
    public init(moduleName: String = "ImageX") {
        self.moduleName = moduleName
    }
    
    internal var displayed: Bool = false // 防止重复设置占位信息
    internal func setDisplayed(placeholder displayed: Bool) -> Self {
        self.mutating { $0.displayed = displayed }
    }
}

extension ImageXOptions {
    
    /// Set up decoder parameters
    func setupDecoderOptions(_ filters: [C7FilterProtocol], finished: Bool) -> ImageCodering.ImageCoderOptions {
        return [
            CoderOptions.decoder.frameTypeKey : self.Animated.frameType,
            CoderOptions.decoder.thumbnailPixelSizeKey : thumbnailPixelSize,
            CoderOptions.decoder.resizingModeKey : resizingMode,
            CoderOptions.decoder.filtersKey : filters,
            CoderOptions.decoder.completeDataKey : finished,
        ] as ImageCodering.ImageCoderOptions
    }
    
    func mutating(_ block: (inout ImageXOptions) -> Void) -> ImageXOptions {
        var options = self
        block(&options)
        return options
    }
}
