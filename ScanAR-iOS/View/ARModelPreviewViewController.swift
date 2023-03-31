//
//  ARModelPreviewViewController.swift
//  ScanAR-iOS
//
//  Created by Vladyslav Vdovychenko on 30.03.2023.
//

import UIKit
import QuickLook
import ARKit

class ARModelPreviewViewController: UIViewController, QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    var fileURL: URL!
    private var didPresentARPreview: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard !didPresentARPreview else { return }
        
        let previewController = QLPreviewController()
        previewController.dataSource = self
        previewController.delegate = self
        present(previewController, animated: false, completion: nil)
        didPresentARPreview = true
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return fileURL as QLPreviewItem
    }
    
    func previewControllerDidDismiss(_ controller: QLPreviewController) {
        self.navigationController?.popViewController(animated: false)
    }
    
}
