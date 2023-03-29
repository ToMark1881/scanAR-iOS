//
//  ModelGenerationManager.swift
//  ScanAR-iOS
//
//  Created by Vladyslav Vdovychenko on 29.03.2023.
//

import Foundation

struct UploadResponse: Decodable {
    let sessionId: String
}

class ModelGenerationManager: NSObject {
    
    private var apiUrl: URL {
        return URL(string: "192.168.1.146:8080/")!
    }
    
    func uploadFiles(from directoryUrl: URL, completion: ((UploadResponse) -> Void)) {
        var request = URLRequest(url: URL(string: "http://" + apiUrl.absoluteString + "upload-photos/")!)
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
                print("Successfully uploaded files")
            }
        }

        // Start the upload task
        uploadTask.resume()
    }
    
    func getProgress(for id: String) {
        // Set up the WebSocket URL components
        var webSocketUrlComponents = URLComponents()
        webSocketUrlComponents.scheme = "wss"
        webSocketUrlComponents.host = apiUrl.absoluteString
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
    
}

extension ModelGenerationManager: URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let uploadProgress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
    }
    
}
