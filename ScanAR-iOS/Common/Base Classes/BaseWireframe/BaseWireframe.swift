//
//  BaseWireframe.swift
//
//
//  Created by macbook on 09.10.2020.
//

import Foundation
import UIKit

class BaseWireframe {

    weak var presentedViewController: UIViewController?

    init() {
        Logger.shared.log("🆕 \(self)", type: .lifecycle)
    }
    
    deinit {
        Logger.shared.log("🗑 \(self)", type: .lifecycle)
    }

    func initializeController<T:UIViewController>() -> T? {
        return self.storyboard.instantiateViewController(withIdentifier: identifier()) as? T
    }

    var storyboard: UIStoryboard {
        get {
            return UIStoryboard(name: storyboardName(), bundle: nil)
        }
    }

    func storyboardName() -> String {
        assert(false, "Must override")

        return ""
    }

    func identifier() -> String {
        assert(false, "Must override")

        return ""
    }

    var isShowed: Bool {
        get {
            return self.presentedViewController != nil
        }
    }

    func dismissViewController(animated: Bool = true, completion: EmptyCompletionBlock = nil) {
        self.presentedViewController?.dismiss(animated: animated, completion: completion)
        //self.presentedViewController = nil
    }
    
    func popViewController(animated: Bool = true) {
        if let navigationController = self.presentedViewController?.navigationController {
            navigationController.popViewController(animated: animated)
        } else {
            dismissViewController(animated: animated)
        }
    }
}
