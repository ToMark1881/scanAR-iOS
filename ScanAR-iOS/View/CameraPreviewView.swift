//
//  CameraPreviewView.swift
//  ScanAR-iOS
//
//  Created by Vladyslav Vdovychenko on 29.03.2023.
//

import AVFoundation
import SwiftUI
import UIKit

import os

private let logger = Logger(subsystem: "com.tomark.scanar-ios",
                            category: "CameraPreviewView")

struct CameraPreviewView: UIViewRepresentable {
    let previewViewCornerRadius: CGFloat = 50
    
    class PreviewView: UIView {
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            guard let layer = layer as? AVCaptureVideoPreviewLayer else {
                fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
            }
            return layer
        }
        
        var session: AVCaptureSession? {
            get {
                return videoPreviewLayer.session
            }
            set {
                videoPreviewLayer.session = newValue
            }
        }
        
        override class var layerClass: AnyClass {
            return AVCaptureVideoPreviewLayer.self
        }
    }
    
    let session: AVCaptureSession
    
    init(session: AVCaptureSession) {
        self.session = session
    }
    
    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        
        view.backgroundColor = .black
        view.videoPreviewLayer.cornerRadius = 0
        view.videoPreviewLayer.connection?.videoOrientation = .portrait
        
        return view
    }
    
    func updateUIView(_ uiView: PreviewView, context: Context) {  }
}

