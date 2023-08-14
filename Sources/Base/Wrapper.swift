//
//  Wrapper.swift
//  Pods
//
//  Created by Condy on 2023/8/8.
//

import Foundation

/// Add the `kj` prefix namespace
public struct ImageXEngine<Base> {
    public let base: Base
}

public protocol ImageXCompatible { }

extension ImageXCompatible {
    
    public var kj: ImageXEngine<Self> {
        get { return ImageXEngine(base: self) }
        set { }
    }
}
