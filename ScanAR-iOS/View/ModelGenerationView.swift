//
//  ModelGenerationView.swift
//  ScanAR-iOS
//
//  Created by Vladyslav Vdovychenko on 29.03.2023.
//

import SwiftUI

struct ModelGenerationView: View {
    
    var directoryURL: URL
    
    private let manager = ModelGenerationManager()
    
    var body: some View {
        Button {
            start()
        } label: {
            Text("Start!")
        }

    }
    
    func start() {
        manager.uploadFiles(from: directoryURL) { response in
            print(response)
        }
    }
}

struct ModelGenerationView_Previews: PreviewProvider {
    static var previews: some View {
        ModelGenerationView(directoryURL: URL(string: "google.com")!)
    }
}
