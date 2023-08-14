//
//  iOS.swift
//  ImageXExamples
//
//  Created by Condy on 2023/7/26.
//

import Foundation

#if os(iOS)
import UIKit

extension UIApplication {
    var topMostViewController: UIViewController? {
        let rootWindow = self.windows.first(where: { $0.isHidden == false })
        var topMostViewController: UIViewController? = rootWindow?.rootViewController
        while topMostViewController?.presentedViewController != nil {
            topMostViewController = topMostViewController?.presentedViewController
        }
        return topMostViewController
    }
}

#endif
