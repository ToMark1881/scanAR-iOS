//
//  CameraView.swift
//  ScanAR-iOS
//
//  Created by Vladyslav Vdovychenko on 29.03.2023.
//

import Foundation
import SwiftUI

struct CameraView: View {
    static let buttonBackingOpacity: CGFloat = 0.15
    
    @ObservedObject var model: CameraViewModel
    @State private var showInfo: Bool = false
    
    let aspectRatio: CGFloat = 4.0 / 3.0
    let previewCornerRadius: CGFloat = 15.0
    
    var body: some View {
        NavigationView {
            GeometryReader { geometryReader in
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        Spacer()
                        CaptureDeviceView(model: model)
                            .padding(.bottom, 8)
                        
                        CameraPreviewView(session: model.session)
                            .frame(width: geometryReader.size.width,
                                   height: geometryReader.size.width * aspectRatio,
                                   alignment: .center)
                            .clipShape(RoundedRectangle(cornerRadius: previewCornerRadius))
                            .onAppear { model.startSession() }
                            .onDisappear { model.pauseSession() }
                            .overlay(
                                Image("ObjectReticle")
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.all))
                        
                        Spacer()
                    }
                    
                    VStack {
                        ScanToolbarView(model: model, showInfo: $showInfo).padding(.horizontal)
                        if showInfo {
                            InfoPanelView(model: model)
                                .padding(.horizontal).padding(.top)
                        }
                        Spacer()
                        CaptureButtonPanelView(model: model, width: geometryReader.size.width)
                    }
                }
            }
            .navigationTitle(Text("Scan"))
            .navigationBarTitle("Scan")
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CaptureButtonPanelView: View {
    @ObservedObject var model: CameraViewModel
    
    var width: CGFloat
    
    var body: some View {
        ZStack(alignment: .center) {
            HStack {
                ThumbnailView(model: model)
                    .frame(width: width / 3)
                    .padding(.horizontal)
                Spacer()
            }
            HStack {
                Spacer()
                CaptureButton(model: model)
                Spacer()
            }
            HStack {
                Spacer()
                CaptureModeButton(model: model,
                                  frameWidth: width / 3)
                .padding(.horizontal)
            }
        }
    }
}

struct ScanToolbarView: View {
    @ObservedObject var model: CameraViewModel
    @Binding var showInfo: Bool
    
    var body: some View {
        ZStack {
            HStack {
                SystemStatusIcon(model: model)
                Button(action: {
                    withAnimation {
                        showInfo.toggle()
                    }
                }, label: {
                    Image(systemName: "info.circle").foregroundColor(Color.blue)
                })
                Spacer()
                NavigationLink(destination: HelpPageView()) {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(Color.blue)
                }
            }
            
            if showInfo {
                Text("Current Capture Info")
                    .font(.caption)
                    .onTapGesture {
                        print("showInfo toggle!")
                        withAnimation {
                            showInfo.toggle()
                        }
                    }
            }
        }
    }
}

struct CaptureButton: View {
    static let outerDiameter: CGFloat = 80
    static let strokeWidth: CGFloat = 4
    static let innerPadding: CGFloat = 10
    static let innerDiameter: CGFloat = CaptureButton.outerDiameter - CaptureButton.strokeWidth - CaptureButton.innerPadding
    static let rootTwoOverTwo: CGFloat = CGFloat(2.0.squareRoot() / 2.0)
    static let squareDiameter: CGFloat = CaptureButton.innerDiameter * CaptureButton.rootTwoOverTwo - CaptureButton.innerPadding
    
    @ObservedObject var model: CameraViewModel
    
    init(model: CameraViewModel) {
        self.model = model
    }
    
    var body: some View {
        Button(action: {
            model.captureButtonPressed()
        }, label: {
            if model.isAutoCaptureActive {
                AutoCaptureButtonView(model: model)
            } else {
                ManualCaptureButtonView()
            }
        }).disabled(!model.isCameraAvailable || !model.readyToCapture)
    }
}

struct AutoCaptureButtonView: View {
    @ObservedObject var model: CameraViewModel
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color.red)
                .frame(width: CaptureButton.squareDiameter,
                       height: CaptureButton.squareDiameter,
                       alignment: .center)
                .cornerRadius(5)
            TimerView(model: model, diameter: CaptureButton.outerDiameter)
        }
    }
}

struct ManualCaptureButtonView: View {
    var body: some View {
        ZStack {
            Circle()
                .strokeBorder(Color.white, lineWidth: CaptureButton.strokeWidth)
                .frame(width: CaptureButton.outerDiameter,
                       height: CaptureButton.outerDiameter,
                       alignment: .center)
            Circle()
                .foregroundColor(Color.white)
                .frame(width: CaptureButton.innerDiameter,
                       height: CaptureButton.innerDiameter,
                       alignment: .center)
        }
    }
}

struct CaptureDeviceView: View {
    
    @State private var selectedMode: Int = 0
    
    @ObservedObject var model: CameraViewModel
    
    var body: some View {
        Picker("Capture Device", selection: $selectedMode) {
            Text("Regular").tag(0)
            Text("Wide").tag(1)
        }
        .onChange(of: selectedMode) { newValue in
            model.advanceToNextCaptureDevice(CameraViewModel.CaptureDevice(rawValue: newValue)!)
        }
        .colorMultiply(.white)
    }
    
}

struct CaptureModeButton: View {
    static let toggleDiameter = CaptureButton.outerDiameter / 3.0
    static let backingDiameter = CaptureModeButton.toggleDiameter * 2.0
    
    @ObservedObject var model: CameraViewModel
    var frameWidth: CGFloat
    
    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Button(action: {
                withAnimation {
                    model.advanceToNextCaptureMode()
                }
            }, label: {
                ZStack {
                    Circle()
                        .frame(width: CaptureModeButton.backingDiameter,
                               height: CaptureModeButton.backingDiameter)
                        .foregroundColor(Color.white)
                        .opacity(Double(CameraView.buttonBackingOpacity))
                    Circle()
                        .frame(width: CaptureModeButton.toggleDiameter,
                               height: CaptureModeButton.toggleDiameter)
                        .foregroundColor(Color.white)
                    switch model.captureMode {
                    case .automatic:
                        Text("A").foregroundColor(Color.black)
                            .frame(width: CaptureModeButton.toggleDiameter,
                                   height: CaptureModeButton.toggleDiameter,
                                   alignment: .center)
                    case .manual:
                        Text("M").foregroundColor(Color.black)
                            .frame(width: CaptureModeButton.toggleDiameter,
                                   height: CaptureModeButton.toggleDiameter,
                                   alignment: .center)
                    }
                }
            })
            if case .automatic = model.captureMode {
                Text("Auto Capture")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .transition(.opacity)
            }
        }
        .frame(width: frameWidth, height: CaptureModeButton.backingDiameter, alignment: .top)
    }
}

struct ThumbnailView: View {
    private let thumbnailFrameWidth: CGFloat = 60.0
    private let thumbnailFrameHeight: CGFloat = 60.0
    private let thumbnailFrameCornerRadius: CGFloat = 10.0
    private let thumbnailStrokeWidth: CGFloat = 2
    
    @ObservedObject var model: CameraViewModel
    
    init(model: CameraViewModel) {
        self.model = model
    }
    
    var body: some View {
        NavigationLink(destination: CaptureGalleryView(model: model)) {
            if let capture = model.lastCapture {
                if let preview = capture.previewUiImage {
                    ThumbnailImageView(uiImage: preview,
                                       width: thumbnailFrameWidth,
                                       height: thumbnailFrameHeight,
                                       cornerRadius: thumbnailFrameCornerRadius,
                                       strokeWidth: thumbnailStrokeWidth)
                } else {
                    ThumbnailImageView(uiImage: capture.uiImage,
                                       width: thumbnailFrameWidth,
                                       height: thumbnailFrameHeight,
                                       cornerRadius: thumbnailFrameCornerRadius,
                                       strokeWidth: thumbnailStrokeWidth)
                }
            } else {
                Image(systemName: "photo.on.rectangle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(16)
                    .frame(width: thumbnailFrameWidth, height: thumbnailFrameHeight)
                    .foregroundColor(.primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: thumbnailFrameCornerRadius)
                            .fill(Color.white)
                            .opacity(Double(CameraView.buttonBackingOpacity))
                            .frame(width: thumbnailFrameWidth,
                                   height: thumbnailFrameWidth,
                                   alignment: .center)
                    )
            }
        }
    }
}

struct ThumbnailImageView: View {
    var uiImage: UIImage
    var thumbnailFrameWidth: CGFloat
    var thumbnailFrameHeight: CGFloat
    var thumbnailFrameCornerRadius: CGFloat
    var thumbnailStrokeWidth: CGFloat
    
    init(uiImage: UIImage, width: CGFloat, height: CGFloat, cornerRadius: CGFloat,
         strokeWidth: CGFloat) {
        self.uiImage = uiImage
        self.thumbnailFrameWidth = width
        self.thumbnailFrameHeight = height
        self.thumbnailFrameCornerRadius = cornerRadius
        self.thumbnailStrokeWidth = strokeWidth
    }
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: thumbnailFrameWidth, height: thumbnailFrameHeight)
            .cornerRadius(thumbnailFrameCornerRadius)
            .clipped()
            .overlay(RoundedRectangle(cornerRadius: thumbnailFrameCornerRadius)
                .stroke(Color.primary, lineWidth: thumbnailStrokeWidth))
            .shadow(radius: 10)
    }
}
