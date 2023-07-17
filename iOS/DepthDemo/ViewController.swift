//
//  ViewController.swift
//  DepthDemo
//
//  Created by Condy on 2023/1/5.
//

import UIKit
import ImageX
import Harbeth

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
    }
    
    @IBAction func goGIF(_ sender: Any) {
        let vc = AnimatedViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func clearCache(_ sender: UIButton) {
        Cached.shared.storage.removedDiskAndMemoryCached { isSuccess in
            print("Clean up completed!!!")
        }
    }
    
    let filters: [C7FilterProtocol] = [
        C7SoulOut(soul: 0.75),
        C7Storyboard(ranks: 2),
    ]
    func setup() {
        let links = [
            //"pikachu",
            //"https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/IMG_3960.heic",
            //"https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/IMG_0139.gif",
            "https://blog.ibireme.com/wp-content/uploads/2015/11/bench_gif_demo.gif",
            //"http://littlesvr.ca/apng/images/SteamEngine.webp", // Animated
            //"https://nokiatech.github.io/heif/content/images/ski_jump_1440x960.heic",
            //"https://nokiatech.github.io/heif/content/image_sequences/starfield_animation.heic", // Animated
            //"https://apng.onevcat.com/assets/elephant.png", // Animated
            //"https://nr-platform.s3.amazonaws.com/uploads/platform/published_extension/branding_icon/275/AmazonS3.png",
            //"https://res.cloudinary.com/dwpjzbyux/raw/upload/v1666474070/RawDemo/raw_vebed5.NEF",
        ]
        let named = links.randomElement() ?? ""
        var options = ImageXOptions()
        options.placeholder = .image(R.image("AppIcon")!)
        options.contentMode = .scaleAspectFit
        options.Animated.loop = .forever
        options.Animated.bufferCount = 20
        //options.Animated.frameType = .appoint(8)
        options.Cache.cacheOption = .disk
        options.Cache.cacheCrypto = .sha1
        options.Cache.cacheDataZip = .gzip
        options.Network.retry = DelayRetry(maxRetryCount: 2, retryInterval: .accumulated(2))
        options.Animated.setPreparationBlock(block: { res in
            self.label.text = "\(res.frameCount) frames / \(String(format: "%.2f", res.loopDuration))s"
        })
        options.Animated.setAnimatedBlock(block: { _ in
            print("Played end!!!")
        })
        imageView.mt.setImage(with: named, filters: filters, options: options)
    }
}
