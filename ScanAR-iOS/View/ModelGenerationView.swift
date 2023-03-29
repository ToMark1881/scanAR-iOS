//
//  ModelGenerationView.swift
//  ScanAR-iOS
//
//  Created by Vladyslav Vdovychenko on 29.03.2023.
//

import SwiftUI

struct ModelGenerationView: View {
    
    var directoryURL: URL
    
    @State private var progress: String = "Progress: 0"
    
    private let manager = ModelGenerationManager()
    
    var body: some View {
        VStack(spacing: 12) {
            Button {
                start()
            } label: {
                Text("Start!")
            }
            
            Button {
                trackProgress()
            } label: {
                Text("Progress")
            }
            
            Text(progress)
            
            Button {
                download()
            } label: {
                Text("Download")
            }

        }

    }
    
    init(directoryURL: URL) {
        self.directoryURL = directoryURL
    }
    
    func start() {
        manager.uploadFiles(from: directoryURL) { }
    }
    
    func trackProgress() {
        manager.getProgress { progress in
            self.progress = "Progress: \(progress)"
        }
    }
    
    func download() {
        manager.downloadModel(into: directoryURL)
    }
}

struct ModelGenerationView_Previews: PreviewProvider {
    static var previews: some View {
        ModelGenerationView(directoryURL: URL(string: "google.com")!)
    }
}
