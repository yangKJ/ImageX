//
//  Res.swift
//  ImageXExamples
//
//  Created by Condy on 2023/7/25.
//

import Foundation
import SwiftUI

struct Res {
    
    static let heic = "https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/IMG_3960.heic"
    static let png = "https://nr-platform.s3.amazonaws.com/uploads/platform/published_extension/branding_icon/275/AmazonS3.png"
    static let nef = "https://res.cloudinary.com/dwpjzbyux/raw/upload/v1666474070/RawDemo/raw_vebed5.NEF"
    static let jpg = "https://media.gcflearnfree.org/content/588f55e5a0b0042cb858653b_01_30_2017/images_stock_puppy.jpg"
    static let jpeg = "https://raw.githubusercontent.com/yangKJ/Harbeth/master/Demo/Harbeth-iOS-Demo/Resources/Assets.xcassets/yuan002.imageset/11.jpeg"
    
    #if os(macOS)
    static let gif = "https://raw.githubusercontent.com/yangKJ/ImageX/master/Images/IMG_0139.gif"
    #else
    static let gif = "https://blog.ibireme.com/wp-content/uploads/2015/11/bench_gif_demo.gif"
    #endif
    static let animated_webp = "http://littlesvr.ca/apng/images/SteamEngine.webp"
    static let animated_png = "https://apng.onevcat.com/assets/elephant.png" // Animated
    
    static let PokemonData = Res.readData("Pokemon", withExtension: "gif")!
    
    static let P0020 = Res.read("IMG_0020", withExtension: "jpg")!
    
    static let P5820030 = Res.read("Miserablefaith", withExtension: "jpg")!
}

extension Res {
    static func read(_ named: String, withExtension: String = "png") -> CPImage? {
        guard let data = readData(named, withExtension: withExtension) else {
            return nil
        }
        return CPImage.init(data: data)
    }
    
    static func readData(_ named: String, withExtension: String = "gif") -> Data? {
        guard let contentURL = Bundle.main.url(forResource: named, withExtension: withExtension),
              let data = try? Data(contentsOf: contentURL) else {
            return nil
        }
        return data
    }
}
