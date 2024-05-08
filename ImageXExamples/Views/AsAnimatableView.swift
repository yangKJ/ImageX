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
    
    @State var data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    var body: some View {
        VStack {
            AsAnimatableView_Bridge(data: data)
        }
    }
}

struct AsAnimatableView_Previews: PreviewProvider {
    static var previews: some View {
        let data = Res.PokemonData
        AsAnimatableView(data: data)
    }
}

fileprivate struct AsAnimatableView_Bridge: CPViewRepresentable {
    
    @State var data: Data
    
    func makeUIView(context: Context) -> AsAnimatableView__ {
        let view = AsAnimatableView__(frame: .zero, data: data)
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

fileprivate class AsAnimatableView__: CPView {
    // 自定义控件播放动态图像
    class AnimatingView: CPView, AsAnimatable {
        
    }
    
    lazy var animatedView: AnimatingView = {
        let view = AnimatingView.init(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        //view.layer.contentsGravity = .resizeAspect
        view.backgroundColor = CPColor.red.withAlphaComponent(0.3)
        return view
    }()
    
    let data: Data
    
    required init(frame: CGRect, data: Data) {
        self.data = data
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
            animatedView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
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
        options.resizingMode = .scaleAspectFit
        options.Animated.loop = .forever
        options.filters = filters
        animatedView.play(data: data, options: options)
    }
}
