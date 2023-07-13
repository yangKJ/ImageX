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
        let vc = GIFViewController()
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
            //"https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/IMG_0139.gif",
            //"https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/IMG_3960.heic",
            "https://blog.ibireme.com/wp-content/uploads/2015/11/bench_gif_demo.gif",
        ]
        let named = links.randomElement() ?? ""
        var options = AnimatedOptions()
        options.placeholder = .image(R.image("AppIcon")!)
        options.contentMode = .scaleAspectFit
        options.GIFs.loop = .forever
        options.GIFs.bufferCount = 20
        options.Network.cacheOption = .disk
        options.Network.cacheCrypto = .sha1
        options.Network.cacheDataZip = .gzip
        options.Network.retry = DelayRetry(maxRetryCount: 2, retryInterval: .accumulated(2))
        options.GIFs.setPreparationBlock(block: { res in
            self.label.text = "\(res.frameCount) frames / \(String(format: "%.2f", res.loopDuration))s"
        })
        options.GIFs.setAnimatedBlock(block: { _ in
            print("Played end!!!")
        })
        imageView.mt.setImage(with: named, filters: filters, options: options)
    }
}
