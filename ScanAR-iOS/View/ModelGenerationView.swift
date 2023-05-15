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
    case processing
    case generating(progress: Int)
    case downloading(progress: Int)
    case done(url: URL)
    
    var description: String {
        switch self {
        case .new:
            return "New"
        case .uploading(let progress):
            return "Uploading \(progress.description)"
        case .processing:
            return "Processing"
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
            switch state {
            case .new:
                Button {
                    start()
                } label: {
                    Text("Start model generation")
                        .padding()
                        .foregroundColor(.black)
                        .font(.system(size: 18))
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.pink, .red]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(Capsule())
                }
                
            case .uploading(let progress):
                var value = Float(progress) / 100
                let binding = Binding(get: { value }, set: { value = $0 })
                VStack {
                    Text("Uploading photos...")
                        .font(.title)
                        .bold()
                        .padding(.bottom, 12)
                    ProgressBar(progress: binding, color: .green)
                        .padding(40)
                }
            
            case .processing:
                Text("Processing photos...")
                    .font(.title)
                    .bold()
                    .padding(.bottom, 12)
                
            case .generating(let progress):
                var value = Float(progress) / 100
                let binding = Binding(get: { value }, set: { value = $0 })
                VStack {
                    Text("Generating model...")
                        .font(.title)
                        .bold()
                        .padding(.bottom, 12)
                    ProgressBar(progress: binding, color: .red)
                        .padding(40)
                }
                
            case .downloading(let progress):
                var value = Float(progress) / 100
                let binding = Binding(get: { value }, set: { value = $0 })
                VStack {
                    Text("Downloading model...")
                        .font(.title)
                        .bold()
                        .padding(.bottom, 12)
                    ProgressBar(progress: binding, color: .blue)
                        .padding(40)
                }
                
            case .done(let url):
                NavigationLink {
                    ModelPreviewView(fileURL: url)
                } label: {
                    Text("Preview model in AR")
                        .padding()
                        .foregroundColor(.black)
                        .font(.system(size: 18))
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.yellow, .green]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    init(directoryURL: URL) {
        self.directoryURL = directoryURL
    }
    
    func start() {
        manager.uploadFiles(from: directoryURL) { progress in
            switch progress {
            case .inProgress(let progress):
                self.state = progress == 100 ? .processing : .uploading(progress: progress)
                                
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
                
            default:
                break
            }
        } completion: { url in
            self.state = .done(url: url)
        }
    }
}
