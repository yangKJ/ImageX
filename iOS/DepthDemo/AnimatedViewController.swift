//
//  AnimatedViewController.swift
//  DepthDemo
//
//  Created by Condy on 2023/1/5.
//

import Foundation
import ImageX
import Harbeth

class AnimatedView: UIView, AsAnimatable {
    
}

class AnimatedViewController: UIViewController {
    
    lazy var animatedView: AnimatedView = {
        let view = AnimatedView.init(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.contentsGravity = .resizeAspect
        view.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        return view
    }()
    
    lazy var placeholder: UILabel = {
        let label = UILabel()
        label.text = "Condy"
        label.backgroundColor = .cyan
        label.font = UIFont.systemFont(ofSize: 50)
        label.textAlignment = .center
        return label
    }()
    
    lazy var animatedButton: UIButton = {
        let button = UIButton.init(type: .custom)
        button.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var richLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "test GIFs"
        setupUI()
        setupGIFs()
        setupButton()
        setupRichLabel()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(animatedButton)
        view.addSubview(animatedView)
        view.addSubview(richLabel)
        NSLayoutConstraint.activate([
            animatedView.topAnchor.constraint(equalTo: view.topAnchor, constant: 100),
            animatedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            animatedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            animatedView.heightAnchor.constraint(equalTo: animatedView.widthAnchor, multiplier: 1),
            animatedButton.topAnchor.constraint(equalTo: animatedView.bottomAnchor, constant: 20),
            animatedButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            animatedButton.widthAnchor.constraint(equalToConstant: 150),
            animatedButton.heightAnchor.constraint(equalToConstant: 150),
            richLabel.topAnchor.constraint(equalTo: animatedButton.bottomAnchor, constant: 20),
            richLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            richLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            richLabel.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    func setupGIFs() {
        let filters: [C7FilterProtocol] = [
            C7WhiteBalance(temperature: 5555),
            C7Storyboard(ranks: 3)
        ]
        let data = R.gifData("pikachu")
        var options = ImageXOptions()
        options.Animated.loop = .forever
        //options.Animated.bufferCount = 5
        options.placeholder = .view(placeholder)
        //options.contentMode = .scaleAspectBottomRight
        animatedView.play(data: data, filters: filters, options: options)
    }
    
    func setupButton() {
        var options = ImageXOptions()
        options.placeholder = .image(R.image("AppIcon")!)
        options.contentMode = .scaleAspectFit
        options.Animated.loop = .count(8)
        options.Animated.bufferCount = 20
        options.Cache.cacheOption = .disk
        options.Cache.cacheCrypto = .sha1
        options.Cache.cacheDataZip = .gzip
        options.Network.retry = DelayRetry(maxRetryCount: 2, retryInterval: .accumulated(2))
        options.Animated.setPreparationBlock(block: { _ in
            print("do something..")
        })
        options.Animated.setAnimatedBlock(block: { [weak self] _ in
            print("Played end!!!\(self?.animatedButton.image(for: .normal) ?? UIImage())")
        })
        options.Network.setNetworkProgress(block: { progress in
            print("download: - \(progress)")
        })
        options.Network.setNetworkFailed(block: { error in
            print("Failed: - \(error.localizedDescription)")
        })
        let named = "https://media.gcflearnfree.org/content/588f55e5a0b0042cb858653b_01_30_2017/images_stock_puppy.jpg"
        //let named = "https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/IMG_3960.heic"
        //let named = "https://nr-platform.s3.amazonaws.com/uploads/platform/published_extension/branding_icon/275/AmazonS3.png"
        animatedButton.mt.setImage(with: named, for: .normal, options: options)
    }
    
    func setupRichLabel() {
        
    }
    
    deinit {
        print("AnimatedViewController is deinit.")
    }
}
