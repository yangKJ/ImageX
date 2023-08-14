# ImageX

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/yangKJ/ImageX)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ImageX.svg?style=flat&label=ImageX&colorA=28a745&&colorB=4E4E4E)](https://cocoapods.org/pods/ImageX)
![Platform](https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS-4E4E4E.svg?colorA=28a745)

[**ImageX**](https://github.com/yangKJ/ImageX)是一款快速让控件播放GIF和添加滤镜的框架，核心其实就是使用[**CADisplayLink**](https://github.com/yangKJ/Harbeth/blob/master/Sources/Basic/Setup/DisplayLink.swift)不断刷新和更新GIF帧图。

-------

[**English**](README.md) | 简体中文

### 功能

- 支持全平台系统，macOS、iOS、tvOS、watchOS；
- 支持播放本地和网络GIF动图；
- 支持同链接地址网络共享，不会多次下载同一资源数据；
- 支持 [**NSImageView 或 UIImageView**](https://github.com/yangKJ/ImageX/blob/master/Sources/Extensions/UIImageView+Ext.swift) 显示网络图像或GIF并添加 [**Harbeth**](https://github.com/yangKJ/Harbeth) 滤镜；
- 支持 [**UIButton 或 NSButton**](https://github.com/yangKJ/ImageX/blob/master/Sources/Extensions/UIButton+Ext.swift) 显示和下载图像并添加滤镜；
- 支持任何控件并使用协议 [**AsAnimatable**](https://github.com/yangKJ/ImageX/blob/master/Sources/Animated/AsAnimatable.swift) 即可快速达到支持播放GIF功能；
- 支持六种 [**ContentMode**](https://github.com/yangKJ/ImageX/blob/master/Sources/Base/ResizingMode.swift) 图片或GIF内容填充模式；
- 支持缓存 [**Cached**](https://github.com/yangKJ/ImageX/blob/master/Sources/Cache/Cached.swift) 网络图片或GIF数据，指定时间空闲时刻清理过期数据；
- 支持磁盘和内存缓存网络数据，提供多种命名加密 [**Crypto**](https://github.com/yangKJ/ImageX/blob/master/Sources/Base/CryptoType.swift) 方式；
- 支持缓存数据再次压缩，占用更小的磁盘空间，例如 [**GZip**](https://github.com/yangKJ/ImageX/blob/master/Sources/Base/Zip.swift) 压缩方式；
- 支持断点续传下载网络资源数据，支持设置下载进度间隔响应时间；

😍😍😍 可以说，基本可以简单的替代 [**Kingfisher**](https://github.com/onevcat/Kingfisher)，后续再慢慢补充完善其余功能区！！!

------

### 简单使用

1. `NSImageView`或`UIImageView`显示网络图像或动图并添加过滤器。

```swift
// 简单使用如下：
let url = URL(string: "https://example.com/image.png")!
imageView.kj.setImage(with: url)
```

2. 或者设置其他参数播放GIF或下载图像。

```swift
let links = [``GIF URL``, ``Image URL``, ``GIF Named``, ``Image Named``]
let named = links.randomElement() ?? ""
var options = ImageXOptions()
options.placeholder = .image(R.image("IMG_0020")!) // 占位图
options.resizingMode = .scaleAspectBottomRight // 填充模式
options.GIFs.loop = .count(3) // 循环播放3次
options.GIFs.bufferCount = 20 // 缓存20帧
options.Cache.cacheOption = .disk // 采用磁盘缓存
options.Cache.cacheCrypto = .user { "Condy" + CryptoType.SHA.sha1(string: $0) } // 自定义加密
options.Cache.cacheDataZip = .gzip // 采用GZip方式压缩数据
options.Network.retry = .max3s // 网络失败重试
options.GIFs.setPreparationBlock(block: { [weak self] _ in
    // GIF开始准备播放时刻
})
options.GIFs.setAnimatedBlock(block: { _ in
    // GIF播放完成
})
let filters: [C7FilterProtocol] = [
    C7SoulOut(soul: 0.75), // 灵魂出窍滤镜
    C7Storyboard(ranks: 2),// 分屏滤镜
]
imageView.kj.setImage(with: named, filters: filters, options: options)
```

-----------------------------------------------------------------------------------
😘😘 其他方法:

```
/// 根据名称显示图像或GIF并添加滤镜
public func setImage(
    with named: String, 
    filters: [C7FilterProtocol], 
    options: ImageXOptions = ImageXOptions.default
)

/// 显示数据源data图像或动图并添加滤镜
public func setImage(
    with data: Data?, 
    filters: [C7FilterProtocol], 
    options: ImageXOptions = ImageXOptions.default
) -> AssetType

/// 显示网络图像或GIF并添加滤镜
public func setImage(
    with url: URL?, 
    filters: [C7FilterProtocol], 
    options: ImageXOptions = ImageXOptions.default
) -> Task?
```

2. 任意控件实现协议`AsAnimatable`均可立刻支持GIF播放，核心其实就是在`layer.contents`显示帧图。

```swift
/// 任意控件实现协议``AsAnimatable``均可支持GIF播放
class AnimatedView: UIView, AsAnimatable {
    ...
}

lazy var animatedView: AnimatedView = {
    let view = AnimatedView.init(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.layer.contentsGravity = .resizeAspect
    view.backgroundColor = UIColor.red.withAlphaComponent(0.3)
    return view
}()

let filters: [C7FilterProtocol] = [ ``Harbeth Filter`` ]
let data = R.gifData("cycling")
let options = ImageXOptions.init(loop: .count(5))
animatedView.play(data: data, filters: filters, options: options)
```

### AsAnimatable

- 只要遵循实现过该协议，即可使用播放GIF动图功能，简简单单！

```
public protocol AsAnimatable: HasAnimatable {    
    /// 动图循环的总持续时间
    var loopDuration: TimeInterval { get }
    
    /// 当前活动动图帧图
    var activeFrame: C7Image? { get }
    
    /// 动图的总帧数
    var frameCount: Int { get }
    
    /// 是否为动图
    var isAnimating: Bool { get }
    
    /// 位图内存成本，单位字节
    var cost: Int { get }
    
    /// 停止动图并从内存中释放动图数据
    func prepareForReuse()
    
    /// 开启动图
    func startAnimating()
    
    /// 停止动图
    func stopAnimating()

    /// 准备动图并开始播放动图
    /// - Parameters:
    ///   - data: 动图数据源
    ///   - filters: Harbeth滤镜添加到帧图
    ///   - options: 使用的动图播放创建其他参数选项
    func play(data: Data?, filters: [C7FilterProtocol], options: ImageXOptions)
}
```

### ResizingMode

- 主要用于图像填充内容更改大小

```
public enum ResizingMode {
    /// 原始图像的尺寸
    case original = 0
    /// 必要时通过更改内容的宽高比来缩放内容以适应自身大小的选项
    case scaleToFill = 1
    /// 内容缩放以适应固定方面。其余部分是透明的
    case scaleAspectFit = 2
    /// 内容缩放以填充固定方面。内容的某些部分可能会被剪切.
    case scaleAspectFill = 3
    /// 内容缩放以填充固定方面。内容的顶部或左侧可以裁剪.
    case scaleAspectBottomRight = 4
    /// 内容缩放以填充固定方面。内容的底部或右侧部分可以裁剪
    case scaleAspectTopLeft = 5
}
```

- scaleToFill: 拉升图片来适应控件尺寸，图像会变形；

<p align="left">
<img src="Images/scaleToFill.png" width="400" hspace="15px">
</p>

- scaleAspectFit: 保持图像宽高比例，适应控件最大尺寸；

<p align="left">
<img src="Images/scaleAspectFit.png" width="400" hspace="15px">
</p>

- scaleAspectFill: 保持图像宽高比，取图像最小边显示，多余四周部分将被裁减；

<p align="left">
<img src="Images/scaleAspectFill.png" width="400" hspace="15px">
</p>

- scaleAspectBottomRight: 保持图像宽高比，取图像最小边显示，多余顶部或左侧部分将被裁减；

<p align="left">
<img src="Images/scaleAspectBottomRight.png" width="400" hspace="15px">
</p>

- scaleAspectTopLeft: 保持图像宽高比，取图像最小边显示，多余底部或右侧部分将被裁减；

<p align="left">
<img src="Images/scaleAspectTopLeft.png" width="400" hspace="15px">
</p>

### Cached

- 网络数据缓存类型，磁盘存储使用`GZip`压缩数据，因此占用的空间更少。
- 考虑到安全问题，命名方式采用多种加密处理，例如md5、sha1、base58，以及用户自定义。
- 考虑到不同程度的安全程度，所以这里将数据源压缩和解压方式开放出来，该库提供GZip压缩或解压方式，当然用户也可以自定义。

### 关于作者
- 🎷 **邮箱地址：[ykj310@126.com](ykj310@126.com) 🎷**
- 🎸 **GitHub地址：[yangKJ](https://github.com/yangKJ) 🎸**
- 🎺 **掘金地址：[茶底世界之下](https://juejin.cn/user/1987535102554472/posts) 🎺**
- 🚴🏻 **简书地址：[77___](https://www.jianshu.com/u/c84c00476ab6) 🚴🏻**

🫰.

- 觉得有帮助的铁子，就给我点个星🌟支持一哈，谢谢铁子们～

-----
