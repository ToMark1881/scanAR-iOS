//
//  ModelGenerationManager.swift
//  ScanAR-iOS
//
//  Created by Vladyslav Vdovychenko on 29.03.2023.
//

import Foundation

enum GenerationState {
    case uploading
    case generating(progress: String)
    case downloading
    case done
}

class ModelGenerationManager: NSObject {
    
    private enum Constants {
        static let host = "192.168.1.146"
        static let port = 8080
    }
    
    private var currentSessionId: String?
    
    func uploadFiles(from directoryUrl: URL, completion: @escaping (() -> Void)) {
        var request = URLRequest(url: URL(string: "http://" + Constants.host + ":" + Constants.port.description + "/upload-photos/")!)
        request.httpMethod = "POST"

        // Set up the URLSession configuration and session object
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)

        // Set up the multipart form data body
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Get the list of files in the directory
        let fileManager = FileManager.default
        let files = try! fileManager.contentsOfDirectory(at: directoryUrl, includingPropertiesForKeys: nil)
        
        var bodyData = Data()
        for fileUrl in files {
            let fileName = fileUrl.lastPathComponent
            
            bodyData.append("--\(boundary)\r\n".data(using: .utf8)!)
            bodyData.append("Content-Disposition: form-data; name=\"files[]\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
            bodyData.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
            
            let fileData = try! Data(contentsOf: fileUrl)
            bodyData.append(fileData)
            bodyData.append("\r\n".data(using: .utf8)!)
        }
        bodyData.append("--\(boundary)--\r\n".data(using: .utf8)!)

        // Set the request body
        request.httpBody = bodyData

        // Create the upload task
        let uploadTask = session.uploadTask(with: request, from: nil) { (data, response, error) in
            if let error = error {
                print("Error uploading files: \(error)")
            } else {
                let id = String(decoding: data!, as: UTF8.self)
                self.currentSessionId = id
                completion()
            }
        }

        // Start the upload task
        uploadTask.resume()
    }
    
    func getProgress(completion: ((String) -> Void)) {
        guard let id = currentSessionId else {
            return
        }
        
        // Set up the WebSocket URL components
        var webSocketUrlComponents = URLComponents()
        webSocketUrlComponents.scheme = "wss"
        webSocketUrlComponents.host = Constants.host
        webSocketUrlComponents.port = Constants.port
        webSocketUrlComponents.path = "/progress"
        webSocketUrlComponents.queryItems = [
            URLQueryItem(name: "id", value: id)
        ]

        // Create the WebSocket URL
        let webSocketUrl = webSocketUrlComponents.url!

        // Create the WebSocket task
        let webSocketTask = URLSession.shared.webSocketTask(with: webSocketUrl)

        // Start the WebSocket task
        webSocketTask.resume()

        // Receive messages from the WebSocket
        webSocketTask.receive { result in
            switch result {
            case .failure(let error):
                print("Error receiving WebSocket message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    print("Received WebSocket message: \(text)")
                case .data(let data):
                    print("Received WebSocket message (data): \(data)")
                @unknown default:
                    fatalError("Received unknown WebSocket message type")
                }
            }
        }
    }
    
    func downloadModel(into destinationURL: URL) {
        guard let id = currentSessionId else {
            return
        }
        
        // Set up the URL components
        var urlComponents = URLComponents()
        urlComponents.scheme = "http"
        urlComponents.host = Constants.host
        urlComponents.port = Constants.port
        urlComponents.path = "/download-model"

        let fileURL = urlComponents.url!
        
        let json = ["id": id]
        let jsonData = try! JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url: fileURL)
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        // Set up the multipart form data body
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        

        // Create a URLSession configuration
        let sessionConfig = URLSessionConfiguration.default

        // Create a URLSession instance
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)

        // Create a download task
        let downloadTask = session.dataTask(with: request) { (data, response, error) in
            // Check for errors
            guard error == nil else {
                print("Error downloading file: \(error!.localizedDescription)")
                return
            }
            
            // Check if there's a response
            guard let httpResponse = response as? HTTPURLResponse else {
                print("No response received")
                return
            }
            
            // Check if the response was successful
            guard (200...299).contains(httpResponse.statusCode) else {
                print("Response status code: \(httpResponse.statusCode)")
                return
            }
            
            // Check if there's a local URL for the downloaded file
            guard let data = data else {
                print("No local URL for downloaded file")
                return
            }
            
            // Move the downloaded file to the desired location
            let url = destinationURL.appendingPathComponent("\(id).usdz")
            
            do {
                try data.write(to: url)
                print("File downloaded to: \(url.absoluteString)")
            } catch {
                print("Error moving downloaded file: \(error.localizedDescription)")
            }
        }

        // Start the download task
        downloadTask.resume()
    }
    
}


extension ModelGenerationManager: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didSendBodyData bytesSent: Int64,
                    totalBytesSent: Int64,
                    totalBytesExpectedToSend: Int64) {
        let uploadProgress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        print("Upload progress: \(uploadProgress)")
    }
    
}

extension ModelGenerationManager: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        let downloadProgress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print("Download progress: \(downloadProgress)")
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        print("Downloaded")
    }
    
}
