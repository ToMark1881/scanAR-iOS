//
//  ContentView.swift
//  ScanAR-iOS
//
//  Created by Vladyslav Vdovychenko on 29.03.2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var model: CameraViewModel

    var body: some View {
        ZStack {
            // Make the entire background black.
            Color.black.edgesIgnoringSafeArea(.all)
            CameraView(model: model)
        }
        .environment(\.colorScheme, .dark)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    @StateObject private static var model = CameraViewModel()
    static var previews: some View {
        ContentView(model: model)
    }
}
