//
//  AnimatedOptions.swift
//  ImageX
//
//  Created by Condy on 2023/2/28.
//

import Foundation

/// Other parameters related to GIF playback.
/// Represents gif playback creating options used in ImageX.
public struct AnimatedOptions {
    
    public static var `default` = AnimatedOptions()
    
    /// Additional parameters that need to be set to play GIFs.
    public var GIFs: AnimatedOptions.GIFs = AnimatedOptions.GIFs.init()
    
    /// Download additional parameters that need to be configured to download network resources.
    public var Network: AnimatedOptions.Network = AnimatedOptions.Network.init()
    
    /// 如果遇见设置`original`以外其他模式显示无效`铺满屏幕`的情况，
    /// 请将承载控件``view.contentMode = .scaleAspectFit``
    /// Content mode used for resizing the frames. Default is ``original``.
    public var contentMode: ImageX.ContentMode = .original
    
    /// Placeholder image. default gray picture.
    public var placeholder: ImageX.Placeholder = .none
    
    /// Confirm the size to facilitate follow-up processing, Default display control size.
    public var confirmSize: CGSize = .zero
    
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
        var options = self
        options.displayed = displayed
        return options
    }
}
