//
//  SceneDelegate.swift
//  ScanAR-iOS
//
//  Created by Vladyslav Vdovychenko on 31.01.2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: scene)
        window.rootViewController = initialiseRootController()
        self.window = window
        window.makeKeyAndVisible()
    }


}


private extension SceneDelegate {
    
    func initialiseRootController() -> UIViewController {
        let wireframe: RootWireframe = .init()
        var moduleInput: RootModuleInput?
        
        let controller = wireframe.createModule(moduleInput: &moduleInput, moduleOutput: nil)!
        return controller
    }
    
}

