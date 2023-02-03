//
//  DisplayLinkProxy.swift
//  Wintersweet
//
//  Created by Condy on 2023/1/5.
//

import Foundation

/// A proxy class to avoid a retain cycle with the display link.
final class DisplayLinkProxy: NSObject {
    
    weak var target: Animator?
    
    init(target: Animator) {
        self.target = target
    }
    
    /// Lets the target update the frame if needed.
    @objc func onScreenUpdate(_ sender: CADisplayLink) {
        guard let animator = target, let store = animator.frameStore else {
            return
        }
        if store.isFinished {
            animator.stopAnimating()
            animator.animationBlock?(store.loopDuration)
            return
        }
        store.shouldChangeFrame(with: sender.duration) {
            if $0 { animator.delegate.updateImageIfNeeded() }
        }
    }
}
