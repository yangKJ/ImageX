//
//  AnimatedOthers.swift
//  ImageX
//
//  Created by Condy on 2023/6/29.
//

import Foundation

// 特殊参数
public struct AnimatedOthers {
    
    public typealias Key = String
    
    public let key: Key
    
    public let value: Any
    
    public init(key: String, value: Any) {
        self.key = key
        self.value = value
    }
}

extension AnimatedOthers {
    enum ButtonKey: AnimatedOthers.Key {
        case image = "ButtonKeyImage"
        case backgroundImage = "ButtonKeyBackgroundImage"
    }
}
