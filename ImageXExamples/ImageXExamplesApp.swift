//
//  ImageXExamplesApp.swift
//  ImageXExamples
//
//  Created by Condy on 2023/7/24.
//

import SwiftUI

@main
struct MetalPetalExamplesApp: App {
    
    #if os(macOS)
    var windowFrame = NSScreen.main!.visibleFrame
    #endif
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                #if os(macOS)
                .frame(width: 888, height: 600)
                #endif
        }
    }
}
