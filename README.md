# Wintersweet

<p align="left">
<img src="https://raw.githubusercontent.com/yangKJ/Wintersweet/master/Images/tutieshi_640x524_1s.gif" width="555" hspace="1px">
</p>

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/yangKJ/Wintersweet)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/Wintersweet.svg?style=flat&label=Wintersweet&colorA=28a745&&colorB=4E4E4E)](https://cocoapods.org/pods/Wintersweet)
![Platform](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS-4E4E4E.svg?colorA=28a745)

[**Wintersweet**](https://github.com/yangKJ/Wintersweet) is a library that quickly allows controls to play gifs and add filters. The core is to use CADisplayLink to constantly refresh and update gif frames.

-------

English | [**简体中文**](README_CN.md)

## Features
🧢 At the moment, the most important features of [**GIF Animatable**](https://github.com/yangKJ/Wintersweet) can be summarized as follows:

- Support full platform system，macOS、iOS、tvOS、watchOS.
- Support `NSImageView` or `UIImageView` display network image or gif and add the [Harbeth](https://github.com/yangKJ/Harbeth) filters.
- Support local and network play gif animated.
- Support any control and used the protocol [AsAnimatable](https://github.com/yangKJ/Wintersweet/blob/master/Sources/AsAnimatable.swift).
- Support six content filling modes.
- Support cache network gif data.

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
let links = [``GIF Link URL``, ``Picture Link URL``]
let URL = URL(string: links.randomElement() ?? "")!
var options = AnimatedOptions(contentMode: .scaleAspectBottomRight)
options.setAnimated { loopDuration in
    // do something..
}
imageView.mt.displayImage(url: URL, filters: filters, options: options)

-----------------------------------------------------------------------------------
😘😘 And other methods:

/// Display image or gif and add the filters.
/// - Parameters:
///   - named: Picture or gif name.
///   - filters: Harbeth filters apply to image or gif frame.
///   - options: Represents gif playback creating options used in Wintersweet.
public func displayImage(named: String, filters: [C7FilterProtocol], options: AnimatedOptions = .default)

/// Display image or gif and add the filters.
/// - Parameters:
///   - data: Picture data.
///   - filters: Harbeth filters apply to image or gif frame.
///   - options: Represents gif playback creating options used in Wintersweet.
/// - Returns: A uniform type identifier UTI.
public func displayImage(data: Data?, filters: [C7FilterProtocol], options: AnimatedOptions = .default) -> AssetType

/// Display network image or gif and add the filters.
/// - Parameters:
///   - url: Link url.
///   - filters: Harbeth filters apply to image or gif frame.
///   - options: Represents gif playback creating options used in Wintersweet.
///   - failed: Network failure callback.
/// - Returns: Current network URLSessionDataTask.
public func displayImage(url: URL, filters: [C7FilterProtocol], options: AnimatedOptions = .default, failed: FailedCallback? = nil) -> URLSessionDataTask?
```

- Any control can play the local gif data.

```swift
let filters: [C7FilterProtocol] = [ ``Harbeth Filter`` ]
let data = AnimatedOptions.gifData("cycling")
let options = AnimatedOptions.init(loop: .count(5))
animatedView.play(data: data, filters: filters, options: options)
```

- Any control implementation protocol ``AsAnimatable`` can support gif animated playback.

```swift
class GIFView: UIView, AsAnimatable {
    ...
}
```

**GIF animated support has been implemented here for [ImageView](https://github.com/yangKJ/Wintersweet/blob/master/Sources/Extensions/ImageView%2BExt.swift), so you can use it directly.✌️**

### AsAnimatable

- The protocol that view classes need to conform to to enable gif animated support.

```swift
public protocol AsAnimatable: HasAnimatable {
    
    /// Total duration of one animation loop
    var loopDuration: TimeInterval { get }
    
    /// The first frame of the current GIF.
    var fristFrame: C7Image? { get }
    
    /// Returns the active frame if available.
    var activeFrame: C7Image? { get }
    
    /// Total frame count of the GIF.
    var frameCount: Int { get }
    
    /// Introspect whether the instance is animating.
    var isAnimatingGIF: Bool { get }
    
    /// Bitmap memory cost with bytes.
    var cost: Int { get }
    
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
    ///   - options: Represents gif playback creating options used in Wintersweet.
    func play(data: Data?, filters: [C7FilterProtocol], options: AnimatedOptions)
}
```

### AnimatedOptions

- Other parameters related to GIF playback.
- Represents gif playback creating options used in Wintersweet.

```
public struct AnimatedOptions {

    public static let `default`: Wintersweet.AnimatedOptions

    /// Desired number of loops. Default  is ``forever``.
    public let loop: Wintersweet.Loop

    /// Content mode used for resizing the frames. Default is ``original``.
    public let contentMode: Wintersweet.ContentMode

    /// The number of frames to buffer. Default is 50. A high number will result in more memory usage and less CPU load, and vice versa.
    public let bufferCount: Int

    /// Weather or not we should cache the URL response. Default  is ``disableMemoryCache``.
    public let cacheOption: Wintersweet.Cached.Options

    /// Placeholder image. default gray picture.
    public var placeholder: Harbeth.C7Image? { get }

    /// Placeholder image size, default 100 x 100.
    public var placeholderSize: CGSize

    /// Ready to play time callback.
    /// - Parameter block: Ready to play time response callback.
    public mutating func setPreparation(block: @escaping Wintersweet.PreparationCallback)

    /// Be played GIF.
    /// - Parameter block: Playback complete response callback.
    public mutating func setAnimated(block: @escaping Wintersweet.AnimatedCallback)
}

extension AnimatedOptions {

    /// Load gif data.
    public static func gifData(_ named: String, forResource: String = "Wintersweet") -> Data?

    /// Load image resources
    public static func image(_ named: String, forResource: String = "Wintersweet") -> Harbeth.C7Image?
}
```

### ContentMode

- Mainly for the image filling content to change the size.

Example | ContentMode
---- | ---------
![original](https://raw.githubusercontent.com/yangKJ/Wintersweet/master/Images/original.png)|**original**<br/>Dimensions of the original image. Do nothing with it.<br/><br/>`imageView.play(... contentMode: .original)`
![scaleToFill](https://raw.githubusercontent.com/yangKJ/Wintersweet/master/Images/scaleToFill.png)|**scaleToFill**<br/>The option to scale the content to fit the size of itself by changing the aspect ratio of the content if necessary.<br/><br/>`imageView.play(... contentMode: .scaleToFill)`
![scaleAspectFit](https://raw.githubusercontent.com/yangKJ/Wintersweet/master/Images/scaleAspectFit.png)|**scaleAspectFit**<br/>Contents scaled to fit with fixed aspect. remainder is transparent.<br/><br/>`imageView.play(... contentMode: .scaleAspectFit)`
![scaleAspectFill](https://raw.githubusercontent.com/yangKJ/Wintersweet/master/Images/scaleAspectFill.png)|**scaleAspectFill**<br/>Contents scaled to fill with fixed aspect. some portion of content may be clipped.<br/><br/>`imageView.play(... contentMode: .scaleAspectFill)`
![scaleAspectBottomRight](https://raw.githubusercontent.com/yangKJ/Wintersweet/master/Images/scaleAspectBottomRight.png)|**scaleAspectBottomRight**<br/>Contents scaled to fill with fixed aspect. top or left portion of content may be clipped.<br/><br/>`imageView.play(... contentMode: .scaleAspectBottomRight)`
![scaleAspectTopLeft](https://raw.githubusercontent.com/yangKJ/Wintersweet/master/Images/scaleAspectTopLeft.png)|**scaleAspectTopLeft**<br/>Contents scaled to fill with fixed aspect. bottom or right portion of content may be clipped.<br/><br/>`imageView.play(... contentMode: .scaleAspectTopLeft)`

### Cached

- Network data caching type.

```
/// Disables memory cache reads.
public static let disableMemoryCacheReads = Options(rawValue: 1 << 0)
/// Disables memory cache writes.
public static let disableMemoryCacheWrites = Options(rawValue: 1 << 1)
/// Read and write memory cache.
public static let usedMemoryCache = Options(rawValue: 1 << 2)
/// Disables both memory cache reads and writes.
public static let disableMemoryCache: Options = //
```

### Loop

- Gif animated played count.

```
public enum Loop {
    /// Incessant cycle.
    case forever
    /// Play it once.
    case never
    /// Loop the specified ``count`` times.
    case count(_ count: Int)
}
```

### ImageContainer

- A single property protocol that animatable classes can optionally conform to. 
- Generally, controls with `image` attributes need to implement this protocol.

```
public protocol ImageContainer {
    /// Used for displaying the animation frames.
    var image: C7Image? { get set }
}

extension AsAnimatable where Self: ImageContainer {
    /// Returns the intrinsic content size based on the size of the image.
    public var intrinsicContentSize: CGSize {
        return image?.size ?? CGSize.zero
    }
}
```

## Installation

**CocoaPods**

```ruby
pod 'Wintersweet'
```

**Swift Package Manager**

```swift
dependencies: [
    .package(url: "https://github.com/yangKJ/Wintersweet.git", branch: "master"),
]
```

## Contact
- 🎷 **E-mail address: [yangkj310@gmail.com](yangkj310@gmail.com) 🎷**
- 🎸 **GitHub address: [yangKJ](https://github.com/yangKJ) 🎸**

-----

## License
Wintersweet is available under the [MIT](LICENSE) license. See the [LICENSE](LICENSE) file for more info.

-----
