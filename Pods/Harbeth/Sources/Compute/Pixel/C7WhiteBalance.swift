//
//  C7WhiteBalance.swift
//  ATMetalBand
//
//  Created by Condy on 2022/2/15.
//

import Foundation

/// 基于色温调整白平衡
public struct C7WhiteBalance: C7FilterProtocol {
    
    public static let range: ParameterRange<Float, Self> = .init(min: 4000, max: 7000, value: 5000)
    
    /// The tint to adjust the image by. A value of -200 is very green and 200 is very pink.
    @Clamping(-200...200) public var tint: Float = 0
    /// The temperature to adjust the image by, in ºK. A value of 4000 is very cool and 7000 very warm.
    /// Note that the scale between 4000 and 5000 is nearly as visually significant as that between 5000 and 7000.
    @Clamping(range.min...range.max) public var temperature: Float = range.value
    
    public var modifier: Modifier {
        return .compute(kernel: "C7WhiteBalance")
    }
    
    public var factors: [Float] {
        return [temperature, tint]
    }
    
    public init(temperature: Float = range.value, tint: Float = 0) {
        self.temperature = temperature
        self.tint = tint
    }
}
