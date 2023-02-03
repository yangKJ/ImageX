//
//  ViewController.swift
//  DepthDemo
//
//  Created by Condy on 2023/1/5.
//

import UIKit
import Wintersweet

class ViewController: UIViewController {
    
    @IBOutlet weak var animatedView: GIFView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    let imageName: String = "cycling"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setup(imageName: imageName)
    }
    
    func setup(imageName: String) {
        guard let imagePath = Bundle.main.url(forResource: imageName, withExtension: "gif"),
              let data = try? Data(contentsOf: imagePath) else {
            return
        }
        //imageView.setAnimatedFrameContentMode(.scaleAspectFill)
        let filters: [C7FilterProtocol] = [
            C7SoulOut(soul: 0.75),
            C7ColorConvert(with: .rbga),
            C7Storyboard(ranks: 2),
        ]
        imageView.play(withGIFData: data, filters: filters, preparation: {
            self.label.text = imageName.capitalized + " (\(self.imageView.frameCount) frames / \(String(format: "%.2f", self.imageView.loopDuration))s)"
        })
        
        animatedView.layer.contentsGravity = .resizeAspect
        //let URL = URL(string: "https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7a00f7f6c0c744a893f304a7d3b629b5~tplv-k3u1fbpfcp-watermark.image?")!
        let URL = URL(string: "https://raw.githubusercontent.com/yangKJ/KJBannerViewDemo/master/KJBannerViewDemo/Resources/IMG_0139.GIF")!
        animatedView.play(withGIFURL: URL, filters: [
            C7WhiteBalance(temperature: 5555),
            C7LookupTable(image: R.image("lut_x"))
        ], loop: .count(3), cacheOption: Cached.Options.usedMemoryCache)
    }
}

extension UIImageView: AsAnimatable, ImageContainer {
    private struct AssociatedKeys {
        static var AnimatorKey = "condy.gif.animator.key"
    }
    
    public var animator: Animator? {
        get {
            guard let animator = objc_getAssociatedObject(self, &AssociatedKeys.AnimatorKey) as? Animator else {
                let animator = Animator(withDelegate: self)
                self.animator = animator
                return animator
            }
            return animator
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.AnimatorKey, newValue as Animator?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

class GIFView: UIView, AsAnimatable {
    public lazy var animator: Animator? = {
        return Animator(withDelegate: self)
    }()
}
