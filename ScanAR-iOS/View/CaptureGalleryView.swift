//
//  CaptureGalleryView.swift
//  ScanAR-iOS
//
//  Created by Vladyslav Vdovychenko on 29.03.2023.
//

import Combine
import Foundation
import SwiftUI

struct CaptureGalleryView: View {
    private let columnSpacing: CGFloat = 3
    
    @ObservedObject var model: CameraViewModel
    @ObservedObject private var captureFolderState: CaptureFolderState
    @State var zoomedCapture: CaptureInfo? = nil
    @State private var showCaptureFolderView: Bool = false
    let usingCurrentCaptureFolder: Bool
    let portraitLayout: [GridItem] = [ GridItem(.flexible()),
                                       GridItem(.flexible()),
                                       GridItem(.flexible()) ]
    
    init(model: CameraViewModel) {
        self.model = model
        self.captureFolderState = model.captureFolderState!
        usingCurrentCaptureFolder = true
    }
    
    init(model: CameraViewModel, observing captureFolderState: CaptureFolderState) {
        self.model = model
        self.captureFolderState = captureFolderState
        usingCurrentCaptureFolder = (model.captureFolderState?.captureDir?.lastPathComponent
                                        == captureFolderState.captureDir?.lastPathComponent)
    }
    
    var body: some View {
        ZStack {
            Color(red: 0, green: 0, blue: 0.01, opacity: 1).ignoresSafeArea(.all)
            NavigationLink(destination: CaptureFoldersView(model: model),
                           isActive: self.$showCaptureFolderView) {
                EmptyView()
            }
            .frame(width: 0, height: 0)
            .disabled(true)
            
            GeometryReader { geometryReader in
                ScrollView() {
                    LazyVGrid(columns: portraitLayout, spacing: columnSpacing) {
                        ForEach(captureFolderState.captures, id: \.id) { captureInfo in
                            GalleryCell(captureInfo: captureInfo,
                                        cellWidth: geometryReader.size.width / 3,
                                        cellHeight: geometryReader.size.width / 3,
                                        zoomedCapture: $zoomedCapture)
                        }
                    }
                }
            }
            .blur(radius: zoomedCapture != nil ? 20 : 0)
            
            ModelGenerationButtonView(shouldShow: !captureFolderState.captures.isEmpty,
                                      directoryURL: captureFolderState.captureDir)
            
            if zoomedCapture != nil {
                ZStack(alignment: .top) {
                    // Add a transluscent layer over the blur to make the text pop.
                    Color(red: 0.25, green: 0.25, blue: 0.25, opacity: 0.25)
                        .ignoresSafeArea(.all)
                    
                    VStack {
                        FullSizeImageView(captureInfo: zoomedCapture!)
                            .onTapGesture {
                                zoomedCapture = nil
                            }
                    }
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            captureFolderState.removeCapture(captureInfo: zoomedCapture!,
                                                             deleteData: true)
                            zoomedCapture = nil
                        }) {
                            Text("Delete").foregroundColor(Color.red)
                        }.padding()
                    }
                }
            }
        }
        .navigationTitle(Text("\(captureFolderState.captureDir?.lastPathComponent ?? "NONE")"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: HStack {
            NewSessionButtonView(model: model, usingCurrentCaptureFolder: usingCurrentCaptureFolder)
                .padding(.horizontal, 5)
            if usingCurrentCaptureFolder {
                Button(action: {
                    self.showCaptureFolderView = true
                }) {
                    Image(systemName: "folder")
                }
            }
        })
    }
}

struct ModelGenerationButtonView: View {
    
    var shouldShow: Bool
    var directoryURL: URL?
    
    var body: some View {
        VStack {
            Spacer()
            
            if let url = directoryURL, shouldShow {
                NavigationLink {
                    ModelGenerationView(directoryURL: url)
                } label: {
                    Text("Create model β")
                        .padding()
                        .foregroundColor(.black)
                        .font(.system(size: 18))
                        .background(
                            LinearGradient(gradient: Gradient(colors: [.cyan, .blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(Capsule())
                }
                .padding(.bottom, 12)
            }
        }
    }
    
}

struct NewSessionButtonView: View {
    @ObservedObject var model: CameraViewModel
    
    @Environment(\.presentationMode) private var presentation
    
    var usingCurrentCaptureFolder: Bool = true
    
    var body: some View {
        if usingCurrentCaptureFolder {
            Menu(content: {
                Button(action: {
                    model.requestNewCaptureFolder()
                    // Navigate back to the main scan page.
                    presentation.wrappedValue.dismiss()
                }) {
                    Label("New Session", systemImage: "camera")
                }
            }, label: {
                Image(systemName: "plus.circle")
            })
        }
    }
}

struct GalleryCell: View {
    let captureInfo: CaptureInfo
    @Binding var zoomedCapture: CaptureInfo?
    @State private var existence: CaptureInfo.FileExistence = CaptureInfo.FileExistence()
    
    let cellWidth: CGFloat
    let cellHeight: CGFloat
    
    var publisher: AnyPublisher<CaptureInfo.FileExistence, Never>
    
    init(captureInfo: CaptureInfo, cellWidth: CGFloat, cellHeight: CGFloat,
         zoomedCapture: Binding<CaptureInfo?>) {
        self.captureInfo = captureInfo
        self.cellWidth = cellWidth
        self.cellHeight = cellHeight
        self._zoomedCapture = zoomedCapture
        
        publisher = captureInfo.checkFilesExist()
            .receive(on: DispatchQueue.main)
            .replaceError(with: CaptureInfo.FileExistence())
            .eraseToAnyPublisher()
    }
    
    var body : some View {
        ZStack {
            AsyncThumbnailView(url: captureInfo.imageUrl)
                .frame(width: cellWidth, height: cellHeight)
                .clipped()
                .onTapGesture {
                    withAnimation {
                        self.zoomedCapture = captureInfo
                    }
                }
                .onReceive(publisher, perform: { loadedExistence in
                    existence = loadedExistence
                })
            MetadataExistenceSummaryView(existence: existence)
                .font(.caption)
                .padding(.all, 2)
        }
    }
}

struct MetadataExistenceSummaryView: View {
    var existence: CaptureInfo.FileExistence
    private let paddingPixels: CGFloat = 2
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                if existence.depth && existence.gravity {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.green)
                        .padding(.all, paddingPixels)
                } else if existence.depth || existence.gravity {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundColor(Color.yellow)
                        .padding(.all, paddingPixels)
                } else {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color.red)
                        .padding(.all, paddingPixels)
                }
                Spacer()
            }
        }
    }
}

struct MetadataExistenceView: View {
    var existence: CaptureInfo.FileExistence
    var textLabels: Bool = false
    
    var body: some View {
        HStack {
            if existence.depth {
                Image(systemName: "square.3.stack.3d.top.fill")
                    .foregroundColor(Color.green)
            } else {
                Image(systemName: "xmark.circle")
                    .foregroundColor(Color.red)
            }
            if textLabels {
                Text("Depth")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if existence.gravity {
                Image(systemName: "arrow.down.to.line.alt")
                    .foregroundColor(Color.green)
            } else {
                Image(systemName: "xmark.circle")
                    .foregroundColor(Color.red)
            }
            if textLabels {
                Text("Gravity")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct FullSizeImageView: View {
    let captureInfo: CaptureInfo
    var publisher: AnyPublisher<CaptureInfo.FileExistence, Never>
    
    @State private var existence = CaptureInfo.FileExistence()
    
    init(captureInfo: CaptureInfo) {
        self.captureInfo = captureInfo
        publisher = captureInfo.checkFilesExist()
            .receive(on: DispatchQueue.main)
            .replaceError(with: CaptureInfo.FileExistence())
            .eraseToAnyPublisher()
    }
    
    var body: some View {
        VStack {
            Text(captureInfo.imageUrl.lastPathComponent)
                .font(.caption)
                .padding()
            GeometryReader { geometryReader in
                AsyncImageView(url: captureInfo.imageUrl)
                    .frame(width: geometryReader.size.width, height: geometryReader.size.height)
                    .aspectRatio(contentMode: .fit)
            }
            MetadataExistenceView(existence: existence, textLabels: true)
                .onReceive(publisher, perform: { loadedExistence in
                    existence = loadedExistence
                })
                .padding(.all)
        }
        .transition(.opacity)
    }
}
