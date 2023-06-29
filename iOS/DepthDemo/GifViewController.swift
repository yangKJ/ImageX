//
//  GIFViewController.swift
//  DepthDemo
//
//  Created by Condy on 2023/1/5.
//

import Foundation
import ImageX

class AnimatedView: UIView, AsAnimatable {
    
}

class GIFViewController: UIViewController {
    
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
        //button.setImage(R.image(""), for: .normal)
        button.frame = CGRect(x: 20, y: self.view.frame.size.height - 250, width: 150, height: 150)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        setupGIF()
        setupButton()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(animatedView)
        view.addSubview(animatedButton)
        NSLayoutConstraint.activate([
            animatedView.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            animatedView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            animatedView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            animatedView.heightAnchor.constraint(equalTo: animatedView.widthAnchor, multiplier: 1),
        ])
    }
    
    func setupGIF() {
        let filters: [C7FilterProtocol] = [
            C7WhiteBalance(temperature: 5555),
            C7Storyboard(ranks: 3)
        ]
        let data = R.gifData("pikachu")
        var options = AnimatedOptions()
        options.loop = .count(5)
        options.placeholder = .view(placeholder)
        animatedView.play(data: data, filters: filters, options: options)
    }
    
    func setupButton() {
        var options = AnimatedOptions()
        options.loop = .count(5)
        options.placeholder = .color(.systemGreen)
        options.contentMode = .scaleAspectFit
        options.bufferCount = 20
        options.cacheOption = .disk
        options.cacheCrypto = .sha1
        options.cacheDataZip = .gzip
        options.retry = DelayRetry(maxRetryCount: 2, retryInterval: .accumulated(2))
        options.setPreparationBlock(block: {
            print("do something..")
        })
        options.setAnimatedBlock(block: { [weak self] _ in
            print("Played end!!!\(self?.animatedButton.image(for: .normal) ?? UIImage())")
        })
        let named = "https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/IMG_0139.gif"
        animatedButton.mt.setImage(named: named, for: .normal, options: options)
    }
    
    deinit {
        print("GIFViewController is deinit.")
    }
}
