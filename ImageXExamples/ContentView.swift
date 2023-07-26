//
//  ContentView.swift
//  ImageXExamples
//
//  Created by Condy on 2023/7/24.
//

import SwiftUI
import ImageX

struct ContentView: View {
    
    @State var isShowAlert: Bool = false
    
    var body: some View {
        NavigationView {
            List {
                Label {
                    Text("Remove the disk cached")
                        .font(.title3)
                        .foregroundColor(.blue)
                } icon: {
                    
                }.onTapGesture {
                    Cached.shared.storage.removedDiskAndMemoryCached { isSuccess in
                        self.isShowAlert = isSuccess
                    }
                }
                Section {
                    NavigationLink(destination: ButtonView()) {
                        Text("played at button")
                    }
                    NavigationLink(destination: AsAnimatableView()) {
                        Text("custom view with play gif")
                    }
                } header: {
                    Text("Other")
                }
                Section {
                    NavigationLink(destination: AnimatedView(web: Res.png)) {
                        Text("Displayed png image")
                    }
                    NavigationLink(destination: AnimatedView(web: Res.jpg)) {
                        Text("Displayed jpp image")
                    }
                    NavigationLink(destination: AnimatedView(web: Res.heic)) {
                        Text("Displayed heic image")
                    }
                    NavigationLink(destination: AnimatedView(web: Res.nef)) {
                        Text("Displayed NEF image")
                    }
                } header: {
                    Text("Still image at image view")
                }
                Section {
                    NavigationLink(destination: AnimatedView(web: Res.gif)) {
                        Text("Played animated gif")
                    }
                    NavigationLink(destination: AnimatedView(web: Res.animated_webp)) {
                        Text("Played animated webp")
                    }
                    NavigationLink(destination: AnimatedView(web: Res.animated_png)) {
                        Text("played animated png")
                    }
                } header: {
                    Text("Played at image view")
                }
            }
            .alert(isPresented: self.$isShowAlert) {
                Alert(title: Text("Clean up completed!!!"))
            }
            .listStyle(.automatic)
            .textCase(.lowercase)
            .inlineNavigationBarTitle("ImageX Examples")
            
            VStack(spacing: 6) {
                Text("Welcome to ImageX examples.")
                Text("Select a topic to begin.").font(Font.caption).foregroundColor(.secondary)
            }
            .toolbar(content: { Spacer() })
        }
        .stackNavigationViewStyle()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice("iPad (8th generation)")
    }
}
