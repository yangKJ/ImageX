//
//  AnimatedView.swift
//  ImageXExamples
//
//  Created by Condy on 2023/7/25.
//

import SwiftUI
import ImageX
import Harbeth

struct AnimatedView: View {
    
    @State var web: String = ""
    
    var body: some View {
        VStack {
            AnimatedView_Bridge(link: $web)
        }
    }
}

struct AnimatedView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedView()
    }
}

fileprivate struct AnimatedView_Bridge: CPViewRepresentable {
    
    @Binding var link: String
    
    func makeUIView(context: Context) -> AnimatedView__ {
        let view = AnimatedView__(frame: .zero, link: link)
        return view
    }
    
    func updateUIView(_ uiView: AnimatedView__, context: Context) {
        
    }
    
    func makeNSView(context: Context) -> AnimatedView__ {
        makeUIView(context: context)
    }
    
    func updateNSView(_ nsView: AnimatedView__, context: Context) {
        updateUIView(nsView, context: context)
    }
}

fileprivate class AnimatedView__: CPView {
    
    let link: String
    
    lazy var animatedImageView: CPImageView = {
        let imageView = CPImageView()
        imageView.backgroundColor = CPColor.blue.withAlphaComponent(0.2)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        #if !os(macOS)
        imageView.contentMode = .scaleAspectFit
        #endif
        return imageView
    }()
    
    lazy var resultLabel: CPLabel = {
        let label = CPLabel()
        label.text = String("loading..")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    required init(frame: CGRect, link: String) {
        self.link = link
        super.init(frame: frame)
        self.setupInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupInit() {
        setupUI()
        setupTestCase()
    }
    
    func setupUI() {
        addSubview(resultLabel)
        addSubview(animatedImageView)
        NSLayoutConstraint.activate([
            animatedImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            animatedImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -20),
            animatedImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            animatedImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            animatedImageView.heightAnchor.constraint(equalTo: animatedImageView.widthAnchor, multiplier: 1),
            resultLabel.topAnchor.constraint(equalTo: animatedImageView.bottomAnchor, constant: 20),
            resultLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            resultLabel.heightAnchor.constraint(equalToConstant: 20),
        ])
    }
    
    func setupTestCase() {
        var options = ImageXOptions()
        options.placeholder = .image(Res.P5820030)
        options.resizingMode = .scaleAspectFit
        options.Animated.loop = .forever
        options.Animated.bufferCount = 20
        //options.Animated.frameType = .appoint(8)
        options.Cache.cacheOption = .disk
        options.Cache.cacheCrypto = .sha1
        options.Cache.cacheDataZip = .gzip
        options.Network.retry = DelayRetry(maxRetryCount: 2, retryInterval: .accumulated(2))
        options.Animated.setPreparationBlock(block: { [weak self] res in
            self?.resultLabel.text = "\(res.frameCount) frames / \(String(format: "%.2f", res.loopDuration))s"
        })
        options.Animated.setAnimatedBlock(block: { _ in
            print("Played end!!!")
        })
        options.Network.setNetworkProgress(block: { [weak self] progress in
            DispatchQueue.main.img.safeAsync {
                if progress >= 1 {
                    self?.resultLabel.text = String("Downloaded")
                } else {
                    self?.resultLabel.text = String("Downloading: \(progress)")
                }
            }
        })
        options.Network.setNetworkFailed(block: { error in
            print("Failed: - \(error.localizedDescription)")
        })
        
        let filters: [C7FilterProtocol] = [
            C7SoulOut(soul: 0.75),
            C7Storyboard(ranks: 2),
        ]
        animatedImageView.img.setImage(with: link, filters: filters, options: options)
    }
}
