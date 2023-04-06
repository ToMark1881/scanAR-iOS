//
//  ModelPreviewView.swift
//  ScanAR-iOS
//
//  Created by Vladyslav Vdovychenko on 30.03.2023.
//

import SwiftUI

struct ModelPreviewView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = ARModelPreviewViewController
    
    let fileURL: URL
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let controller = ARModelPreviewViewController()
        controller.fileURL = fileURL
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
    
}
