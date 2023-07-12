# ImageX

<p align="left">
<img src="https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/tutieshi_640x524_1s.gif" width="555" hspace="1px">
</p>

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/yangKJ/ImageX)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ImageX.svg?style=flat&label=ImageX&colorA=28a745&&colorB=4E4E4E)](https://cocoapods.org/pods/ImageX)
![Platform](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS-4E4E4E.svg?colorA=28a745)

[**ImageX**](https://github.com/yangKJ/ImageX) is a powerful library that quickly allows controls to play gifs and add filters. The core is to use CADisplayLink to constantly refresh and update gif frames.

-------

English | [**简体中文**](README_CN.md)

## Features
🧢 At the moment, the most important features of [**GIF Animatable**](https://github.com/yangKJ/ImageX) can be summarized as follows:

- Support more platform system，macOS、iOS、tvOS、watchOS.
- Support local and network play gifs animated.
- Support asynchronous downloading and caching images or gifs from the web.
- Support network sharing with the same link url, and will not download the same resource data multiple times.
- Support breakpoint continuous transmission and download of network resource data.
- Support any control play gif if used the protocol [AsAnimatable](https://github.com/yangKJ/ImageX/blob/master/Sources/AsAnimatable.swift).
- Support extension `NSImageView` or `UIImageView`,`UIButton`,`NSButton`,`WKInterfaceImage` display image or gif and add the filters.
- Support six image or gif content modes.
- Support disk and memory cached network data, And the data is compressed by GZip.
- Support secondary compression of cache data, occupying less disk space.
- Support clean up disk expired data in your spare time and size limit.
- Support setting different types of named encryption methods, Such as md5, sha1, base58, And user defined.
- Support to set the response time of download progress interval.

------

## Requirements

| iOS Target | macOS Target | Xcode Version | Swift Version |
|:---:|:---:|:---:|:---:|
| iOS 10.0+ | macOS 10.13+ | Xcode 10.0+ | Swift 5.0+ |

## Support the Project
Buy me a coffee or support me on [GitHub](https://github.com/sponsors/yangKJ?frequency=one-time&sponsor=yangKJ).

<a href="https://www.buymeacoffee.com/yangkj3102">
<img width=25% alt="yellow-button" src="https://user-images.githubusercontent.com/1888355/146226808-eb2e9ee0-c6bd-44a2-a330-3bbc8a6244cf.png">
</a>

------

## Usage

- `NSImageView` or `UIImageView` display network image or gif and add the filters.

```swift
// Set image from a url.
let url = URL(string: "https://example.com/image.png")!
imageView.mt.setImage(with: url)
```

- Or set other parameters play gif or downloading image.

```swift
var options = AnimatedOptions(moduleName: "Component Name")
options.loop = .count(3)
options.placeholder = .image(R.image("AppIcon")!)
options.contentMode = .scaleAspectBottomRight
options.bufferCount = 20
options.cacheOption = .disk
options.cacheCrypto = .md5
options.cacheDataZip = .gzip
options.retry = .max3s
options.setPreparationBlock(block: { [weak self] _ in
    // do something..
})
options.setAnimatedBlock(block: { _ in
    // play is complete and then do something..
})
options.setNetworkProgress(block: { _ in
    // download progress..
})
options.setNetworkFailed(block: { _, _ in
    // download failed.
})

let links = [``GIF URL``, ``Image URL``, ``GIF Named``, ``Image Named``]
let named = links.randomElement() ?? ""
// Setup filters.
let filters: [C7FilterProtocol] = [
    C7SoulOut(soul: 0.75),
    C7Storyboard(ranks: 2),
]
imageView.mt.setImage(with: named, filters: filters, options: options)
```

----------------------------------------------------------------
😘😘 And other methods:

```
/// Display image or gif and add the filters.
/// - Parameters:
///   - named: Picture or gif name.
///   - filters: Harbeth filters apply to image or gif frame.
///   - options: Represents gif playback creating options used in ImageX.
public func setImage(
    with named: String, 
    filters: [C7FilterProtocol], 
    options: AnimatedOptions = AnimatedOptions.default
)

/// Display image or gif and add the filters.
/// - Parameters:
///   - data: Picture data.
///   - filters: Harbeth filters apply to image or gif frame.
///   - options: Represents gif playback creating options used in ImageX.
/// - Returns: A uniform type identifier UTI.
public func setImage(
    with data: Data?, 
    filters: [C7FilterProtocol], 
    options: AnimatedOptions = AnimatedOptions.default
) -> AssetType

/// Display network image or gif and add the filters.
/// - Parameters:
///   - url: Link url.
///   - filters: Harbeth filters apply to image or gif frame.
///   - options: Represents gif playback creating options used in ImageX.
/// - Returns: Current network URLSessionDataTask.
public func setImage(
    with url: URL?, 
    filters: [C7FilterProtocol], 
    options: AnimatedOptions = AnimatedOptions.default
) -> Task?
```

- Any control can play the local gif data.

```swift
let filters: [C7FilterProtocol] = [ ``Harbeth Filter`` ]
let data = R.gifData(``GIF Name``)
let options = AnimatedOptions(loop: .count(5), placeholder: .color(.cyan))
animatedView.play(data: data, filters: filters, options: options)
```

- Any control implementation protocol ``AsAnimatable`` can support gif animated playback.

```swift
class AnimatedView: UIView, AsAnimatable {
    ...
}
```

**GIF animated support has been implemented here for [**ImageView**](https://github.com/yangKJ/ImageX/blob/master/Sources/Extensions/UIImageView%2BExt.swift) , so you can use it directly.✌️**

### ContentMode

- Mainly for the image filling content to change the size.

Example | ContentMode
---- | ---------
![original](https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/original.png)|**original**<br/>Dimensions of the original image. Do nothing with it.<br/><br/>`AnimatedOptions(contentMode: .original)`
![scaleToFill](https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/scaleToFill.png)|**scaleToFill**<br/>The option to scale the content to fit the size of itself by changing the aspect ratio of the content if necessary.<br/><br/>`AnimatedOptions(contentMode: .scaleToFill)`
![scaleAspectFit](https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/scaleAspectFit.png)|**scaleAspectFit**<br/>Contents scaled to fit with fixed aspect. remainder is transparent.<br/><br/>`AnimatedOptions(contentMode: .scaleAspectFit)`
![scaleAspectFill](https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/scaleAspectFill.png)|**scaleAspectFill**<br/>Contents scaled to fill with fixed aspect. some portion of content may be clipped.<br/><br/>`AnimatedOptions(contentMode: .scaleAspectFill)`
![scaleAspectBottomRight](https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/scaleAspectBottomRight.png)|**scaleAspectBottomRight**<br/>Contents scaled to fill with fixed aspect. top or left portion of content may be clipped.<br/><br/>`AnimatedOptions(contentMode: .scaleAspectBottomRight)`
![scaleAspectTopLeft](https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/scaleAspectTopLeft.png)|**scaleAspectTopLeft**<br/>Contents scaled to fill with fixed aspect. bottom or right portion of content may be clipped.<br/><br/>`AnimatedOptions(contentMode: .scaleAspectTopLeft)`

### AnimatedOptions

- Other parameters related to GIF playback.
- Represents gif playback creating options used in ImageX.

```swift
public struct AnimatedOptions {
    
    public static let `default` = AnimatedOptions()
    
    /// Desired number of loops. Default is ``forever``.
    public var loop: ImageX.Loop = .forever
    
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
    public var retry: ImageX.DelayRetry = .max3s
    
    /// Confirm the size to facilitate follow-up processing, Default display control size.
    public var confirmSize: CGSize = .zero
    
    /// Web images or GIFs link download priority.
    public var downloadPriority: Float = URLSessionTask.defaultPriority
    
    /// The timeout interval for the request. Defaults to 20.0
    public var timeoutInterval: TimeInterval = 20
    
    /// 做组件化操作时刻，解决本地GIF或本地图片所处于另外模块从而读不出数据问题。😤
    /// Do the component operation to solve the problem that the local GIF or Image cannot read the data in another module.
    public let moduleName: String
}
```

### AsAnimatable

- The protocol that view classes need to conform to to enable gif animated support.

```swift
public protocol AsAnimatable: HasAnimatable {
    
    /// Total duration of one animation loop.
    var loopDuration: TimeInterval { get }
    
    /// The first frame that is not nil of GIF.
    var fristFrame: C7Image? { get }
    
    /// Returns the active frame if available.
    var activeFrame: C7Image? { get }
    
    /// Total frame count of the GIF.
    var frameCount: Int { get }
    
    /// Introspect whether the instance is animating.
    var isAnimatingGIF: Bool { get }
    
    /// Bitmap memory cost with bytes.
    var costGIF: Int { get }
    
    /// Stop animating and free up GIF data from memory.
    func prepareForReuseGIF()
    
    /// Start animating GIF.
    func startAnimatingGIF()
    
    /// Stop animating GIF.
    func stopAnimatingGIF()
    
    /// Prepare for animation and start play GIF.
    /// - Parameters:
    ///   - data: gif data.
    ///   - filters: Harbeth filters apply to image or gif frame.
    ///   - options: Represents gif playback creating options used in ImageX.
    func play(data: Data?, filters: [C7FilterProtocol], options: AnimatedOptions)
}
```

### Cached

- Network data caching type. There are two modes: memory and disk storage.
- Among them, the disk storage uses GZip to compress data, so it will occupy less space.
- Support setting different types of named encryption methods, such as md5, sha1, base58, And user defined.
- Considering different degrees of security, the data source compression and decompression method is opened here. The library provides [GZip](https://github.com/yangKJ/ImageX/blob/master/Sources/Core/Zip.swift) compression or decompression. Of course, users can also customize it.

## Installation

**CocoaPods**

```ruby
pod 'ImageX'
```

**Swift Package Manager**

```swift
dependencies: [
    .package(url: "https://github.com/yangKJ/ImageX.git", branch: "master"),
]
```

## Contact
- 🎷 **E-mail address: [yangkj310@gmail.com](yangkj310@gmail.com) 🎷**
- 🎸 **GitHub address: [yangKJ](https://github.com/yangKJ) 🎸**

-----

## License
ImageX is available under the [MIT](LICENSE) license. See the [LICENSE](LICENSE) file for more info.

-----
