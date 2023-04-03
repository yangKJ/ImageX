//
//  GifViewController.swift
//  DepthDemo
//
//  Created by Condy on 2023/2/6.
//

import Foundation
import Wintersweet

class GIFView: UIView, AsAnimatable {
    
}

class GifViewController: UIViewController {
    
    lazy var animatedView: GIFView = {
        let view = GIFView.init(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.contentsGravity = .resizeAspect
        view.backgroundColor = UIColor.red.withAlphaComponent(0.3)
        return view
    }()
    
    lazy var placeholder: UILabel = {
        let label = UILabel()
        label.text = "Condy"
        label.backgroundColor = .systemCyan
        label.font = UIFont.systemFont(ofSize: 50)
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        setupGIF()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(animatedView)
        NSLayoutConstraint.activate([
            animatedView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
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
        let options = AnimatedOptions(loop: .count(5), placeholder: .view(placeholder))
        animatedView.play(data: data, filters: filters, options: options)
    }
    
    deinit {
        print("GifViewController is deinit.")
    }
}
