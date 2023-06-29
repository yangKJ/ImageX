//
//  ViewController.swift
//  DepthDemo
//
//  Created by Condy on 2023/1/5.
//

import UIKit
import ImageX

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
            "pikachu",
            "https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/IMG_0139.gif",
            "https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/IMG_3960.heic",
            "https://media.gcflearnfree.org/content/588f55e5a0b0042cb858653b_01_30_2017/images_stock_puppy.jpg",
        ]
        let named = links.randomElement() ?? ""
        var options = AnimatedOptions()
        options.loop = .forever
        options.placeholder = .color(.systemGreen)
        options.contentMode = .scaleAspectFit
        options.bufferCount = 20
        options.cacheOption = .disk
        options.cacheCrypto = .sha1
        options.cacheDataZip = .gzip
        options.retry = DelayRetry(maxRetryCount: 2, retryInterval: .accumulated(2))
        options.setPreparationBlock(block: { [weak self] in
            guard let `self` = self else {
                return
            }
            self.label.text = "\(self.imageView.frameCount) frames / \(String(format: "%.2f", self.imageView.loopDuration))s"
        })
        options.setAnimatedBlock(block: { _ in
            print("Played end!!!")
        })
        imageView.mt.setImage(named: named, filters: filters, options: options)
    }
}
