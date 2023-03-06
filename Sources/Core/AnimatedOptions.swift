//
//  AnimatedOptions.swift
//  Wintersweet
//
//  Created by Condy on 2023/2/23.
//

import Foundation
@_exported import Harbeth

public typealias PreparationCallback = (() -> Void)
public typealias AnimatedCallback = ((_ loopDuration: TimeInterval) -> Void)
public typealias FailedCallback = ((_ error: Error?) -> Void)

/// Other parameters related to GIF playback.
/// Represents gif playback creating options used in Wintersweet.
public struct AnimatedOptions {
    
    public static let `default` = AnimatedOptions()
    
    public let preparation: PreparationCallback?
    public let animated: AnimatedCallback?
    
    /// Desired number of loops. Default  is ``forever``.
    public let loop: Wintersweet.Loop
    
    /// Content mode used for resizing the frames. Default is ``original``.
    public let contentMode: Wintersweet.ContentMode
    
    /// The number of frames to buffer. Default is 50. A high number will result in more memory usage and less CPU load, and vice versa.
    public let bufferCount: Int
    
    /// Weather or not we should cache the URL response. Default is ``all``.
    public let cacheOption: Wintersweet.Cached.Options
    
    /// Placeholder image. default gray picture.
    public let placeholder: Wintersweet.Placeholder
    
    /// Instantiation of GIF configuration parameters.
    /// - Parameters:
    ///   - placeholder: Placeholder information. Default ``none``.
    ///   - loop: Desired number of loops. Default  is ``forever``.
    ///   - contentMode: Content mode used for resizing the frames. Default is ``original``.
    ///   - bufferCount: The number of frames to buffer. Default is 50. A high number will result in more memory usage and less CPU load, and vice versa.
    ///   - cacheOption: Weather or not we should cache the URL response. Default  is ``all``.
    ///   - preparation: Ready to play time callback.
    ///   - animated: Be played GIF.
    public init(placeholder: Placeholder = .none,
                loop: Loop = .forever,
                contentMode: ContentMode = .original,
                bufferCount: Int = 50,
                cacheOption: Cached.Options = .all,
                preparation: PreparationCallback? = nil,
                animated: AnimatedCallback? = nil) {
        self.loop = loop
        self.contentMode = contentMode
        self.bufferCount = bufferCount
        self.cacheOption = cacheOption
        self.placeholder = placeholder
        self.preparation = preparation
        self.animated = animated
        AnimatedOptions.setupRunloopOptimizeCleanedUpDiskCached()
    }
    
    internal var displayed: Bool = false // 防止重复设置占位信息
    internal func setDisplayed(placeholder displayed: Bool) -> Self {
        var options = self
        options.displayed = displayed
        return options
    }
}

extension AnimatedOptions {
    
    /// Have you cleaned up the disk cache in your spare time?
    public private(set) static var cleanedUpDiskCached: Bool = false
    /// Configure free time to clear the disk cache.
    public static func setupRunloopOptimizeCleanedUpDiskCached() {
        if AnimatedOptions.cleanedUpDiskCached {
            return
        }
        Cached.backgroundQueue.async {
            RunloopOptimize.default.commit { oneself in
                if AnimatedOptions.cleanedUpDiskCached {
                    oneself.removeAllTasks()
                } else {
                    Cached.Options.cleanedUpExpiredDiskCache { _ in
                        AnimatedOptions.cleanedUpDiskCached = true
                    }
                }
            }
        }
    }
}

extension R {
    
    /// Compare whether the addresses of the two objects are the same.
    public static func equateable(object1: AnyObject, object2: AnyObject) -> Bool {
        let str1 = String(describing: Unmanaged<AnyObject>.passUnretained(object1).toOpaque())
        let str2 = String(describing: Unmanaged<AnyObject>.passUnretained(object2).toOpaque())
        return str1 == str2
    }
    
    /// Read image resources
    public static func image(_ named: String) -> C7Image? {
        return Harbeth.R.image(named, forResource: "Wintersweet")
    }
    
    /// Read gif data.
    public static func gifData(_ named: String, forResource: String = "Wintersweet") -> Data? {
        let bundle: Bundle?
        if let bundlePath = Bundle.main.path(forResource: forResource, ofType: "bundle") {
            bundle = Bundle.init(path: bundlePath)
        } else {
            bundle = Bundle.main
        }
        guard let contentURL = ["gif", "GIF", "Gif"].compactMap({
            bundle?.url(forResource: named, withExtension: $0)
        }).first else {
            return nil
        }
        return try? Data(contentsOf: contentURL)
    }
}


//extension RunloopOptimize {
//    private func setupNotification() {
//        #if !os(macOS) && !os(watchOS)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(clearMemoryCache),
//                                               name: UIApplication.didReceiveMemoryWarningNotification,
//                                               object: nil)
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(backgroundCleanExpiredDiskCache),
//                                               name: UIApplication.didEnterBackgroundNotification,
//                                               object: nil)
//        #endif
//    }
//}
//
//#if !os(macOS) && !os(watchOS)
//extension RunloopOptimize {
//
//    @objc public func clearMemoryCache() {
//        Cached.Options.cleanedUpMemoryCache()
//    }
//
//    @objc public func backgroundCleanExpiredDiskCache() {
//        if cleanuped == true {
//            return
//        }
//        let selector = NSSelectorFromString("sharedApplication")
//        guard UIApplication.responds(to: selector),
//              let application = UIApplication.perform(selector).takeUnretainedValue() as? UIApplication else {
//            return
//        }
//
//        func endBackgroundTask(_ task: inout UIBackgroundTaskIdentifier) {
//            application.endBackgroundTask(task)
//            task = UIBackgroundTaskIdentifier.invalid
//        }
//
//        var backgroundTask: UIBackgroundTaskIdentifier!
//        backgroundTask = application.beginBackgroundTask {
//            endBackgroundTask(&backgroundTask)
//        }
//
//        Cached.Options.cleanedUpExpiredDiskCache(completion: {
//            endBackgroundTask(&backgroundTask)
//        })
//    }
//}
//#endif
