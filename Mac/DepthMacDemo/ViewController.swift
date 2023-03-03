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
        ]
        let links = [
            "https://raw.githubusercontent.com/yangKJ/Wintersweet/master/Images/IMG_0139.gif",
            "https://raw.githubusercontent.com/yangKJ/Harbeth/master/Demo/Harbeth-iOS-Demo/Resources/Assets.xcassets/yuan002.imageset/11.jpeg",
            "https://raw.githubusercontent.com/yangKJ/Harbeth/master/Demo/Harbeth-iOS-Demo/Resources/Assets.xcassets/yuan003.imageset/12.jpeg",
            //"https://raw.githubusercontent.com/yangKJ/Harbeth/master/Demo/Harbeth-iOS-Demo/Resources/Assets.xcassets/IMG_3960.imageset/IMG_3960.heic"
        ]
        let URL = URL(string: links.randomElement() ?? "")!
        let options = AnimatedOptions(placeholder: .image(R.image("IMG_0020")!), contentMode: .scaleAspectBottomRight)
        imageView.mt.displayImage(url: URL, filters: filters, options: options)
        //imageView.play(withGIFURL: URL, filters: filters, contentMode: .original, cacheOption: .usedMemoryCache)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
