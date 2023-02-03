//
//  NSViewController+Ext.swift
//  DepthMacDemo
//
//  Created by Condy on 2023/1/12.
//

import Foundation
import Cocoa

extension NSViewController {
    
    func push(viewController: NSViewController, completion: (() -> Void)? = nil) {
        guard let window = view.window else {
            return
        }
        let origin = CGPoint(x: window.frame.midX - viewController.view.frame.width / 2.0, y: window.frame.midY - viewController.view.frame.height / 2.0)
        let windowFrame = CGRect(origin: origin, size: viewController.view.frame.size)
        guard !NSWorkspace.shared.accessibilityDisplayShouldReduceMotion else {
            window.makeFirstResponder(viewController)
            // The delay is needed to prevent weird UI race issues on macOS 12. For example, it caused the video in the editor to not show up.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                window.contentViewController = nil
                window.setFrame(windowFrame, display: true)
                window.contentViewController = viewController
                completion?()
            })
            return
        }
        
        viewController.view.alphaValue = 0.0
        
        // Workaround for macOS first responder quirk. Still in macOS 10.15.3.
        // Reproduce: Without the below, if you click convert, hide the window, show the window when the conversion is done,
        // and then drag and drop a new file, the width/height text fields are now not editable.
        window.makeFirstResponder(viewController)
        
        NSAnimationContext.runAnimationGroup({ _ in
            window.contentViewController?.view.animator().alphaValue = 0.0
            window.contentViewController = nil
            window.animator().setFrame(windowFrame, display: true)
        }, completionHandler: {
            window.contentViewController = viewController
            viewController.view.animator().alphaValue = 1.0
            completion?()
        })
    }
}
