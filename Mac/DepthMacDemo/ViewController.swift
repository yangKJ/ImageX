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
        let URL = URL(string: "https://raw.githubusercontent.com/yangKJ/KJBannerViewDemo/master/KJBannerViewDemo/Resources/IMG_0139.GIF")!
        imageView.play(withGIFURL: URL, filters: filters, contentMode: .original)
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
