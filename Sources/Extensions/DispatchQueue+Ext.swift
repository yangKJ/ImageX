//
//  DispatchQueue+Ext.swift
//  Pods
//
//  Created by Condy on 2024/4/1.
//

import Foundation

extension DispatchQueue: ImageXCompatible { }

extension ImageXEngine where Base: DispatchQueue {
    
    public func safeAsync(_ block: @escaping () -> ()) {
        if base === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            base.async { block() }
        }
    }
    
    public func safeSync(_ block: @escaping () -> ()) {
        if base === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            base.sync { block() }
        }
    }
}
