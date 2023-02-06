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
    
    let imageName: String = "cycling"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup(imageName: imageName)
    }
    
    @IBAction func goGIF(_ sender: Any) {
        let vc = GifViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func setup(imageName: String) {
        guard let imagePath = Bundle.main.url(forResource: imageName, withExtension: "gif"),
              let data = try? Data(contentsOf: imagePath) else {
            return
        }
        let filters: [C7FilterProtocol] = [
            C7SoulOut(soul: 0.75),
            C7ColorConvert(with: .rbga),
            C7Storyboard(ranks: 2),
        ]
        imageView.play(withGIFData: data, filters: filters, preparation: {
            self.label.text = imageName.capitalized + " (\(self.imageView.frameCount) frames / \(String(format: "%.2f", self.imageView.loopDuration))s)"
        })
    }
}
