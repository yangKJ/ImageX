//
//  HasAnimatable.swift
//  Wintersweet
//
//  Created by Condy on 2023/2/6.
//

import Foundation

public protocol HasAnimatable: NSObjectProtocol {
    /// Responsible for managing the animation frames.
    //var animator: Animator? { get set }
    
    /// View frame used for resizing the frames.
    var frame: CGRect { get set }
    
    #if !os(macOS)
    /// Notifies the instance that it needs display.
    var layer: CALayer { get }
    #endif
}

fileprivate struct AssociatedKeys {
    static var AnimatorKey = "condy.gif.animator.key"
}

extension HasAnimatable {
    /// Responsible for managing the animation frames.
    weak var animator: Animator? {
        get {
            return synchronizedAnimator {
                if let animator = objc_getAssociatedObject(self, &AssociatedKeys.AnimatorKey) as? Animator {
                    return animator
                }
                guard let weakself = self as? AsAnimatable else {
                    return nil
                }
                let animator = Animator(withDelegate: weakself)
                self.animator = animator
                return animator
            }
        }
        set {
            synchronizedAnimator {
                objc_setAssociatedObject(self, &AssociatedKeys.AnimatorKey, newValue as Animator?, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    func synchronizedAnimator<T>( _ action: () -> T) -> T {
        objc_sync_enter(self)
        let result = action()
        objc_sync_exit(self)
        return result
    }
}
