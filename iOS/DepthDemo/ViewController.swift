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
    
    let imageName: String = "pikachu"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup(imageName: imageName)
    }
    
    @IBAction func goGIF(_ sender: Any) {
        let vc = GifViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    let filters: [C7FilterProtocol] = [
        C7SoulOut(soul: 0.75),
        C7Storyboard(ranks: 2),
    ]
    func setup(imageName: String) {
        let options = AnimatedOptions(contentMode: .scaleAspectFit, bufferCount: 10, preparation: { [weak self] in
            guard let `self` = self else { return }
            self.label.text = imageName.capitalized + " (\(self.imageView.frameCount) frames / \(String(format: "%.2f", self.imageView.loopDuration))s)"
        }, animated: { _ in
            print("Played end!!!")
        })
        imageView.mt.displayImage(named: imageName, filters: filters, options: options)
    }
}
