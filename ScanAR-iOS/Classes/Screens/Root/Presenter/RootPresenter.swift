//  VIPER Template created by Vladyslav Vdovychenko
//  
//  RootPresenter.swift
//  ScanAR-iOS
//
//  Created by Vladyslav Vdovychenko on 31.01.2023.
//

import Foundation

final class RootPresenter: BasePresenter {
    
    weak var view: RootViewInput!
    var interactor: RootInteractorInput!
    var router: RootRouterInput!
    
    weak var moduleOutput: RootModuleOutput?
    
}

// MARK: - Module Input
extension RootPresenter: RootModuleInput {
    
}

// MARK: - View - Presenter
extension RootPresenter: RootViewOutput {
    
}

// MARK: - Interactor - Presenter
extension RootPresenter: RootInteractorOutput {
    
}

// MARK: - Router - Presenter
extension RootPresenter: RootRouterOutput {
    
}
