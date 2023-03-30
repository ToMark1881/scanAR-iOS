//
//  ModelGenerationView.swift
//  ScanAR-iOS
//
//  Created by Vladyslav Vdovychenko on 29.03.2023.
//

import SwiftUI

enum GenerationState {
    case new
    case uploading(progress: Int)
    case generating(progress: Int)
    case downloading(progress: Int)
    case done
    
    var description: String {
        switch self {
        case .new:
            return "New"
        case .uploading(let progress):
            return "Uploading \(progress.description)"
        case .generating(let progress):
            return "Generating \(progress.description)"
        case .downloading(let progress):
            return "Downloading \(progress.description)"
        case .done:
            return "Done!"
        }
    }
}

struct ModelGenerationView: View {
    
    var directoryURL: URL
    @State private var state: GenerationState = .new
    
    private let manager = ModelGenerationManager()
    
    var body: some View {
        VStack {
            Button {
                start()
            } label: {
                Text("START!")
            }
            
            Text(state.description)
                .padding(.vertical, 12)
        }
    }
    
    init(directoryURL: URL) {
        self.directoryURL = directoryURL
    }
    
    func start() {
        manager.uploadFiles(from: directoryURL) { progress in
            switch progress {
            case .inProgress(let progress):
                self.state = .uploading(progress: progress)
                
            case .finished:
                trackProgress()
            }
        }
    }
    
    func trackProgress() {
        self.state = .generating(progress: 0)
        manager.getProgress { progress in
            switch progress {
            case .inProgress(let progress):
                self.state = .generating(progress: progress)
                
            case .finished:
                download()
            }
        }
    }
    
    func download() {
        manager.downloadModel(into: directoryURL) { progress in
            switch progress {
            case .inProgress(let progress):
                self.state = .downloading(progress: progress)
            case .finished:
                self.state = .done
            }
        } completion: { url in
            openModel(from: url)
        }
    }
    
    func openModel(from url: URL) {
        
    }
}

struct EmptyGenerationView: View {
    
    var body: some View {
        EmptyView()
    }
    
}

struct ModelGenerationView_Previews: PreviewProvider {
    static var previews: some View {
        ModelGenerationView(directoryURL: URL(string: "google.com")!)
    }
}
