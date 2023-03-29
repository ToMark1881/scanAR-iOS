//
//  ContentView.swift
//  ScanAR-iOS
//
//  Created by Vladyslav Vdovychenko on 29.03.2023.
//

import SwiftUI

/// This is the root view for the app.
struct ContentView: View {
    @ObservedObject var model: CameraViewModel

    var body: some View {
        ZStack {
            // Make the entire background black.
            Color.black.edgesIgnoringSafeArea(.all)
            CameraView(model: model)
        }
        // Force dark mode so the photos pop.
        .environment(\.colorScheme, .dark)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    @StateObject private static var model = CameraViewModel()
    static var previews: some View {
        ContentView(model: model)
    }
}
