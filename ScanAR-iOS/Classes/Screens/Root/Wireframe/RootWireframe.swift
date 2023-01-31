//  VIPER Template created by Vladyslav Vdovychenko
//  
//  RootWireframe.swift
//  ScanAR-iOS
//
//  Created by Vladyslav Vdovychenko on 31.01.2023.
//

import Foundation
import UIKit

final class RootWireframe: BaseWireframe {
    
    override func storyboardName() -> String {
        return "Root"
    }
    
    override func identifier() -> String {
        return "RootViewController"
    }
    
    func pushFrom(_ parent: UINavigationController?,
                  moduleInput: inout RootModuleInput?,
                  moduleOutput: RootModuleOutput? = nil) {
        guard let viewController = self.createModule(moduleInput: &moduleInput,
                                                     moduleOutput: moduleOutput),
              let parent = parent else { return }
        
        self.presentedViewController = viewController
        parent.pushViewController(viewController, animated: true)
    }
    
    func presentIn(_ parent: UIViewController?,
                   moduleInput: inout RootModuleInput?,
                   moduleOutput: RootModuleOutput? = nil) {
        guard let viewController = self.createModule(moduleInput: &moduleInput,
                                                     moduleOutput: moduleOutput),
              let parent = parent else { return }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        self.presentedViewController = viewController
        
        navigationController.modalPresentationStyle = .fullScreen
        parent.present(navigationController, animated: true, completion: nil)
    }
    
    func createModule(moduleInput: inout RootModuleInput?,
                      moduleOutput: RootModuleOutput?) -> RootViewController? {
        guard let view: RootViewController = initializeController() else { return nil }
        let presenter = RootPresenter()
        let router = RootRouter()
        let interactor = RootInteractor()
        
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        
        view.output = presenter
        router.output = presenter
        
        router.view = view
        presenter.moduleOutput = moduleOutput
        
        interactor.output = presenter
        
        moduleInput = presenter
        
        return view
    }
    
}
