//
//  ViewController.swift
//  DepthMacDemo
//
//  Created by Condy on 2023/1/6.
//

import Cocoa
import ImageX
import Harbeth

class GIFImageView: NSImageView {
    
}

class ViewController: NSViewController {
    
    @IBOutlet weak var imageView: GIFImageView!
    //@IBOutlet weak var imageView: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let filters: [C7FilterProtocol] = [
            C7SoulOut(soul: 0.75),
            C7ColorConvert(with: .rbga),
            C7Storyboard(ranks: 2),
            C7WhiteBalance(temperature: 5555),
        ]
        let links = [
            "failed_link",
            "https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/IMG_0139.gif",
            "https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/IMG_3960.heic",
            "https://raw.githubusercontent.com/yangKJ/Harbeth/master/Demo/Harbeth-iOS-Demo/Resources/Assets.xcassets/yuan002.imageset/11.jpeg",
            "https://raw.githubusercontent.com/yangKJ/Harbeth/master/Demo/Harbeth-iOS-Demo/Resources/Assets.xcassets/yuan003.imageset/12.jpeg",
        ]
        let named = links.randomElement() ?? ""
        var options = ImageXOptions()
        options.placeholder = .image(R.image("IMG_0020")!)
        options.contentMode = .scaleAspectBottomRight
        options.Animated.loop = .forever
        options.Animated.bufferCount = 20
        options.Cache.cacheOption = .disk
        options.Cache.cacheCrypto = .base58
        options.Cache.cacheDataZip = .gzip
        options.Network.retry = DelayRetry(maxRetryCount: 2, retryInterval: .accumulated(2))
        options.Animated.setPreparationBlock(block: { _ in
            // do something..
        })
        options.Animated.setAnimatedBlock(block: { loopDuration in
            // play is complete and then do something..
        })
        imageView.mt.setImage(with: named, filters: filters, options: options)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
