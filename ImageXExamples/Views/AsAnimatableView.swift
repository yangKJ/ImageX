//
//  AsAnimatableView.swift
//  ImageXExamples
//
//  Created by Condy on 2023/7/25.
//

import SwiftUI
import ImageX
import Harbeth

struct AsAnimatableView: View {
    var body: some View {
        VStack {
            AsAnimatableView_Bridge()
        }
    }
}

struct AsAnimatableView_Previews: PreviewProvider {
    static var previews: some View {
        AsAnimatableView()
    }
}

fileprivate struct AsAnimatableView_Bridge: CPViewRepresentable {
    
    func makeUIView(context: Context) -> AsAnimatableView__ {
        let view = AsAnimatableView__()
        return view
    }
    
    func updateUIView(_ uiView: AsAnimatableView__, context: Context) {
        
    }
    
    func makeNSView(context: Context) -> AsAnimatableView__ {
        makeUIView(context: context)
    }
    
    func updateNSView(_ nsView: AsAnimatableView__, context: Context) {
        updateUIView(nsView, context: context)
    }
}

// 自定义控件播放动态图像
fileprivate class AnimatingView: CPView, AsAnimatable {
    
}

fileprivate class AsAnimatableView__: CPView {
    
    lazy var animatedView: AnimatingView = {
        let view = AnimatingView.init(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.layer.contentsGravity = .resizeAspect
        view.backgroundColor = CPColor.red.withAlphaComponent(0.3)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupInit()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupInit() {
        setupUI()
        setupGIFs()
    }
    
    func setupUI() {
        addSubview(animatedView)
        NSLayoutConstraint.activate([
            animatedView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            animatedView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -20),
            animatedView.widthAnchor.constraint(equalToConstant: 360),
            animatedView.heightAnchor.constraint(equalTo: animatedView.widthAnchor, multiplier: 1),
        ])
    }
    
    func setupGIFs() {
        let filters: [C7FilterProtocol] = [
            C7WhiteBalance(temperature: 5555),
            C7Storyboard(ranks: 3),
            C7Granularity(grain: 0.2)
        ]
        var options = ImageXOptions()
        options.placeholder = .image(Res.P0020)
        options.contentMode = .scaleAspectFit
        options.Animated.loop = .forever
        animatedView.play(data: Res.PokemonData, filters: filters, options: options)
    }
}
