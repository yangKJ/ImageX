//
//  C7Sepia.swift
//  Harbeth
//
//  Created by Condy on 2022/2/23.
//

import Foundation

/// 棕褐色，老照片
public struct C7Sepia: C7FilterProtocol {
    
    /// The degree to which tan replaces normal image color, from 0.0 to 1.0
    @ZeroOneRange public var intensity: Float = R.iRange.value
    
    public var modifier: Modifier {
        return .compute(kernel: "C7Sepia")
    }
    
    public var factors: [Float] {
        return [intensity]
    }
    
    public init(intensity: Float = R.iRange.value) {
        self.intensity = intensity
    }
}
