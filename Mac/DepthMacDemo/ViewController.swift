//
//  ViewController.swift
//  DepthMacDemo
//
//  Created by Condy on 2023/1/6.
//

import Cocoa
import ImageX

class GIFImageView: NSImageView {
    
}

class ViewController: NSViewController {
    
    @IBOutlet weak var imageView: GIFImageView!
    
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
            "jordan-whitt-54480", "failed_link",
            "https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/IMG_0139.gif",
            "https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/IMG_3960.heic",
            "https://raw.githubusercontent.com/yangKJ/Harbeth/master/Demo/Harbeth-iOS-Demo/Resources/Assets.xcassets/yuan002.imageset/11.jpeg",
            "https://raw.githubusercontent.com/yangKJ/Harbeth/master/Demo/Harbeth-iOS-Demo/Resources/Assets.xcassets/yuan003.imageset/12.jpeg",
            "https://media.gcflearnfree.org/content/588f55e5a0b0042cb858653b_01_30_2017/images_stock_puppy.jpg",
        ]
        let named = links.randomElement() ?? ""
        var options = AnimatedOptions()
        options.loop = .forever
        options.placeholder = .image(R.image("IMG_0020")!)
        options.contentMode = .scaleAspectBottomRight
        options.bufferCount = 20
        options.cacheOption = .disk
        options.cacheCrypto = .base58
        options.cacheDataZip = .gzip
        options.retry = DelayRetry(maxRetryCount: 2, retryInterval: .accumulated(2))
        options.setPreparationBlock(block: {
            // do something..
        })
        options.setAnimatedBlock(block: { loopDuration in
            // play is complete and then do something..
        })
        imageView.mt.setImage(named: named, filters: filters, options: options)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
