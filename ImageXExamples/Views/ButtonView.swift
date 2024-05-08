//
//  ButtonView.swift
//  ImageXExamples
//
//  Created by Condy on 2023/7/25.
//

import SwiftUI
import ImageX
import Harbeth

struct ButtonView: View {
    
    var body: some View {
        VStack {
            ButtonView_Bridge()
            VStack(alignment: .leading) {
                Text("Touch image to try..").textCase(.none)
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.secondarySystemBackground))
            .padding()
        }
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView()
    }
}

fileprivate struct ButtonView_Bridge: CPViewRepresentable {
    
    func makeUIView(context: Context) -> ButtonView__ {
        let view = ButtonView__()
        return view
    }
    
    func updateUIView(_ uiView: ButtonView__, context: Context) {
        
    }
    
    func makeNSView(context: Context) -> ButtonView__ {
        makeUIView(context: context)
    }
    
    func updateNSView(_ nsView: ButtonView__, context: Context) {
        updateUIView(nsView, context: context)
    }
}

fileprivate class ButtonView__: CPView {
    
    lazy var animatedButton: CPButton = {
        let button = CPButton()
        button.backgroundColor = CPColor.blue.withAlphaComponent(0.2)
        button.translatesAutoresizingMaskIntoConstraints = false
        #if os(macOS)
        button.action = #selector(click)
        button.setButtonType(.toggle)
        #else
        button.adjustsImageWhenHighlighted = false
        button.addTarget(self, action: #selector(click(_:)), for: .touchUpInside)
        #endif
        return button
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
        setupTestCase()
    }
    
    func setupUI() {
        addSubview(animatedButton)
        //animatedButton.frame = CGRect(x: 20, y: 100, width: Res.width-40, height: Res.width-40)
        NSLayoutConstraint.activate([
            animatedButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            animatedButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            animatedButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            animatedButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            animatedButton.heightAnchor.constraint(equalTo: animatedButton.widthAnchor, multiplier: 1),
        ])
    }
    
    func setupTestCase() {
        var options = ImageXOptions()
        options.placeholder = .image(Res.P5820030)
        options.resizingMode = .scaleAspectFit
        options.Animated.loop = .forever
        options.Animated.bufferCount = 20
        options.Cache.cacheOption = .disk
        options.Cache.cacheCrypto = .sha1
        options.Cache.cacheDataZip = .gzip
        options.Network.retry = .max3s
        
        let filters: [C7FilterProtocol] = [
            C7SoulOut(soul: 0.2),
            C7Storyboard(ranks: 2),
            C7ColorConvert(with: .rbga)
        ]
        options.filters = filters
        #if os(macOS)
        animatedButton.img.setImage(with: Res.jpeg, options: options)
        animatedButton.img.setAlternateImage(with: Res.jpeg, options: options)
        #else
        animatedButton.img.setImage(with: Res.jpeg, for: .normal, options: options)
        animatedButton.img.setImage(with: Res.gif, for: .selected, options: options)
        #endif
    }
    
    @objc private func click(_ sender: CPButton) {
        #if os(macOS)
        
        #else
        sender.isSelected = !sender.isSelected
        #endif
    }
}
