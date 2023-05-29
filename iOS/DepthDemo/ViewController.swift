//
//  ViewController.swift
//  DepthDemo
//
//  Created by Condy on 2023/1/5.
//

import UIKit
import Wintersweet

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup()
    }
    
    @IBAction func goGIF(_ sender: Any) {
        let vc = GifViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    let filters: [C7FilterProtocol] = [
        C7SoulOut(soul: 0.75),
        C7Storyboard(ranks: 2),
    ]
    func setup() {
        let links = [
            "pikachu",
            "https://raw.githubusercontent.com/yangKJ/Wintersweet/master/Images/IMG_0139.gif",
            "https://raw.githubusercontent.com/yangKJ/Harbeth/master/Demo/Harbeth-iOS-Demo/Resources/Assets.xcassets/IMG_3960.imageset/IMG_3960.heic"
        ]
        let named = links.randomElement() ?? ""
        var options = AnimatedOptions(loop: .forever,
                                      placeholder: .color(.systemGreen),
                                      contentMode: .scaleAspectFit,
                                      bufferCount: 20,
                                      cacheOption: .disk,
                                      cacheCrypto: .sha1,
                                      cacheDataZip: .gzip)
        options.setPreparationBlock(block: { [weak self] in
            guard let `self` = self else { return }
            self.label.text = "\(self.imageView.frameCount) frames / \(String(format: "%.2f", self.imageView.loopDuration))s"
        })
        options.setAnimatedBlock(block: { _ in
            print("Played end!!!")
        })
        imageView.mt.displayImage(named: named, filters: filters, options: options)
    }
}
