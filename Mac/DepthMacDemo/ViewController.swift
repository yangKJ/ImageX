//
//  ViewController.swift
//  DepthMacDemo
//
//  Created by Condy on 2023/1/6.
//

import Cocoa
import Wintersweet

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
            "https://raw.githubusercontent.com/yangKJ/Wintersweet/master/Images/IMG_0139.gif",
            "https://raw.githubusercontent.com/yangKJ/Harbeth/master/Demo/Harbeth-iOS-Demo/Resources/Assets.xcassets/yuan002.imageset/11.jpeg",
            "https://raw.githubusercontent.com/yangKJ/Harbeth/master/Demo/Harbeth-iOS-Demo/Resources/Assets.xcassets/yuan003.imageset/12.jpeg",
            "https://raw.githubusercontent.com/yangKJ/Harbeth/master/Demo/Harbeth-iOS-Demo/Resources/Assets.xcassets/IMG_3960.imageset/IMG_3960.heic"
        ]
        let named = links.randomElement() ?? ""
        var options = AnimatedOptions(loop: .count(3),
                                      placeholder: .image(R.image("IMG_0020")!),
                                      contentMode: .scaleAspectBottomRight,
                                      bufferCount: 20,
                                      cacheOption: .disk,
                                      cacheCrypto: .base58,
                                      cacheDataZip: .gzip)
        options.setPreparationBlock(block: {
            // do something..
        })
        options.setAnimatedBlock(block: { loopDuration in
            // play is complete and then do something..
        })
        imageView.mt.displayImage(named: named, filters: filters, options: options)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
